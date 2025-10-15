import 'dart:math';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/database.dart';
import '../log.dart';
import '../models/hybrid_track.dart';
import '../models/music.dart';
import 'youtube_cache_service.dart';
import 'youtube_discovery_service.dart';

part 'discovery_service.g.dart';

/// Represents different discovery modes for recommendation generation
enum DiscoveryMode {
  /// Recommend from all available songs (online and downloaded)
  online(isOnline: true),
  /// Recommend only from downloaded songs
  offline(isOnline: false);

  const DiscoveryMode({required this.isOnline});
  final bool isOnline;
}

/// Quality filter level for YouTube content
enum YouTubeQualityFilter {
  /// Very strict: only official channels, VEVO, topic channels
  strict,
  /// Moderate: allow some high-quality user uploads
  moderate,
  /// Permissive: allow most music content
  permissive,
}

/// Configuration for discovery algorithms
class DiscoveryConfig {
  final int maxRecommendations;
  final double artistSimilarityWeight;
  final double genreSimilarityWeight;
  final double userPreferenceWeight;
  final double metadataCorrelationWeight;
  final bool avoidRecentlyPlayed;
  final Duration recentPlayedWindow;

  // YouTube discovery settings
  final bool youtubeEnabled;
  final double youtubeRatio;
  final YouTubeQualityFilter youtubeQualityFilter;
  final bool youtubePreferOfficial;

  const DiscoveryConfig({
    this.maxRecommendations = 50,
    this.artistSimilarityWeight = 0.35,
    this.genreSimilarityWeight = 0.25,
    this.userPreferenceWeight = 0.30,
    this.metadataCorrelationWeight = 0.10,
    this.avoidRecentlyPlayed = true,
    this.recentPlayedWindow = const Duration(hours: 2),
    // YouTube settings - disabled by default due to unreliable Invidious instances
    this.youtubeEnabled = false, // Set to true in user settings if Invidious works
    this.youtubeRatio = 0.3, // 30% YouTube content
    this.youtubeQualityFilter = YouTubeQualityFilter.strict,
    this.youtubePreferOfficial = true,
  });

  /// Ensure all weights sum to 1.0
  DiscoveryConfig get normalized {
    final totalWeight = artistSimilarityWeight +
                      genreSimilarityWeight +
                      userPreferenceWeight +
                      metadataCorrelationWeight;

    if (totalWeight == 0) return this;

    return DiscoveryConfig(
      maxRecommendations: maxRecommendations,
      artistSimilarityWeight: artistSimilarityWeight / totalWeight,
      genreSimilarityWeight: genreSimilarityWeight / totalWeight,
      userPreferenceWeight: userPreferenceWeight / totalWeight,
      metadataCorrelationWeight: metadataCorrelationWeight / totalWeight,
      avoidRecentlyPlayed: avoidRecentlyPlayed,
      recentPlayedWindow: recentPlayedWindow,
      youtubeEnabled: youtubeEnabled,
      youtubeRatio: youtubeRatio,
      youtubeQualityFilter: youtubeQualityFilter,
      youtubePreferOfficial: youtubePreferOfficial,
    );
  }

  /// Copy with method for updating config
  DiscoveryConfig copyWith({
    int? maxRecommendations,
    double? artistSimilarityWeight,
    double? genreSimilarityWeight,
    double? userPreferenceWeight,
    double? metadataCorrelationWeight,
    bool? avoidRecentlyPlayed,
    Duration? recentPlayedWindow,
    bool? youtubeEnabled,
    double? youtubeRatio,
    YouTubeQualityFilter? youtubeQualityFilter,
    bool? youtubePreferOfficial,
  }) {
    return DiscoveryConfig(
      maxRecommendations: maxRecommendations ?? this.maxRecommendations,
      artistSimilarityWeight: artistSimilarityWeight ?? this.artistSimilarityWeight,
      genreSimilarityWeight: genreSimilarityWeight ?? this.genreSimilarityWeight,
      userPreferenceWeight: userPreferenceWeight ?? this.userPreferenceWeight,
      metadataCorrelationWeight: metadataCorrelationWeight ?? this.metadataCorrelationWeight,
      avoidRecentlyPlayed: avoidRecentlyPlayed ?? this.avoidRecentlyPlayed,
      recentPlayedWindow: recentPlayedWindow ?? this.recentPlayedWindow,
      youtubeEnabled: youtubeEnabled ?? this.youtubeEnabled,
      youtubeRatio: youtubeRatio ?? this.youtubeRatio,
      youtubeQualityFilter: youtubeQualityFilter ?? this.youtubeQualityFilter,
      youtubePreferOfficial: youtubePreferOfficial ?? this.youtubePreferOfficial,
    );
  }
}

/// Weighted song recommendation with scoring information
class WeightedSong {
  final Song song;
  final double score;
  final Map<String, double> scoreBreakdown;

  const WeightedSong({
    required this.song,
    required this.score,
    required this.scoreBreakdown,
  });

  @override
  String toString() => 'WeightedSong(${song.title} by ${song.artist}, score: ${score.toStringAsFixed(3)})';
}

@Riverpod(keepAlive: true)
class DiscoveryService extends _$DiscoveryService {
  SubtracksDatabase get _db => ref.read(databaseProvider);

  /// Cache for genre relationships to avoid repeated calculations
  final Map<String, Set<String>> _genreRelationshipCache = {};

  /// Cache for artist similarity scores
  final Map<String, Map<String, double>> _artistSimilarityCache = {};

  /// Track current discovery session for interaction logging
  int? _currentSessionId;

  @override
  void build() {
    // Service is stateless - no initial state needed
  }

  /// Generate similar songs based on a seed song using multiple algorithms
  Future<List<Song>> generateSimilarSongs(
    Song seedSong, {
    int limit = 50,
    DiscoveryMode mode = DiscoveryMode.online,
    DiscoveryConfig config = const DiscoveryConfig(),
    int? sessionId,
  }) async {
    try {
      log.info('Generating ${limit} similar songs for "${seedSong.title}" by ${seedSong.artist}');

      final normalizedConfig = config.normalized;
      final candidates = <WeightedSong>[];

      // Get station-specific interaction history for personalization
      Set<String> thumbsUpSongIds = {};
      Set<String> thumbsDownSongIds = {};
      Set<String> frequentlySkippedSongIds = {};

      if (sessionId != null) {
        thumbsUpSongIds = await _db.getThumbsUpSongsForStation(sessionId);
        thumbsDownSongIds = await _db.getThumbsDownSongsForStation(sessionId);
        frequentlySkippedSongIds = await _db.getFrequentlySkippedSongsForStation(sessionId);

        log.fine('Station personalization: ${thumbsUpSongIds.length} thumbs up, ${thumbsDownSongIds.length} thumbs down, ${frequentlySkippedSongIds.length} frequently skipped');
      }

      // Get base song pool (filtered by discovery mode)
      final allSongs = await _getSongPool(seedSong.sourceId, mode);

      // Remove the seed song from candidates
      final filteredSongs = allSongs.where((song) => song.id != seedSong.id).toList();

      // Get full song objects for thumbs up songs to use in similarity calculations
      final thumbsUpSongs = filteredSongs.where((song) => thumbsUpSongIds.contains(song.id)).toList();

      log.fine('Found ${filteredSongs.length} candidate songs for recommendations');

      // Apply different recommendation strategies
      for (final song in filteredSongs) {
        // STATION-SPECIFIC FILTERING: Exclude thumbs down and frequently skipped songs
        if (thumbsDownSongIds.contains(song.id) || frequentlySkippedSongIds.contains(song.id)) {
          continue; // Skip this song entirely
        }

        final scores = <String, double>{};

        // Artist similarity scoring
        scores['artist'] = await _calculateArtistSimilarity(seedSong, song) * normalizedConfig.artistSimilarityWeight;

        // Genre similarity scoring
        scores['genre'] = await _calculateGenreSimilarity(seedSong, song) * normalizedConfig.genreSimilarityWeight;

        // User preference scoring (global rating)
        scores['preference'] = _calculateUserPreference(song) * normalizedConfig.userPreferenceWeight;

        // Metadata correlation scoring
        scores['metadata'] = _calculateMetadataCorrelation(seedSong, song) * normalizedConfig.metadataCorrelationWeight;

        // STATION-SPECIFIC PERSONALIZATION: Boost songs similar to thumbs up songs
        double stationBoost = 0.0;
        if (thumbsUpSongs.isNotEmpty) {
          double maxSimilarity = 0.0;
          for (final likedSong in thumbsUpSongs) {
            final similarity = await _calculateSongSimilarity(likedSong, song);
            maxSimilarity = maxSimilarity > similarity ? maxSimilarity : similarity;
          }
          // Apply boost based on similarity to liked songs (up to 50% boost)
          stationBoost = maxSimilarity * 0.5;
        }

        final totalScore = scores.values.sum + stationBoost;

        // Only include songs with meaningful scores
        if (totalScore > 0.1) {
          candidates.add(WeightedSong(
            song: song,
            score: totalScore,
            scoreBreakdown: {...scores, 'station_boost': stationBoost},
          ));
        }
      }

      // Sort by score and apply randomization within score bands
      candidates.sort((a, b) => b.score.compareTo(a.score));

      // Apply smart sampling to balance quality with diversity
      final recommendations = _applySmartSampling(candidates, limit);

      log.info('Generated ${recommendations.length} recommendations from ${candidates.length} candidates');

      return recommendations.map((w) => w.song).toList();
    } catch (e, stackTrace) {
      log.severe('Error generating similar songs', e, stackTrace);
      return [];
    }
  }

  /// Get songs similar to a specific artist
  Future<List<Song>> getArtistSimilarSongs(
    String artistId, {
    int sourceId = 1,
    int limit = 50,
    DiscoveryMode mode = DiscoveryMode.online,
  }) async {
    try {
      // Get all songs by this artist first
      final artistSongs = await _db.filterSongs(
        (tbl) => tbl.sourceId.equals(sourceId) &
                 tbl.artistId.equals(artistId) &
                 tbl.userRating.equalsValue(UserRating.thumbsDown).not() &
                 (mode.isOnline ? const Constant(true) : tbl.downloadFilePath.isNotNull()),
        (tbl) => OrderBy([OrderingTerm(expression: const CustomExpression('RANDOM()'))]),
        (tbl) => Limit(5, null),
      ).get();

      if (artistSongs.isEmpty) return [];

      // Use the most popular/liked song as seed
      final seedSong = artistSongs.firstWhere(
        (song) => song.userRating == UserRating.thumbsUp,
        orElse: () => artistSongs.first,
      );

      return generateSimilarSongs(
        seedSong,
        limit: limit,
        mode: mode,
        config: const DiscoveryConfig(
          artistSimilarityWeight: 0.50, // Higher weight for artist similarity
          genreSimilarityWeight: 0.30,
          userPreferenceWeight: 0.15,
          metadataCorrelationWeight: 0.05,
        ),
      );
    } catch (e, stackTrace) {
      log.severe('Error getting artist similar songs', e, stackTrace);
      return [];
    }
  }

  /// Get songs similar to a specific genre
  Future<List<Song>> getGenreSimilarSongs(
    String genre, {
    int sourceId = 1,
    int limit = 50,
    DiscoveryMode mode = DiscoveryMode.online,
  }) async {
    try {
      // Get songs from the same genre first
      final genreSongs = await _db.filterSongs(
        (tbl) => tbl.sourceId.equals(sourceId) &
                 tbl.genre.equals(genre) &
                 tbl.userRating.equalsValue(UserRating.thumbsDown).not() &
                 (mode.isOnline ? const Constant(true) : tbl.downloadFilePath.isNotNull()),
        (tbl) => OrderBy([OrderingTerm(expression: const CustomExpression('RANDOM()'))]),
        (tbl) => Limit(10, null),
      ).get();

      if (genreSongs.isEmpty) return [];

      // Use a liked song as seed, or random if none liked
      final seedSong = genreSongs.firstWhere(
        (song) => song.userRating == UserRating.thumbsUp,
        orElse: () => genreSongs.first,
      );

      return generateSimilarSongs(
        seedSong,
        limit: limit,
        mode: mode,
        config: const DiscoveryConfig(
          artistSimilarityWeight: 0.20,
          genreSimilarityWeight: 0.50, // Higher weight for genre similarity
          userPreferenceWeight: 0.20,
          metadataCorrelationWeight: 0.10,
        ),
      );
    } catch (e, stackTrace) {
      log.severe('Error getting genre similar songs', e, stackTrace);
      return [];
    }
  }

  /// Get songs weighted by user preferences
  Future<List<Song>> getUserPreferenceWeightedSongs(
    Song seedSong, {
    int limit = 50,
    DiscoveryMode mode = DiscoveryMode.online,
  }) async {
    return generateSimilarSongs(
      seedSong,
      limit: limit,
      mode: mode,
      config: const DiscoveryConfig(
        artistSimilarityWeight: 0.15,
        genreSimilarityWeight: 0.15,
        userPreferenceWeight: 0.60, // Much higher weight for user preferences
        metadataCorrelationWeight: 0.10,
      ),
    );
  }

  /// Build a complete discovery playlist based on a seed song
  /// If sessionId is provided, uses existing session for personalization.
  /// If sessionId is null, creates a new session (used when creating new stations).
  Future<List<Song>> buildDiscoveryPlaylist(
    Song seedSong, {
    bool includeOfflineOnly = false,
    int playlistSize = 50,
    int? sessionId,
  }) async {
    final mode = includeOfflineOnly ? DiscoveryMode.offline : DiscoveryMode.online;

    log.info('Building discovery playlist: ${includeOfflineOnly ? "offline" : "online"} mode, sessionId: $sessionId');

    try {
      // Use provided sessionId or create a new one
      if (sessionId != null) {
        _currentSessionId = sessionId;
        log.fine('Using existing discovery session: $_currentSessionId');
      } else {
        _currentSessionId = await _db.createDiscoverySession(
          sourceId: seedSong.sourceId,
          seedSongId: seedSong.id,
          seedArtist: seedSong.artist,
          seedGenre: seedSong.genre,
          mode: mode.isOnline ? 'online' : 'offline',
          playlistSize: playlistSize,
        );
        log.fine('Created new discovery session: $_currentSessionId');
      }

      // Get recommendations using the default balanced algorithm with station personalization
      final recommendations = await generateSimilarSongs(
        seedSong,
        limit: playlistSize - 1, // Account for seed song
        mode: mode,
        sessionId: _currentSessionId, // Enable station-specific personalization
      );

      // Ensure the seed song is first in the playlist
      final playlist = [seedSong, ...recommendations];

      log.info('Built discovery playlist with ${playlist.length} songs (including seed)');
      return playlist;
    } catch (e, stackTrace) {
      log.severe('Error building discovery playlist', e, stackTrace);
      // Fallback: return just the seed song
      return [seedSong];
    }
  }

  /// Record that a song was played in the current discovery session
  Future<void> recordSongPlayed(Song song, int positionInPlaylist) async {
    if (_currentSessionId == null) return;

    try {
      await _db.recordDiscoveryInteraction(
        sessionId: _currentSessionId!,
        songId: song.id,
        interactionType: 'played',
        positionInPlaylist: positionInPlaylist,
        songDurationMs: song.duration?.inMilliseconds,
      );
    } catch (e) {
      log.warning('Failed to record song played: $e');
    }
  }

  /// Record that a song was skipped in the current discovery session
  Future<void> recordSongSkipped(Song song, int positionInPlaylist, {int? playDurationMs}) async {
    if (_currentSessionId == null) return;

    try {
      await _db.recordDiscoveryInteraction(
        sessionId: _currentSessionId!,
        songId: song.id,
        interactionType: 'skipped',
        positionInPlaylist: positionInPlaylist,
        songDurationMs: song.duration?.inMilliseconds,
        playDurationMs: playDurationMs,
      );
    } catch (e) {
      log.warning('Failed to record song skipped: $e');
    }
  }

  /// Record that a song was completed in the current discovery session
  Future<void> recordSongCompleted(Song song, int positionInPlaylist, int playDurationMs) async {
    if (_currentSessionId == null) return;

    try {
      await _db.recordDiscoveryInteraction(
        sessionId: _currentSessionId!,
        songId: song.id,
        interactionType: 'completed',
        positionInPlaylist: positionInPlaylist,
        songDurationMs: song.duration?.inMilliseconds,
        playDurationMs: playDurationMs,
      );
    } catch (e) {
      log.warning('Failed to record song completed: $e');
    }
  }

  /// Record that a song was rated in the current discovery session
  Future<void> recordSongRated(Song song, int positionInPlaylist, UserRating rating) async {
    if (_currentSessionId == null) return;

    final interactionType = rating == UserRating.thumbsUp ? 'thumbs_up' : 'thumbs_down';

    try {
      await _db.recordDiscoveryInteraction(
        sessionId: _currentSessionId!,
        songId: song.id,
        interactionType: interactionType,
        positionInPlaylist: positionInPlaylist,
        songDurationMs: song.duration?.inMilliseconds,
      );
    } catch (e) {
      log.warning('Failed to record song rating: $e');
    }
  }

  /// End the current discovery session
  void endDiscoverySession() {
    if (_currentSessionId != null) {
      log.fine('Ended discovery session $_currentSessionId');
      _currentSessionId = null;
    }
  }

  /// Get discovery analytics for improving recommendations
  Future<Map<String, dynamic>> getDiscoveryAnalytics(int sourceId, {Duration? period}) async {
    final since = period != null
        ? DateTime.now().subtract(period)
        : DateTime.now().subtract(const Duration(days: 30));

    try {
      // Temporarily disabled - database analytics methods not yet implemented
      // TODO: Implement analytics when discovery session tracking is ready

      log.fine('Discovery analytics requested for sourceId: $sourceId since: $since');

      return {
        'total_sessions': 0,
        'average_playlist_size': 0,
        'popular_songs': <Map<String, dynamic>>[],
        'frequently_skipped': <Map<String, dynamic>>[],
        'mode_distribution': {'online': 0, 'offline': 0},
      };
    } catch (e, stackTrace) {
      log.severe('Error getting discovery analytics', e, stackTrace);
      return {};
    }
  }

  /// Get distribution of online vs offline discovery sessions
  Map<String, int> _getModeDistribution(List<dynamic> sessions) {
    final distribution = <String, int>{'online': 0, 'offline': 0};

    for (final session in sessions) {
      if (session is Map && session.containsKey('mode')) {
        final mode = session['mode'] as String;
        distribution[mode] = (distribution[mode] ?? 0) + 1;
      }
    }

    return distribution;
  }

  /// Get the pool of songs available for recommendations based on discovery mode
  Future<List<Song>> _getSongPool(int sourceId, DiscoveryMode mode) async {
    if (mode.isOnline) {
      // Get all songs except thumbs down
      return _db.filterSongs(
        (tbl) => tbl.sourceId.equals(sourceId) &
                 tbl.userRating.equalsValue(UserRating.thumbsDown).not(),
        (tbl) => OrderBy([]), // No specific ordering needed
        (tbl) => Limit(100000, null), // Effectively no limit
      ).get();
    } else {
      // Get only downloaded songs except thumbs down
      return _db.filterSongs(
        (tbl) => tbl.sourceId.equals(sourceId) &
                 tbl.userRating.equalsValue(UserRating.thumbsDown).not() &
                 tbl.downloadFilePath.isNotNull(),
        (tbl) => OrderBy([]),
        (tbl) => Limit(100000, null), // Effectively no limit
      ).get();
    }
  }

  /// Calculate similarity between two songs based on their artists
  Future<double> _calculateArtistSimilarity(Song seedSong, Song candidateSong) async {
    // Same artist = highest similarity
    if (seedSong.artistId == candidateSong.artistId) return 1.0;

    // No artist information = no similarity
    if (seedSong.artistId == null || candidateSong.artistId == null) return 0.0;

    // Check cache first
    if (_artistSimilarityCache.containsKey(seedSong.artistId!) &&
        _artistSimilarityCache[seedSong.artistId!]!.containsKey(candidateSong.artistId!)) {
      return _artistSimilarityCache[seedSong.artistId!]![candidateSong.artistId!]!;
    }

    double similarity = 0.0;

    try {
      // Get albums for both artists to calculate overlap
      final seedArtistAlbums = await _db.albumsByArtistId(seedSong.sourceId, seedSong.artistId!).get();
      final candidateArtistAlbums = await _db.albumsByArtistId(candidateSong.sourceId, candidateSong.artistId!).get();

      // Calculate genre overlap between artists
      final seedGenres = seedArtistAlbums.map((a) => a.genre).whereNotNull().toSet();
      final candidateGenres = candidateArtistAlbums.map((a) => a.genre).whereNotNull().toSet();

      if (seedGenres.isNotEmpty && candidateGenres.isNotEmpty) {
        final genreOverlap = seedGenres.intersection(candidateGenres).length;
        final totalGenres = seedGenres.union(candidateGenres).length;
        similarity = genreOverlap / totalGenres;
      }

      // Cache the result
      _artistSimilarityCache.putIfAbsent(seedSong.artistId!, () => {});
      _artistSimilarityCache[seedSong.artistId!]![candidateSong.artistId!] = similarity;

    } catch (e) {
      log.warning('Error calculating artist similarity: $e');
    }

    return similarity;
  }

  /// Calculate similarity between two songs based on their genres
  Future<double> _calculateGenreSimilarity(Song seedSong, Song candidateSong) async {
    final seedGenre = seedSong.genre;
    final candidateGenre = candidateSong.genre;

    // No genre information = no similarity
    if (seedGenre == null || candidateGenre == null) return 0.0;

    // Exact genre match = highest similarity
    if (seedGenre == candidateGenre) return 1.0;

    // Check for related genres
    final relatedGenres = _getRelatedGenres(seedGenre);
    if (relatedGenres.contains(candidateGenre.toLowerCase())) {
      return 0.7; // High but not perfect similarity for related genres
    }

    return 0.0;
  }

  /// Get genres related to the given genre
  Set<String> _getRelatedGenres(String genre) {
    final genreLower = genre.toLowerCase();

    // Check cache first
    if (_genreRelationshipCache.containsKey(genreLower)) {
      return _genreRelationshipCache[genreLower]!;
    }

    // Define genre relationships
    final relationships = <String, Set<String>>{
      'rock': {'alternative', 'alternative rock', 'indie rock', 'hard rock', 'classic rock', 'progressive rock'},
      'alternative': {'rock', 'indie', 'alternative rock', 'indie rock', 'grunge'},
      'indie': {'alternative', 'indie rock', 'indie pop', 'indie folk'},
      'pop': {'pop rock', 'indie pop', 'electropop', 'dance pop'},
      'metal': {'hard rock', 'heavy metal', 'death metal', 'black metal', 'progressive metal'},
      'electronic': {'techno', 'house', 'ambient', 'electronica', 'edm', 'dance'},
      'jazz': {'smooth jazz', 'bebop', 'swing', 'fusion', 'blues'},
      'blues': {'jazz', 'rock', 'blues rock', 'electric blues'},
      'folk': {'indie folk', 'country', 'americana', 'acoustic'},
      'country': {'folk', 'americana', 'country rock'},
      'hip hop': {'rap', 'hip-hop', 'r&b', 'urban'},
      'classical': {'baroque', 'romantic', 'contemporary classical', 'orchestral'},
    };

    final related = relationships[genreLower] ?? <String>{};
    _genreRelationshipCache[genreLower] = related;

    return related;
  }

  /// Calculate user preference score for a song based on rating
  double _calculateUserPreference(Song song) {
    switch (song.userRating) {
      case UserRating.thumbsUp:
        return 1.0; // Highest preference
      case UserRating.unrated:
        return 0.5; // Neutral
      case UserRating.thumbsDown:
        return 0.0; // Should be filtered out earlier, but safety check
    }
  }

  /// Calculate correlation between songs based on metadata (duration, etc.)
  double _calculateMetadataCorrelation(Song seedSong, Song candidateSong) {
    double correlation = 0.0;
    int factors = 0;

    // Duration similarity (within 30% is considered similar)
    if (seedSong.duration != null && candidateSong.duration != null) {
      final seedMs = seedSong.duration!.inMilliseconds;
      final candidateMs = candidateSong.duration!.inMilliseconds;
      final durationDiff = (seedMs - candidateMs).abs() / seedMs;

      if (durationDiff <= 0.3) {
        correlation += 1.0 - durationDiff; // Closer durations get higher scores
      }
      factors++;
    }

    // Album similarity (same album = higher correlation)
    if (seedSong.albumId != null &&
        candidateSong.albumId != null &&
        seedSong.albumId == candidateSong.albumId) {
      correlation += 0.8;
      factors++;
    }

    return factors > 0 ? correlation / factors : 0.0;
  }

  /// Calculate overall similarity between two songs for station personalization
  /// Combines artist, genre, and album similarity
  Future<double> _calculateSongSimilarity(Song song1, Song song2) async {
    double similarity = 0.0;
    int factors = 0;

    // Artist similarity (highest weight)
    final artistSim = await _calculateArtistSimilarity(song1, song2);
    if (artistSim > 0) {
      similarity += artistSim * 0.5;
      factors++;
    }

    // Genre similarity
    final genreSim = await _calculateGenreSimilarity(song1, song2);
    if (genreSim > 0) {
      similarity += genreSim * 0.3;
      factors++;
    }

    // Album similarity
    if (song1.albumId != null && song2.albumId != null && song1.albumId == song2.albumId) {
      similarity += 0.2; // Same album is a strong signal
      factors++;
    }

    return factors > 0 ? similarity : 0.0;
  }

  /// Normalize a track signature for duplicate detection
  ///
  /// Creates a normalized string from artist + title that can be used
  /// to match tracks across different sources (local vs YouTube).
  ///
  /// Normalization includes:
  /// - Convert to lowercase
  /// - Remove common suffixes (official audio, official video, etc.)
  /// - Remove special characters and extra whitespace
  /// - Trim whitespace
  ///
  /// This helps match tracks like:
  /// - "Radiohead - Creep" (local) vs "Radiohead - Creep (Official Video)" (YouTube)
  /// - "Pink Floyd - Wish You Were Here" vs "Pink Floyd - Wish You Were Here Official Audio"
  String _normalizeTrackSignature(String artist, String title) {
    // Normalize artist
    var normalizedArtist = artist.toLowerCase().trim();

    // Normalize title - remove common YouTube suffixes
    var normalizedTitle = title.toLowerCase().trim();

    // Remove common suffixes
    final suffixesToRemove = [
      'official video',
      'official music video',
      'official audio',
      'official lyric video',
      '(official video)',
      '(official music video)',
      '(official audio)',
      '(official lyric video)',
      '[official video]',
      '[official music video]',
      '[official audio]',
      'music video',
      'lyric video',
      '(music video)',
      '(lyric video)',
      '- official',
      'official',
    ];

    for (final suffix in suffixesToRemove) {
      if (normalizedTitle.endsWith(suffix)) {
        normalizedTitle = normalizedTitle.substring(0, normalizedTitle.length - suffix.length).trim();
      }
    }

    // Remove special characters except spaces and hyphens
    normalizedArtist = normalizedArtist.replaceAll(RegExp(r'[^\w\s\-]'), '');
    normalizedTitle = normalizedTitle.replaceAll(RegExp(r'[^\w\s\-]'), '');

    // Collapse multiple spaces
    normalizedArtist = normalizedArtist.replaceAll(RegExp(r'\s+'), ' ').trim();
    normalizedTitle = normalizedTitle.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Combine into signature
    return '$normalizedArtist|$normalizedTitle';
  }

  /// Apply smart sampling to balance quality recommendations with diversity
  List<WeightedSong> _applySmartSampling(List<WeightedSong> candidates, int limit) {
    if (candidates.length <= limit) return candidates;

    final result = <WeightedSong>[];
    final random = Random();

    // Take top 20% as guaranteed high-quality picks
    final guaranteedCount = (limit * 0.2).ceil();
    result.addAll(candidates.take(guaranteedCount));

    // For the rest, use weighted random selection from top 50% of candidates
    final remainingSlots = limit - guaranteedCount;
    final eligibleCandidates = candidates.skip(guaranteedCount).take((candidates.length * 0.5).ceil()).toList();

    // Create score buckets for more diverse sampling
    final scoreBuckets = <double, List<WeightedSong>>{};
    for (final candidate in eligibleCandidates) {
      final bucket = (candidate.score * 10).round() / 10.0; // Round to nearest 0.1
      scoreBuckets.putIfAbsent(bucket, () => []).add(candidate);
    }

    // Sample from different score buckets to ensure diversity
    final buckets = scoreBuckets.keys.toList()..sort((a, b) => b.compareTo(a));
    int added = 0;

    while (added < remainingSlots && buckets.isNotEmpty) {
      for (final bucket in buckets) {
        if (added >= remainingSlots) break;

        final bucketCandidates = scoreBuckets[bucket]!;
        if (bucketCandidates.isNotEmpty) {
          final randomIndex = random.nextInt(bucketCandidates.length);
          result.add(bucketCandidates.removeAt(randomIndex));
          added++;

          // Remove empty buckets
          if (bucketCandidates.isEmpty) {
            scoreBuckets.remove(bucket);
            buckets.remove(bucket);
            break; // Restart the outer loop to refresh buckets list
          }
        }
      }
    }

    return result;
  }

  // ==========================================================================
  // HYBRID DISCOVERY (YouTube + Local)
  // ==========================================================================

  /// Generate YouTube recommendations based on local song recommendations
  ///
  /// This searches YouTube for similar music based on artists and genres
  /// from the local recommendations, then filters for quality.
  ///
  /// Parameters:
  /// - [seedSong]: The seed song for discovery
  /// - [localRecommendations]: Local songs to base YouTube searches on
  /// - [limit]: Maximum number of YouTube tracks to return
  /// - [config]: Discovery configuration with YouTube settings
  ///
  /// Returns list of YouTube tracks as HybridTracks
  Future<List<HybridTrack>> generateYouTubeRecommendations(
    Song seedSong,
    List<Song> localRecommendations, {
    int limit = 15,
    DiscoveryConfig config = const DiscoveryConfig(),
  }) async {
    try {
      log.info('Generating YouTube recommendations (limit: $limit)');

      final youtubeService = ref.read(youTubeDiscoveryServiceProvider.notifier);

      final youtubeTracks = <HybridTrack>[];
      final seenVideoIds = <String>{};

      // Build a set of locally-owned tracks for duplicate detection
      // We'll check artist + title (normalized) to find matches
      final localTrackSignatures = <String>{};
      try {
        final allLocalSongs = await _getSongPool(seedSong.sourceId, DiscoveryMode.online);
        for (final song in allLocalSongs) {
          if (song.artist != null && song.title != null) {
            // Normalize artist + title for matching
            final signature = _normalizeTrackSignature(song.artist!, song.title!);
            localTrackSignatures.add(signature);
          }
        }
        log.fine('Loaded ${localTrackSignatures.length} local track signatures for duplicate detection');
      } catch (e) {
        log.warning('Failed to load local tracks for duplicate detection: $e');
        // Continue without duplicate detection
      }

      // Extract top artists from local recommendations
      final artistCounts = <String, int>{};
      for (final song in localRecommendations.take(10)) {
        if (song.artist != null) {
          artistCounts[song.artist!] = (artistCounts[song.artist!] ?? 0) + 1;
        }
      }

      // Sort artists by frequency
      final topArtists = artistCounts.entries
          .sorted((a, b) => b.value.compareTo(a.value))
          .take(5)
          .map((e) => e.key)
          .toList();

      log.fine('Top artists for YouTube search: $topArtists');

      // Extract prevalent genres
      final genreCounts = <String, int>{};
      for (final song in localRecommendations.take(10)) {
        if (song.genre != null) {
          genreCounts[song.genre!] = (genreCounts[song.genre!] ?? 0) + 1;
        }
      }

      final topGenres = genreCounts.entries
          .where((e) => e.value >= 2) // At least 2 occurrences
          .sorted((a, b) => b.value.compareTo(a.value))
          .take(3)
          .map((e) => e.key)
          .toList();

      log.fine('Top genres for YouTube search: $topGenres');

      // Search YouTube for each top artist
      for (final artist in topArtists) {
        if (youtubeTracks.length >= limit) break;

        try {
          // Build search query
          final query = topGenres.isNotEmpty
              ? '$artist ${topGenres.first} official audio'
              : '$artist official audio';

          final results = await youtubeService.searchMusic(query, limit: 5);

          // Apply quality filtering
          final strictFilter = config.youtubeQualityFilter == YouTubeQualityFilter.strict;
          final filteredResults = youtubeService.filterByQuality(
            results,
            strictFilter: strictFilter,
            preferOfficial: config.youtubePreferOfficial,
          );

          log.fine('YouTube search "$query": ${filteredResults.length} quality results');

          // Convert to HybridTracks and deduplicate
          // NOTE: We don't cache tracks here - they will be cached lazily when about to play
          for (final result in filteredResults) {
            if (youtubeTracks.length >= limit) break;
            if (seenVideoIds.contains(result.videoId)) continue;

            // DUPLICATE DETECTION: Skip if user already owns this track locally
            final youtubeSignature = _normalizeTrackSignature(result.author, result.title);
            if (localTrackSignatures.contains(youtubeSignature)) {
              log.fine('Skipping duplicate track: ${result.author} - ${result.title} (already owned locally)');
              continue;
            }

            seenVideoIds.add(result.videoId);
            youtubeTracks.add(HybridTrackFactory.fromYouTubeSearchResult(result));
          }

          // Small delay to avoid rate limiting
          await Future.delayed(const Duration(milliseconds: 200));
        } catch (e) {
          log.warning('Failed YouTube search for artist "$artist": $e');
          continue;
        }
      }

      // If we still need more tracks, search by genre
      if (youtubeTracks.length < limit && topGenres.isNotEmpty) {
        for (final genre in topGenres) {
          if (youtubeTracks.length >= limit) break;

          try {
            final query = '$genre music official';
            final results = await youtubeService.searchMusic(query, limit: 5);

            final strictFilter = config.youtubeQualityFilter == YouTubeQualityFilter.strict;
            final filteredResults = youtubeService.filterByQuality(
              results,
              strictFilter: strictFilter,
              preferOfficial: config.youtubePreferOfficial,
            );

            // Convert to HybridTracks (lazy caching - done when about to play)
            for (final result in filteredResults) {
              if (youtubeTracks.length >= limit) break;
              if (seenVideoIds.contains(result.videoId)) continue;

              // DUPLICATE DETECTION: Skip if user already owns this track locally
              final youtubeSignature = _normalizeTrackSignature(result.author, result.title);
              if (localTrackSignatures.contains(youtubeSignature)) {
                log.fine('Skipping duplicate track: ${result.author} - ${result.title} (already owned locally)');
                continue;
              }

              seenVideoIds.add(result.videoId);
              youtubeTracks.add(HybridTrackFactory.fromYouTubeSearchResult(result));
            }

            await Future.delayed(const Duration(milliseconds: 200));
          } catch (e) {
            log.warning('Failed YouTube search for genre "$genre": $e');
            continue;
          }
        }
      }

      log.info('Generated ${youtubeTracks.length} YouTube recommendations');
      return youtubeTracks;
    } catch (e, stackTrace) {
      log.severe('Error generating YouTube recommendations', e, stackTrace);
      return [];
    }
  }

  /// Blend local and YouTube tracks into a hybrid playlist
  ///
  /// Uses weighted interleaving to distribute YouTube tracks evenly
  /// throughout the playlist while maintaining the configured ratio.
  ///
  /// Parameters:
  /// - [localTracks]: Local song recommendations
  /// - [youtubeTracks]: YouTube track recommendations
  /// - [youtubeRatio]: Ratio of YouTube content (0.0 to 1.0)
  ///
  /// Returns blended list of HybridTracks
  List<HybridTrack> blendTracks(
    List<Song> localTracks,
    List<HybridTrack> youtubeTracks,
    double youtubeRatio,
  ) {
    try {
      log.info('Blending ${localTracks.length} local + ${youtubeTracks.length} YouTube tracks (ratio: $youtubeRatio)');

      if (youtubeTracks.isEmpty) {
        // No YouTube tracks, return all local
        return HybridTrackFactory.fromSongs(localTracks);
      }

      if (localTracks.isEmpty) {
        // No local tracks, return all YouTube
        return youtubeTracks;
      }

      final blended = <HybridTrack>[];
      final totalTracks = localTracks.length;
      final youtubeCount = (totalTracks * youtubeRatio).round().clamp(0, youtubeTracks.length);
      final localCount = totalTracks - youtubeCount;

      log.fine('Target blend: $localCount local + $youtubeCount YouTube = $totalTracks total');

      // Calculate interleave pattern
      // Example for 70/30 (7 local, 3 YouTube): L L L Y L L L Y L L
      final localPerYoutube = youtubeCount > 0 ? (localCount / youtubeCount).round() : localCount;

      int localIndex = 0;
      int youtubeIndex = 0;
      int localStreak = 0;

      while (blended.length < totalTracks) {
        // Add local tracks
        if (localIndex < localCount &&
            (localStreak < localPerYoutube || youtubeIndex >= youtubeCount)) {
          blended.add(HybridTrack.local(song: localTracks[localIndex++]));
          localStreak++;
        }
        // Add YouTube track
        else if (youtubeIndex < youtubeCount) {
          blended.add(youtubeTracks[youtubeIndex++]);
          localStreak = 0;
        }
        // Fill remaining with local if YouTube exhausted
        else if (localIndex < localCount) {
          blended.add(HybridTrack.local(song: localTracks[localIndex++]));
        } else {
          break; // Both exhausted
        }
      }

      final actualLocalCount = blended.where((t) => t.isLocal).length;
      final actualYouTubeCount = blended.where((t) => t.isYouTube).length;
      log.info('Final blend: $actualLocalCount local + $actualYouTubeCount YouTube = ${blended.length} total');

      return blended;
    } catch (e, stackTrace) {
      log.severe('Error blending tracks', e, stackTrace);
      // Fallback: return all local tracks
      return HybridTrackFactory.fromSongs(localTracks);
    }
  }

  /// Build a hybrid discovery playlist with YouTube integration
  ///
  /// Generates local recommendations, searches YouTube for similar content,
  /// filters for quality, and blends them according to the configured ratio.
  ///
  /// Parameters:
  /// - [seedSong]: The seed song for discovery
  /// - [includeOfflineOnly]: If true, use only downloaded songs
  /// - [playlistSize]: Target size of the playlist
  /// - [config]: Discovery configuration with YouTube settings
  /// - [sessionId]: Discovery session ID for tracking
  ///
  /// Returns hybrid playlist of local and YouTube tracks
  Future<List<HybridTrack>> buildHybridDiscoveryPlaylist(
    Song seedSong, {
    bool includeOfflineOnly = false,
    int playlistSize = 50,
    DiscoveryConfig config = const DiscoveryConfig(),
    int? sessionId,
  }) async {
    try {
      log.info('Building hybrid discovery playlist (size: $playlistSize, YouTube: ${config.youtubeEnabled})');

      // Check if YouTube is enabled
      if (!config.youtubeEnabled) {
        log.fine('YouTube disabled, using local-only playlist');
        final localSongs = await buildDiscoveryPlaylist(
          seedSong,
          includeOfflineOnly: includeOfflineOnly,
          playlistSize: playlistSize,
          sessionId: sessionId,
        );
        return HybridTrackFactory.fromSongs(localSongs);
      }

      // Skip service availability check - let individual requests fail gracefully
      // This allows offline work and graceful degradation
      final youtubeService = ref.read(youTubeDiscoveryServiceProvider.notifier);
      log.info('YouTube discovery enabled - will attempt search (may fail gracefully if service unavailable)');

      final mode = includeOfflineOnly ? DiscoveryMode.offline : DiscoveryMode.online;

      // Calculate how many local vs YouTube tracks we need
      final youtubeCount = (playlistSize * config.youtubeRatio).round();
      final localCount = playlistSize - youtubeCount;

      log.fine('Target: $localCount local + $youtubeCount YouTube tracks');

      // Generate local recommendations (excluding seed song)
      final localRecommendations = await generateSimilarSongs(
        seedSong,
        limit: localCount,
        mode: mode,
        config: config,
        sessionId: sessionId,
      );

      log.fine('Generated ${localRecommendations.length} local recommendations');

      // Generate YouTube recommendations based on local tracks
      final youtubeRecommendations = await generateYouTubeRecommendations(
        seedSong,
        localRecommendations,
        limit: youtubeCount,
        config: config,
      );

      log.fine('Generated ${youtubeRecommendations.length} YouTube recommendations');

      // Blend the tracks
      final blendedTracks = blendTracks(
        localRecommendations,
        youtubeRecommendations,
        config.youtubeRatio,
      );

      // Add seed song at the beginning
      final playlist = [
        HybridTrack.local(song: seedSong),
        ...blendedTracks,
      ];

      log.info('Built hybrid playlist with ${playlist.length} tracks '
          '(${playlist.where((t) => t.isLocal).length} local, '
          '${playlist.where((t) => t.isYouTube).length} YouTube)');

      return playlist;
    } catch (e, stackTrace) {
      log.severe('Error building hybrid discovery playlist', e, stackTrace);

      // Fallback to local-only on any error
      log.warning('Falling back to local-only playlist due to error');
      final localSongs = await buildDiscoveryPlaylist(
        seedSong,
        includeOfflineOnly: includeOfflineOnly,
        playlistSize: playlistSize,
        sessionId: sessionId,
      );
      return HybridTrackFactory.fromSongs(localSongs);
    }
  }
}