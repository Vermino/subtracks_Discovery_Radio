import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart' show Value;
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pool/pool.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';

import '../cache/image_cache.dart';
import '../database/database.dart';
import '../log.dart';
import '../models/hybrid_track.dart';
import '../models/music.dart';
import '../models/query.dart';
import '../models/support.dart';
import '../models/youtube_models.dart';
import '../sources/music_source.dart';
import '../state/settings.dart';
import 'cache_service.dart';
import 'discovery_service.dart';
import 'settings_service.dart';
import 'youtube_cache_service.dart';
import 'youtube_discovery_service.dart';

part 'audio_service.g.dart';

class QueueSourceItem {
  final MediaItem mediaItem;
  final UriAudioSource audioSource;
  final QueueData queueData;

  const QueueSourceItem({
    required this.mediaItem,
    required this.audioSource,
    required this.queueData,
  });
}

class QueueSlice {
  final QueueSourceItem? prev;
  final QueueSourceItem? current;
  final QueueSourceItem? next;

  const QueueSlice(this.prev, this.current, this.next);
}

@Riverpod(keepAlive: true)
FutureOr<AudioControl> audioControlInit(AudioControlInitRef ref) async {
  final imageCache = ref.watch(imageCacheProvider);

  return AudioService.init(
    builder: () => AudioControl(AudioPlayer(), ref),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.subtracks2.channel.audio',
      androidNotificationChannelName: 'Music playback',
      androidNotificationIcon: 'drawable/ic_stat_name',
    ),
    cacheManager: imageCache,
    cacheKeyResolver: (mediaItem) =>
        mediaItem.data.artCache?.thumbnailArtCacheKey ?? '',
  );
}

@Riverpod(keepAlive: true)
AudioControl audioControl(AudioControlRef ref) {
  return ref.watch(audioControlInitProvider).requireValue;
}

class AudioControl extends BaseAudioHandler with QueueHandler, SeekHandler {
  static const radioLength = 10;

  Stream<Duration> get position => _player.positionStream;

  BehaviorSubject<QueueMode> queueMode = BehaviorSubject.seeded(QueueMode.user);
  BehaviorSubject<List<int>?> shuffleIndicies = BehaviorSubject.seeded(null);
  BehaviorSubject<AudioServiceRepeatMode> repeatMode =
      BehaviorSubject.seeded(AudioServiceRepeatMode.none);

  final Ref _ref;
  final AudioPlayer _player;

  int? _queueLength;
  int? _previousCurrentTrackIndex;

  final _syncPool = Pool(1);
  final _playLock = Lock();
  final _currentIndexIgnore = <int?>[null, 0];

  final ConcatenatingAudioSource _audioSource =
      ConcatenatingAudioSource(children: []);

  // Track the current discovery session for interactions
  int? _currentDiscoverySessionId;

  /// Get the current discovery session ID if playing a discovery station
  int? get currentDiscoverySessionId => _currentDiscoverySessionId;

  /// Get the current discovery station details if playing one
  Future<DiscoverySession?> getCurrentDiscoveryStation() async {
    if (_currentDiscoverySessionId == null) return null;
    return await _db.getDiscoverySessionById(_currentDiscoverySessionId!);
  }

  SubtracksDatabase get _db => _ref.read(databaseProvider);
  CacheService get _cache => _ref.read(cacheServiceProvider);
  MusicSource get _source {
    final source = _ref.read(musicSourceProvider);
    if (source == null) {
      throw StateError('No music source configured - cannot play audio');
    }
    return source;
  }
  int get _sourceId => _ref.read(sourceIdProvider);

  AudioControl(this._player, this._ref) {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        queueIndex: event.currentIndex,
      ));
    });

    _player.playbackEventStream.doOnError((e, st) async {
      log.warning('playbackEventStream error', e, st);

      // Check if error is related to YouTube URL expiry
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('403') ||
          errorString.contains('410') ||
          errorString.contains('forbidden') ||
          errorString.contains('gone')) {
        await _handlePotentialYouTubeUrlExpiry();
      }
    });

    shuffleIndicies.listen((value) {
      playbackState.add(playbackState.value.copyWith(
        shuffleMode: value != null
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
      ));
    });

    repeatMode.listen((value) {
      playbackState.add(playbackState.value.copyWith(repeatMode: value));
    });

    _player.processingStateStream.listen((event) async {
      if (event == ProcessingState.completed) {
        if (_audioSource.length > 0) {
          log.fine('completed');
          await stop();
          await seek(Duration.zero);
        }
      }
    });

    _ref.listen(sourceIdProvider, (_, __) async {
      await _clearAudioSource(true);
      await _db.clearQueue();
    });

    _ref.listen(maxBitrateProvider, (prev, next) async {
      if (prev?.valueOrNull != next.valueOrNull) {
        await _resyncQueue(true);
      }
    });

    _ref.listen(
        settingsServiceProvider.select((value) => value.app.streamFormat),
        (prev, next) async {
      await _resyncQueue(true);
    });

    _player.durationStream.listen((duration) {
      if (mediaItem.valueOrNull == null) return;

      final index = queue.valueOrNull?.indexOf(mediaItem.value!);

      final updated = mediaItem.value!.copyWith(duration: duration);
      mediaItem.add(updated);

      if (index != null) {
        queue.add(queue.value..replaceRange(index, index + 1, [updated]));
      }
    });

    _player.currentIndexStream.listen((index) async {
      if (_currentIndexIgnore.contains(index)) {
        _currentIndexIgnore.remove(index);
        return;
      }
      if (index == null || index >= _audioSource.sequence.length) return;

      final queueIndex = _audioSource.sequence[index].tag;
      if (queueIndex != null) {
        await _db.setCurrentTrack(queueIndex);
      }
    });

    _db.currentTrackIndex().watchSingleOrNull().listen((index) {
      // distict() except for when in loop one mode
      if (repeatMode.value != AudioServiceRepeatMode.one &&
          _previousCurrentTrackIndex == index) {
        return;
      }

      _previousCurrentTrackIndex = index;
      _syncPool.withResource(() => _syncQueue(index));
    });
  }

  Future<void> init() async {
    await _player.setAudioSource(_audioSource, preload: false);

    final last = await _db.getLastAudioState().getSingleOrNull();
    if (last == null) return;

    _queueLength = await _db.queueLength().getSingleOrNull();
    final repeat = {
      RepeatMode.none: AudioServiceRepeatMode.none,
      RepeatMode.all: AudioServiceRepeatMode.all,
      RepeatMode.one: AudioServiceRepeatMode.one,
    }[last.repeat]!;
    repeatMode.add(repeat);
    await repeatMode.firstWhere((e) => e == repeat);

    queueMode.add(last.queueMode);
    await queueMode.firstWhere((e) => e == last.queueMode);

    if (last.shuffleIndicies != null) {
      final indicies = last.shuffleIndicies!.unlock;
      shuffleIndicies.add(indicies);
      await shuffleIndicies.firstWhere((e) => e == indicies);
    }

    final startIndex = await _db.currentTrackIndex().getSingleOrNull();

    if (startIndex != null && _queueLength != null) {
      await _preparePlayer(startIndex);
    }
  }

  Future<void> playSongs({
    QueueMode mode = QueueMode.user,
    required QueueContextType context,
    String? contextId,
    required ListQuery query,
    required FutureOr<Iterable<Song>> Function(ListQuery query) getSongs,
    int? startIndex,
    bool? shuffle,
  }) async {
    if (!_playLock.locked) {
      return _playLock.synchronized(
        () => _playSongs(
          mode: mode,
          context: context,
          contextId: contextId,
          query: query,
          getSongs: getSongs,
          startIndex: startIndex,
          shuffle: shuffle,
        ),
      );
    }
  }

  Future<void> playRadio({
    required QueueContextType context,
    String? contextId,
    ListQuery query = const ListQuery(),
    required FutureOr<Iterable<Song>> Function(ListQuery query) getSongs,
  }) async {
    await playSongs(
      mode: QueueMode.radio,
      context: QueueContextType.library,
      contextId: contextId,
      query: query.copyWith(
        sort: SortBy(
          // Enhanced algorithm that prioritizes liked songs
          // Weight: thumbsUp=3x, unrated=1x, thumbsDown=0.1x probability
          column: '''
            CASE
              WHEN user_rating = 'thumbsUp' THEN SIN(songs.ROWID + ${Random().nextInt(3000)}) * 3.0
              WHEN user_rating = 'unrated' THEN SIN(songs.ROWID + ${Random().nextInt(10000)})
              WHEN user_rating = 'thumbsDown' THEN SIN(songs.ROWID + ${Random().nextInt(30000)}) * 0.1
              ELSE SIN(songs.ROWID + ${Random().nextInt(10000)})
            END
          ''',
        ),
        // Exclude thumbs down songs entirely - users don't want to hear them
        filters: IList([
          FilterWith.equals(column: 'user_rating', value: 'thumbsDown', invert: true),
        ]),
      ),
      getSongs: getSongs,
      startIndex: 0,
    );
  }

  /// Play Discovery Radio - intelligent recommendations based on a seed song
  Future<void> playDiscoveryRadio({
    required Song seedSong,
    DiscoveryMode mode = DiscoveryMode.online,
    int playlistSize = 50,
    int? sessionId,
  }) async {
    log.info('Starting Discovery Radio with seed: "${seedSong.title}" by ${seedSong.artist}');

    final discoveryService = _ref.read(discoveryServiceProvider.notifier);

    try {
      // Store the session ID for tracking interactions
      _currentDiscoverySessionId = sessionId;

      // Build the discovery playlist
      // Pass sessionId so we reuse existing stations instead of creating duplicates
      final playlist = await discoveryService.buildDiscoveryPlaylist(
        seedSong,
        includeOfflineOnly: !mode.isOnline,
        playlistSize: playlistSize,
        sessionId: sessionId, // Reuse existing session if provided
      );

      if (playlist.isEmpty) {
        log.warning('Discovery Radio: No songs found for playlist');
        return;
      }

      log.info('Discovery Radio: Generated playlist with ${playlist.length} songs');

      // Update session metadata before starting playback
      if (_currentDiscoverySessionId != null) {
        await _db.updateStationLastPlayed(
          _currentDiscoverySessionId!,
          DateTime.now(),
        );
        await _db.incrementStationPlayCount(_currentDiscoverySessionId!);
      }

      // Use the existing playSongs method with our discovery playlist
      // This will clear the queue and audio source automatically via _clearAudioSource
      await playSongs(
        mode: QueueMode.radio,
        context: QueueContextType.discovery,
        contextId: seedSong.id,
        query: const ListQuery(), // Not used since we provide getSongs directly
        getSongs: (query) => playlist,
        startIndex: 0,
      );

      log.info('Discovery Radio: Started playback successfully');
    } catch (e, stackTrace) {
      log.severe('Discovery Radio: Failed to start playback', e, stackTrace);

      // Fallback: play the seed song only
      await playSongs(
        mode: QueueMode.radio,
        context: QueueContextType.discovery,
        contextId: seedSong.id,
        query: const ListQuery(),
        getSongs: (query) => [seedSong],
        startIndex: 0,
      );
    }
  }

  /// Play Discovery Radio based on an artist
  Future<void> playDiscoveryRadioByArtist({
    required String artistId,
    DiscoveryMode mode = DiscoveryMode.online,
    int playlistSize = 50,
  }) async {
    final discoveryService = _ref.read(discoveryServiceProvider.notifier);

    try {
      final playlist = await discoveryService.getArtistSimilarSongs(
        artistId,
        sourceId: _sourceId,
        limit: playlistSize,
        mode: mode,
      );

      if (playlist.isEmpty) {
        log.warning('Discovery Radio: No songs found for artist $artistId');
        return;
      }

      await playSongs(
        mode: QueueMode.radio,
        context: QueueContextType.discovery,
        contextId: artistId,
        query: const ListQuery(),
        getSongs: (query) => playlist,
        startIndex: 0,
      );

      log.info('Discovery Radio: Started artist-based radio for $artistId with ${playlist.length} songs');
    } catch (e, stackTrace) {
      log.severe('Discovery Radio: Failed to start artist-based radio', e, stackTrace);
    }
  }

  /// Play Discovery Radio based on a genre
  Future<void> playDiscoveryRadioByGenre({
    required String genre,
    DiscoveryMode mode = DiscoveryMode.online,
    int playlistSize = 50,
  }) async {
    final discoveryService = _ref.read(discoveryServiceProvider.notifier);

    try {
      final playlist = await discoveryService.getGenreSimilarSongs(
        genre,
        sourceId: _sourceId,
        limit: playlistSize,
        mode: mode,
      );

      if (playlist.isEmpty) {
        log.warning('Discovery Radio: No songs found for genre $genre');
        return;
      }

      await playSongs(
        mode: QueueMode.radio,
        context: QueueContextType.discovery,
        contextId: genre,
        query: const ListQuery(),
        getSongs: (query) => playlist,
        startIndex: 0,
      );

      log.info('Discovery Radio: Started genre-based radio for $genre with ${playlist.length} songs');
    } catch (e, stackTrace) {
      log.severe('Discovery Radio: Failed to start genre-based radio', e, stackTrace);
    }
  }

  /// Play Hybrid Discovery Radio with YouTube integration
  ///
  /// This extends Discovery Radio to include YouTube tracks seamlessly
  /// blended with local tracks based on the configured ratio.
  Future<void> playHybridDiscoveryRadio({
    required Song seedSong,
    DiscoveryMode mode = DiscoveryMode.online,
    int playlistSize = 50,
    DiscoveryConfig config = const DiscoveryConfig(
      youtubeEnabled: true,
      youtubeRatio: 0.3, // 30% YouTube content by default
      youtubeQualityFilter: YouTubeQualityFilter.moderate,
      youtubePreferOfficial: true,
    ),
    int? sessionId,
  }) async {
    log.info('Starting Hybrid Discovery Radio with YouTube integration');
    log.fine('Seed: "${seedSong.title}" by ${seedSong.artist}');
    log.fine('YouTube enabled: ${config.youtubeEnabled}, ratio: ${config.youtubeRatio}');

    final discoveryService = _ref.read(discoveryServiceProvider.notifier);

    try {
      // Store session ID for tracking interactions
      _currentDiscoverySessionId = sessionId;

      // Build hybrid playlist (local + YouTube)
      final playlist = await discoveryService.buildHybridDiscoveryPlaylist(
        seedSong,
        includeOfflineOnly: !mode.isOnline,
        playlistSize: playlistSize,
        config: config,
        sessionId: sessionId,
      );

      if (playlist.isEmpty) {
        log.warning('Hybrid Discovery: No tracks found');
        return;
      }

      final localCount = playlist.where((t) => t.isLocal).length;
      final youtubeCount = playlist.where((t) => t.isYouTube).length;
      log.info('Hybrid Discovery: Generated ${playlist.length} tracks '
          '($localCount local, $youtubeCount YouTube)');

      // Convert HybridTracks to playable format
      await _playHybridTracks(
        tracks: playlist,
        mode: QueueMode.radio,
        context: QueueContextType.discovery,
        contextId: seedSong.id,
      );

      log.info('Hybrid Discovery: Started playback successfully');
    } catch (e, stackTrace) {
      log.severe('Hybrid Discovery: Failed to start playback', e, stackTrace);

      // Fallback: play the seed song only
      await playSongs(
        mode: QueueMode.radio,
        context: QueueContextType.discovery,
        contextId: seedSong.id,
        query: const ListQuery(),
        getSongs: (query) => [seedSong],
        startIndex: 0,
      );
    }
  }

  /// Internal method to play hybrid tracks
  ///
  /// Converts HybridTracks to Songs and uses existing playSongs infrastructure
  Future<void> _playHybridTracks({
    required List<HybridTrack> tracks,
    QueueMode mode = QueueMode.user,
    required QueueContextType context,
    String? contextId,
    int? startIndex,
  }) async {
    // Convert HybridTracks to Songs for queue
    final songs = await _convertHybridTracksToSongs(tracks);

    if (songs.isEmpty) {
      log.warning('No playable songs after HybridTrack conversion');
      return;
    }

    log.fine('Converted ${tracks.length} HybridTracks to ${songs.length} playable Songs');

    // Use existing playSongs() method
    await playSongs(
      mode: mode,
      context: context,
      contextId: contextId,
      query: const ListQuery(),
      getSongs: (query) => songs,
      startIndex: startIndex ?? 0,
    );
  }

  /// Convert HybridTracks to Songs for playback
  ///
  /// For local tracks: returns the Song as-is
  /// For YouTube tracks: creates a temporary Song with the cached stream URL
  Future<List<Song>> _convertHybridTracksToSongs(List<HybridTrack> tracks) async {
    final songs = <Song>[];
    final youtubeCache = _ref.read(youTubeCacheServiceProvider.notifier);

    for (final track in tracks) {
      await track.when(
        local: (song) async {
          songs.add(song);
        },
        youtube: (videoId, title, artist, durationSeconds, thumbnailUrl, userRating) async {
          try {
            // IMPORTANT: Fetch and cache the YouTube track first before attempting playback
            // This ensures we have a fresh stream URL available
            log.fine('Fetching audio stream for playback: $videoId');
            final cachedTrack = await _fetchAndCacheYouTubeTrack(
              videoId,
              title,
              artist,
              durationSeconds,
              thumbnailUrl ?? '',
            );

            if (cachedTrack != null) {
              // Create a Song-like object that AudioService can play
              // We use a special ID prefix 'youtube:' to identify YouTube tracks
              // The audio URL is stored in the 'album' field (temporary workaround)
              final youtubeSong = Song(
                sourceId: _sourceId,
                id: 'youtube:$videoId',
                title: title,
                artist: artist,
                album: cachedTrack.audioUrl, // Store URL here temporarily
                duration: Duration(seconds: durationSeconds),
                userRating: userRating,
              );
              songs.add(youtubeSong);

              log.fine('Cached and converted YouTube track: $videoId');
            } else {
              log.warning('Failed to cache YouTube track for playback: $videoId');
            }
          } catch (e) {
            log.warning('Error caching/converting YouTube track $videoId: $e');
          }
        },
      );
    }

    return songs;
  }

  /// Fetch and cache a YouTube track for playback
  ///
  /// This helper method fetches the audio stream from YouTube API and caches it
  /// Returns the cached track with a fresh stream URL, or null if fetch fails
  Future<YoutubeTrack?> _fetchAndCacheYouTubeTrack(
    String videoId,
    String title,
    String artist,
    int durationSeconds,
    String thumbnailUrl,
  ) async {
    try {
      final youtubeCache = _ref.read(youTubeCacheServiceProvider.notifier);
      final youtubeService = _ref.read(youTubeDiscoveryServiceProvider.notifier);

      // Check if already cached and valid
      final existingTrack = await youtubeCache.getTrack(videoId, refreshIfExpired: true);
      if (existingTrack != null) {
        log.fine('Using cached track: $videoId');
        return existingTrack;
      }

      // Fetch audio stream from API
      log.fine('Fetching fresh audio stream from API: $videoId');
      final audioStream = await youtubeService.getAudioStream(videoId);

      if (audioStream == null) {
        log.warning('Failed to fetch audio stream: $videoId');
        return null;
      }

      // Create search result object for caching
      final searchResult = YouTubeSearchResult(
        videoId: videoId,
        title: title,
        author: artist,
        lengthSeconds: durationSeconds,
        thumbnail: thumbnailUrl,
      );

      // Cache the track
      await youtubeCache.cacheTrack(searchResult, audioStream);

      // Get the cached track
      final cachedTrack = await youtubeCache.getTrack(videoId);

      if (cachedTrack == null) {
        log.warning('Track was cached but not found: $videoId');
        return null;
      }

      log.fine('Successfully cached YouTube track: $videoId');
      return cachedTrack;
    } catch (e, stackTrace) {
      log.severe('Error fetching and caching YouTube track: $videoId', e, stackTrace);
      return null;
    }
  }

  Future<void> _playSongs({
    QueueMode mode = QueueMode.user,
    required QueueContextType context,
    String? contextId,
    required ListQuery query,
    required FutureOr<Iterable<Song>> Function(ListQuery query) getSongs,
    int? startIndex,
    bool? shuffle,
  }) async {
    shuffle = shuffle ?? shuffleIndicies.valueOrNull != null;
    queueMode.add(mode);

    // Add filter to exclude thumbs down songs for all playback modes
    // Users don't want to hear songs they've given thumbs down
    query = query.copyWith(
      filters: IList([
        ...query.filters,
        FilterWith.equals(column: 'user_rating', value: 'thumbsDown', invert: true),
      ]),
    );

    if (mode == QueueMode.radio) {
      if (repeatMode.value != AudioServiceRepeatMode.none) {
        await _loop(AudioServiceRepeatMode.none);
      }
      if (shuffleIndicies.value != null) {
        await _shuffle(unshuffle: true);
      }
    }

    await _clearAudioSource();

    const limit = 500;
    _queueLength = 0;

    if ((startIndex == null || startIndex >= limit) && shuffle) {
      startIndex = Random().nextInt(limit);
    } else {
      startIndex ??= 0;
    }

    // clear the queue and load the initial songs only up to the startIndex
    await _db.transaction(() async {
      await _db.clearQueue();

      while (_queueLength! <= startIndex!) {
        final songs = await getSongs(query.copyWith(
          page: Pagination(limit: limit, offset: _queueLength!),
        ));
        await _loadQueueSongs(songs, _queueLength!, context, contextId);
        if (songs.length < limit) {
          break;
        }
      }
    });

    // if there are less songs than the limit and we're shuffling,
    // choose a new random startIndex
    if (startIndex >= _queueLength!) {
      startIndex = Random().nextInt(_queueLength!);
    }

    await _preparePlayer(startIndex, shuffle);
    await _db.setCurrentTrack(startIndex);
    play();

    const maxLength = 10000;

    // no need to do extra loading if we've already loaded everything
    if (_queueLength! < limit) return;
    while (true) {
      final songs = await getSongs(query.copyWith(
        page: Pagination(limit: limit, offset: _queueLength!),
      ));
      await _loadQueueSongs(songs, _queueLength!, context, contextId);
      if (songs.length < limit || _queueLength! >= maxLength) {
        break;
      }
    }
  }

  Future<void> _loadQueueSongs(
    Iterable<Song> songs,
    int total,
    QueueContextType context,
    String? contextId,
  ) async {
    await _db.insertQueue(songs.mapIndexed(
      (i, song) => QueueCompanion.insert(
        index: Value(i + (_queueLength ?? 0)),
        sourceId: song.sourceId,
        id: song.id,
        context: context,
        contextId: Value(contextId),
      ),
    ));

    _queueLength = (_queueLength ?? 0) + songs.length;
    if (shuffleIndicies.valueOrNull != null) {
      await _generateShuffleIndicies(startIndex: _player.currentIndex);
    }
  }

  Future<void> _preparePlayer(int startIndex, [bool? shuffle]) async {
    if (shuffle == true) {
      await _shuffle(startIndex: startIndex);
    } else if (shuffle == false) {
      await _shuffle(unshuffle: true);
    }

    final slice = await _getQueueSlice(startIndex);
    if (slice == null) {
      throw StateError('Could not get queue slice!');
    }

    final list =
        [slice.prev, slice.current, slice.next].whereNotNull().toList();

    mediaItem.add(slice.current!.mediaItem);
    queue.add(list.map((e) => e.mediaItem).toList());

    log.fine('addAll');
    await _audioSource.addAll(list.map((e) => e.audioSource).toList());
    await _player.seek(Duration.zero, index: list.indexOf(slice.current!));
  }

  Future<void> _syncQueue(int? index) async {
    if (index == null || _queueLength == null) return;

    final slice = await _getQueueSlice(index);
    if (slice == null || slice.current == null) return;

    mediaItem.add(slice.current!.mediaItem);
    queue.add(
      [slice.prev, slice.current, slice.next]
          .map((e) => e?.mediaItem)
          .whereNotNull()
          .toList(),
    );

    final sourceIndex = _player.currentIndex;
    final sourceNeedsNext = sourceIndex == _audioSource.length - 1;
    final sourceNeedsPrev = sourceIndex == 0;

    if (sourceNeedsNext && slice.next != null) {
      log.fine('add');
      await _audioSource.add(slice.next!.audioSource);
    }
    if (sourceNeedsPrev && slice.prev != null) {
      await _insertFirstAudioSource(slice.prev!.audioSource);
    }
  }

  Future<void> _loop(AudioServiceRepeatMode mode) async {
    repeatMode.add(mode);
    await repeatMode.firstWhere((e) => e == mode);

    await _resyncQueue();
  }

  Future<void> _generateShuffleIndicies({
    bool unshuffle = false,
    int? startIndex,
  }) async {
    final indicies = unshuffle
        ? null
        : (List.generate(_queueLength!, (i) => i + 1)
          ..insert(0, 0)
          ..removeLast()
          ..shuffle());

    if (indicies != null && startIndex != null) {
      indicies.removeAt(indicies.indexOf(startIndex));
      indicies.insert(0, startIndex);
    }
    shuffleIndicies.add(indicies);
    await shuffleIndicies.firstWhere((e) => e == indicies);
  }

  Future<void> _shuffle({bool unshuffle = false, int? startIndex}) async {
    await _generateShuffleIndicies(
      unshuffle: unshuffle,
      startIndex: startIndex,
    );

    await _resyncQueue();
  }

  Future<void> _resyncQueue([bool reloadCurrent = false]) async {
    return _syncPool.withResource(() async {
      final currentSource =
          _player.sequenceState?.currentSource as UriAudioSource?;
      if (currentSource == null) return;

      final currentSourceIndex = _player.sequence!.indexOf(currentSource);
      await _pruneAudioSources(currentSourceIndex);

      if (reloadCurrent && !currentSource.uri.isScheme('file')) {
        final position = _player.position;

        final item = (await _getQueueItems([currentSource.tag]))[0];

        await _audioSource.clear();
        await _audioSource.add(item.audioSource);
        await seek(position);
      }

      await _syncQueue(currentSource.tag);
    });
  }

  int _realIndex(int index) {
    if (shuffleIndicies.valueOrNull == null) {
      return index;
    }

    if (index < 0 || index >= shuffleIndicies.value!.length) {
      return -1;
    }

    return shuffleIndicies.value![index];
  }

  int _effectiveIndex(int index) {
    if (shuffleIndicies.valueOrNull == null) {
      return index;
    }

    return shuffleIndicies.value!.indexOf(index);
  }

  Future<void> _insertFirstAudioSource(AudioSource source) {
    log.fine('insert');
    final wait = _audioSource.insert(0, source);
    _currentIndexIgnore.add(1);
    return wait;
  }

  Future<void> _pruneAudioSources(int keepIndex) async {
    if (keepIndex > 0) {
      log.fine('removeRange 0');
      final wait = _audioSource.removeRange(0, keepIndex);
      _currentIndexIgnore.add(0);
      await wait;
    }
    if (_audioSource.length > 1) {
      log.fine('removeRange 1');
      await _audioSource.removeRange(1, _audioSource.length);
    }
  }

  Future<void> _clearAudioSource([bool clearMetadata = false]) async {
    // await _player.stop();
    log.fine('_clearAudioSource');
    await _audioSource.clear();

    if (clearMetadata) {
      mediaItem.add(null);
      queue.add([]);
      queueTitle.add('');
      // Clear discovery session when clearing metadata
      _currentDiscoverySessionId = null;
    }
  }

  Future<QueueSlice?> _getQueueSlice(int index) async {
    if (_queueLength == null) {
      return null;
    }

    final effectiveIndex = _effectiveIndex(index);

    int nextIndex;
    int prevIndex;
    if (repeatMode.value == AudioServiceRepeatMode.none) {
      nextIndex = _realIndex(effectiveIndex + 1);
      prevIndex = _realIndex(effectiveIndex - 1);
    } else if (repeatMode.value == AudioServiceRepeatMode.one) {
      nextIndex = index;
      prevIndex = index;
    } else {
      nextIndex = _realIndex(
        effectiveIndex + 1 >= _queueLength! ? 0 : effectiveIndex + 1,
      );
      prevIndex = _realIndex(
        effectiveIndex - 1 < 0 ? _queueLength! - 1 : effectiveIndex - 1,
      );
    }

    final slice = await _getQueueItems([prevIndex, index, nextIndex]);
    final current = slice.firstWhereOrNull(
      (e) => e.queueData.index == index,
    );
    final next = slice.firstWhereOrNull((e) => e.queueData.index == nextIndex);
    final prev = slice.firstWhereOrNull((e) => e.queueData.index == prevIndex);

    return QueueSlice(prev, current, next);
  }

  Future<List<QueueSourceItem>> _getQueueItems(List<int> indexes) async {
    final slice = await _db.queueInIndicies(indexes).get();

    // Separate YouTube and local track IDs
    final localIds = <String>[];
    final youtubeIds = <String>[];

    for (final item in slice) {
      if (item.id.startsWith('youtube:')) {
        youtubeIds.add(item.id);
      } else {
        localIds.add(item.id);
      }
    }

    // Fetch local songs from database
    final localSongs = localIds.isNotEmpty
        ? await _db.songsInIds(_sourceId, localIds).get()
        : <Song>[];

    // Reconstruct YouTube songs from cache
    final youtubeSongs = <Song>[];
    final youtubeCache = _ref.read(youTubeCacheServiceProvider.notifier);

    for (final youtubeId in youtubeIds) {
      try {
        final videoId = youtubeId.replaceFirst('youtube:', '');

        // IMPORTANT: Check if YouTube URL needs refreshing before playback
        // YouTube stream URLs expire quickly (typically 5-6 hours)
        // Only refresh if URL is expired or expiring soon
        log.fine('Fetching YouTube track for playback: $videoId');

        // First try to get from cache without forcing refresh
        var cachedTrack = await youtubeCache.getTrack(videoId, refreshIfExpired: false);

        // Check if we need to refresh
        final needsRefresh = cachedTrack == null || _isYouTubeUrlExpired(cachedTrack);

        if (needsRefresh) {
          log.info('YouTube URL needs refresh for: $videoId');
          cachedTrack = await youtubeCache.refreshTrackUrl(videoId);
        } else {
          log.fine('Using cached YouTube URL for: $videoId (valid for ${_getYouTubeUrlTimeLeft(cachedTrack)} more minutes)');
        }

        if (cachedTrack != null) {
          // Reconstruct Song from cached YouTube track with fresh URL
          final youtubeSong = Song(
            sourceId: _sourceId,
            id: youtubeId,
            title: cachedTrack.title,
            artist: cachedTrack.artist,
            album: cachedTrack.audioUrl, // Store fresh URL in album field
            duration: Duration(seconds: cachedTrack.durationSeconds),
            userRating: UserRating.unrated,
          );
          youtubeSongs.add(youtubeSong);

          // Enhanced logging with expiry information
          final expiryTime = DateTime.fromMillisecondsSinceEpoch(cachedTrack.expiresAt * 1000);
          final timeUntilExpiry = expiryTime.difference(DateTime.now());
          log.info('Fresh URL obtained for video: $videoId (expires in ${timeUntilExpiry.inMinutes} minutes at $expiryTime)');
          log.fine('Audio URL: ${cachedTrack.audioUrl.substring(0, 100)}...');
        } else {
          log.severe('CRITICAL: Failed to refresh YouTube URL for playback: $youtubeId - track will be skipped');
        }
      } catch (e) {
        log.warning('Error refreshing YouTube URL for playback: $youtubeId', e);
      }
    }

    // Combine local and YouTube songs
    final allSongs = [...localSongs, ...youtubeSongs];
    final songMap = {for (var song in allSongs) song.id: song};

    // Get album art only for local songs
    final albumIds = localSongs.map((e) => e.albumId).whereNotNull().toSet();
    final albums = await _db.albumsInIds(_sourceId, albumIds.toList()).get();
    final albumArtMap = {
      for (var album in albums) album.id: _mapArtCache(album)
    };

    final queueItems = slice.map(
      (item) {
        final song = songMap[item.id];
        if (song == null) {
          log.warning('Song not found in map: ${item.id}');
          return null;
        }

        return _mapSong(
          song,
          MediaItemData(
            sourceId: item.sourceId,
            contextType: item.context,
            contextId: item.contextId,
            artCache: albumArtMap[song.albumId],
          ),
          item,
        );
      },
    ).whereNotNull();

    return queueItems.toList();
  }

  QueueSourceItem _mapSong(Song song, MediaItemData data, QueueData queueData) {
    final item = MediaItem(
      id: song.id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: song.duration,
      artUri: data.artCache?.thumbnailArtUri ?? _cache.placeholderThumbImageUri,
      extras: {
        'isYouTube': song.id.startsWith('youtube:'),
      },
    );
    item.data = data;

    // Determine audio source based on song type
    UriAudioSource audioSource;

    if (song.downloadFilePath != null) {
      // Local downloaded file
      audioSource = AudioSource.file(song.downloadFilePath!, tag: queueData.index);
    } else if (song.id.startsWith('youtube:')) {
      // YouTube track - extract URL from album field (temporary storage)
      // The album field is repurposed to store the YouTube stream URL
      final youtubeUrl = song.album; // URL stored temporarily in album field
      if (youtubeUrl != null && youtubeUrl.startsWith('http')) {
        // Log the URL being used for debugging
        final videoId = song.id.replaceFirst('youtube:', '');
        log.info('Creating AudioSource for YouTube video $videoId');
        log.fine('Stream URL: $youtubeUrl');

        // Add comprehensive headers that Google/YouTube expects
        // These headers help prevent 403 Forbidden errors
        audioSource = AudioSource.uri(
          Uri.parse(youtubeUrl),
          tag: queueData.index,
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': '*/*',
            'Accept-Language': 'en-US,en;q=0.9',
            'Accept-Encoding': 'identity',
            'Origin': 'https://www.youtube.com',
            'Referer': 'https://www.youtube.com/watch?v=$videoId',
            'Range': 'bytes=0-',
          },
        );
        log.fine('AudioSource created with headers: Referer=https://www.youtube.com/watch?v=$videoId');
      } else {
        // Fallback to Navidrome stream (shouldn't happen)
        log.warning('YouTube track has no valid stream URL: ${song.id}');
        audioSource = AudioSource.uri(_source.streamUri(song.id), tag: queueData.index);
      }
    } else {
      // Navidrome stream
      audioSource = AudioSource.uri(_source.streamUri(song.id), tag: queueData.index);
    }

    return QueueSourceItem(
      mediaItem: item,
      audioSource: audioSource,
      queueData: queueData,
    );
  }

  MediaItemArtCache _mapArtCache(Album album) {
    final full = _cache.albumArt(album, thumbnail: false);
    final thumbnail = _cache.albumArt(album, thumbnail: true);
    return MediaItemArtCache(
      fullArtUri: full.uri,
      fullArtCacheKey: full.cacheKey,
      thumbnailArtUri: thumbnail.uri,
      thumbnailArtCacheKey: thumbnail.cacheKey,
    );
  }

  ///
  /// AudioHandler
  ///

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> skipToQueueItem(int index) async {
    if (_player.effectiveIndices == null || _player.effectiveIndices!.isEmpty) {
      return;
    }

    index = _player.effectiveIndices![index];
    if (index < 0 || index >= queue.value.length) {
      return;
    }

    await _player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    if (queueMode.value == QueueMode.radio) {
      switch (repeatMode) {
        case AudioServiceRepeatMode.all:
        case AudioServiceRepeatMode.group:
        case AudioServiceRepeatMode.one:
          return _loop(AudioServiceRepeatMode.one);
        default:
          return _loop(AudioServiceRepeatMode.none);
      }
    }

    return _loop(repeatMode);
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    if (queueMode.value == QueueMode.radio) {
      return;
    }

    switch (shuffleMode) {
      case AudioServiceShuffleMode.all:
      case AudioServiceShuffleMode.group:
        return _shuffle(startIndex: _player.sequenceState?.currentSource?.tag);
      case AudioServiceShuffleMode.none:
        return _shuffle(unshuffle: true);
    }
  }

  /// Save the current discovery radio station with a name
  Future<void> saveCurrentDiscoveryStation(String stationName) async {
    if (_currentDiscoverySessionId == null) {
      throw StateError('No active discovery session to save');
    }

    try {
      await _db.updateStationName(_currentDiscoverySessionId!, stationName);
      log.info('Discovery station saved: "$stationName" (session ID: $_currentDiscoverySessionId)');
    } catch (e, stackTrace) {
      log.severe('Failed to save discovery station', e, stackTrace);
      rethrow;
    }
  }

  /// Handle potential YouTube URL expiry during playback
  ///
  /// Checks if the current track is a YouTube track and refreshes its URL if needed
  Future<void> _handlePotentialYouTubeUrlExpiry() async {
    try {
      final currentItem = mediaItem.valueOrNull;
      if (currentItem == null) return;

      // Check if this is a YouTube track
      final isYouTube = currentItem.extras?['isYouTube'] == true;
      if (!isYouTube) return;

      log.info('YouTube URL may be expired, attempting refresh...');

      // Extract video ID from the song ID
      final videoId = currentItem.id.replaceFirst('youtube:', '');

      // Refresh the URL
      await _refreshYouTubeUrl(videoId);
    } catch (e, stackTrace) {
      log.severe('Error handling YouTube URL expiry', e, stackTrace);
    }
  }

  /// Refresh the YouTube URL for a specific video
  ///
  /// Fetches a fresh stream URL and reloads the audio source
  Future<void> _refreshYouTubeUrl(String videoId) async {
    try {
      log.info('Refreshing YouTube URL for video: $videoId');

      final youtubeCache = _ref.read(youTubeCacheServiceProvider.notifier);

      // Force refresh the URL
      final refreshedTrack = await youtubeCache.refreshTrackUrl(videoId);

      if (refreshedTrack == null) {
        log.warning('Failed to refresh YouTube URL: $videoId');
        // Skip to next track if refresh fails
        await skipToNext();
        return;
      }

      log.info('YouTube URL refreshed successfully: $videoId');

      // Reload the current track with the new URL
      await _resyncQueue(true);

      log.info('Audio source reloaded with fresh URL');
    } catch (e, stackTrace) {
      log.severe('Failed to refresh YouTube URL: $videoId', e, stackTrace);

      // Skip to next track on persistent error
      try {
        await skipToNext();
      } catch (skipError) {
        log.severe('Failed to skip to next track', skipError);
      }
    }
  }

  /// Check if YouTube URL is expired or expiring soon (< 5 minutes)
  bool _isYouTubeUrlExpired(YoutubeTrack track) {
    final expiryTime = DateTime.fromMillisecondsSinceEpoch(track.expiresAt * 1000);
    final timeLeft = expiryTime.difference(DateTime.now());
    return timeLeft < const Duration(minutes: 5);
  }

  /// Get time left before YouTube URL expires (in minutes)
  int _getYouTubeUrlTimeLeft(YoutubeTrack track) {
    final expiryTime = DateTime.fromMillisecondsSinceEpoch(track.expiresAt * 1000);
    final timeLeft = expiryTime.difference(DateTime.now());
    return timeLeft.inMinutes;
  }

}
