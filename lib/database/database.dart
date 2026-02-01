import 'dart:io';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:drift/isolate.dart';
import 'package:drift/native.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../log.dart';
import '../models/music.dart';
import '../models/query.dart';
import '../models/settings.dart';
import '../models/support.dart';
import 'converters.dart';
import 'error_logging_database.dart';

part 'database.g.dart';

// don't exceed SQLITE_MAX_VARIABLE_NUMBER (32766 for version >= 3.32.0)
// https://www.sqlite.org/limits.html
const kSqliteMaxVariableNumber = 32766;

@DriftDatabase(include: {'tables.drift'})
class SubtracksDatabase extends _$SubtracksDatabase {
  SubtracksDatabase() : super(_openConnection());
  SubtracksDatabase.connection(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 12;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          // Add user_rating column to songs table
          await migrator.addColumn(songs, songs.userRating);
        }
        if (from < 3) {
          // Add discovery tracking tables
          await migrator.createTable(discoverySessions);
          await migrator.createTable(discoveryInteractions);
        }
        if (from < 4) {
          // Add station metadata columns to discovery_sessions table
          await customStatement(
            'ALTER TABLE discovery_sessions ADD COLUMN station_name TEXT',
          );
          await customStatement(
            'ALTER TABLE discovery_sessions ADD COLUMN last_played_at INTEGER',
          );
          await customStatement(
            'ALTER TABLE discovery_sessions ADD COLUMN play_count INTEGER NOT NULL DEFAULT 0',
          );
          await customStatement(
            'ALTER TABLE discovery_sessions ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0',
          );
          // Add indexes for the new columns
          await customStatement(
            'CREATE INDEX discovery_sessions_last_played_at ON discovery_sessions (last_played_at)',
          );
          await customStatement(
            'CREATE INDEX discovery_sessions_is_favorite ON discovery_sessions (is_favorite)',
          );
        }
        if (from < 5) {
          // Add global rating counter columns to songs table
          await customStatement(
            'ALTER TABLE songs ADD COLUMN thumbs_up_count INTEGER NOT NULL DEFAULT 0',
          );
          await customStatement(
            'ALTER TABLE songs ADD COLUMN thumbs_down_count INTEGER NOT NULL DEFAULT 0',
          );
        }
        if (from < 6) {
          // Add YouTube tracks table
          await customStatement('''
            CREATE TABLE youtube_tracks (
              id TEXT PRIMARY KEY NOT NULL,
              title TEXT NOT NULL,
              artist TEXT,
              channel_name TEXT NOT NULL,
              duration_seconds INTEGER NOT NULL,
              thumbnail_url TEXT,
              audio_url TEXT NOT NULL,
              audio_bitrate INTEGER NOT NULL,
              audio_codec TEXT NOT NULL,
              audio_quality TEXT NOT NULL,
              cached_at INTEGER NOT NULL,
              expires_at INTEGER NOT NULL,
              access_count INTEGER NOT NULL DEFAULT 0,
              last_accessed INTEGER
            )
          ''');

          // Create indexes for youtube_tracks
          await customStatement(
            'CREATE INDEX idx_youtube_tracks_expires ON youtube_tracks(expires_at)',
          );
          await customStatement(
            'CREATE INDEX idx_youtube_tracks_cached ON youtube_tracks(cached_at)',
          );
          await customStatement(
            'CREATE INDEX idx_youtube_tracks_last_accessed ON youtube_tracks(last_accessed)',
          );

          // Add youtube_discovery_items table
          await customStatement('''
            CREATE TABLE youtube_discovery_items (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              session_id INTEGER NOT NULL,
              youtube_track_id TEXT NOT NULL,
              position_in_playlist INTEGER NOT NULL,
              discovered_at INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP)),
              FOREIGN KEY (session_id) REFERENCES discovery_sessions (id) ON DELETE CASCADE,
              FOREIGN KEY (youtube_track_id) REFERENCES youtube_tracks (id) ON DELETE CASCADE
            )
          ''');

          // Create indexes for youtube_discovery_items
          await customStatement(
            'CREATE INDEX idx_youtube_discovery_session ON youtube_discovery_items(session_id)',
          );
          await customStatement(
            'CREATE INDEX idx_youtube_discovery_track ON youtube_discovery_items(youtube_track_id)',
          );
        }
        if (from < 7) {
          // Add YouTube track source tracking to discovery_interactions
          await customStatement(
            'ALTER TABLE discovery_interactions ADD COLUMN track_source TEXT NOT NULL DEFAULT \'local\'',
          );
          await customStatement(
            'ALTER TABLE discovery_interactions ADD COLUMN youtube_video_id TEXT',
          );
          // Create indexes for the new columns
          await customStatement(
            'CREATE INDEX discovery_interactions_track_source ON discovery_interactions (track_source)',
          );
          await customStatement(
            'CREATE INDEX discovery_interactions_youtube_video_id ON discovery_interactions (youtube_video_id)',
          );
        }
        if (from < 8) {
          // Add YouTube discovery settings to app_settings table
          await customStatement(
            'ALTER TABLE app_settings ADD COLUMN youtube_discovery_enabled BOOLEAN NOT NULL DEFAULT 0',
          );
          await customStatement(
            'ALTER TABLE app_settings ADD COLUMN youtube_discovery_ratio REAL NOT NULL DEFAULT 0.3',
          );
          await customStatement(
            'ALTER TABLE app_settings ADD COLUMN youtube_quality_filter TEXT NOT NULL DEFAULT \'moderate\'',
          );
          await customStatement(
            'ALTER TABLE app_settings ADD COLUMN youtube_prefer_official BOOLEAN NOT NULL DEFAULT 1',
          );

          // Add Lidarr download requests tracking table
          await customStatement('''
            CREATE TABLE lidarr_requests (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              youtube_video_id TEXT NOT NULL,
              artist_name TEXT NOT NULL,
              foreign_artist_id TEXT,
              status TEXT NOT NULL,
              requested_at INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP)),
              completed_at INTEGER,
              error_message TEXT,
              UNIQUE(youtube_video_id)
            )
          ''');
          // Create indexes for lidarr_requests
          await customStatement(
            'CREATE INDEX idx_lidarr_requests_status ON lidarr_requests(status)',
          );
          await customStatement(
            'CREATE INDEX idx_lidarr_requests_video ON lidarr_requests(youtube_video_id)',
          );
          await customStatement(
            'CREATE INDEX idx_lidarr_requests_requested_at ON lidarr_requests(requested_at)',
          );
        }
        if (from < 9) {
          // Add theme preset settings to app_settings table
          await customStatement(
            'ALTER TABLE app_settings ADD COLUMN theme_preset TEXT NOT NULL DEFAULT \'subtracks\'',
          );
          await customStatement(
            'ALTER TABLE app_settings ADD COLUMN enable_dynamic_colors BOOLEAN NOT NULL DEFAULT 1',
          );
          await customStatement(
            'ALTER TABLE app_settings ADD COLUMN custom_seed_color INTEGER',
          );
        }
        if (from < 10) {
          // Add per-station YouTube ratio to discovery_sessions table
          await customStatement(
            'ALTER TABLE discovery_sessions ADD COLUMN youtube_ratio REAL NOT NULL DEFAULT 0.3',
          );
        }
        if (from < 11) {
          // Add offline mode settings to app_settings table
          await customStatement(
            'ALTER TABLE app_settings ADD COLUMN download_preference TEXT NOT NULL DEFAULT \'any_connection\'',
          );
          await customStatement(
            'ALTER TABLE app_settings ADD COLUMN thumbs_up_auto_download BOOLEAN NOT NULL DEFAULT 0',
          );
          await customStatement(
            'ALTER TABLE app_settings ADD COLUMN thumbs_down_auto_delete BOOLEAN NOT NULL DEFAULT 0',
          );
        }
        if (from < 12) {
          // Add indexes for genre and user_rating to songs table
          await customStatement(
            'CREATE INDEX songs_source_id_genre_idx ON songs (source_id, genre)',
          );
          await customStatement(
            'CREATE INDEX songs_source_id_user_rating_updated_idx ON songs (source_id, user_rating, updated)',
          );
        }
      },
    );
  }

  /// Runs a database opertion in a background isolate.
  ///
  /// **Only pass top-level functions to [computation]!**
  ///
  /// **Do not use non-serializable data inside [computation]!**
  Future<Ret> background<Ret>(
    FutureOr<Ret> Function(SubtracksDatabase) computation,
  ) async {
    return computeWithDatabase(
      connect: SubtracksDatabase.connection,
      computation: computation,
    );
  }

  MultiSelectable<Album> albumsList(int sourceId, ListQuery opt) {
    return filterAlbums(
      (_) => _filterPredicate('albums', sourceId, opt),
      (_) => _filterOrderBy(opt),
      (_) => _filterLimit(opt),
    );
  }

  MultiSelectable<Album> albumsListDownloaded(int sourceId, ListQuery opt) {
    return filterAlbumsDownloaded(
      (_, __) => _filterPredicate('albums', sourceId, opt),
      (_, __) => _filterOrderBy(opt),
      (_, __) => _filterLimit(opt),
    );
  }

  MultiSelectable<Artist> artistsList(int sourceId, ListQuery opt) {
    return filterArtists(
      (_) => _filterPredicate('artists', sourceId, opt),
      (_) => _filterOrderBy(opt),
      (_) => _filterLimit(opt),
    );
  }

  MultiSelectable<Artist> artistsListDownloaded(int sourceId, ListQuery opt) {
    return filterArtistsDownloaded(
      (_, __, ___) => _filterPredicate('artists', sourceId, opt),
      (_, __, ___) => _filterOrderBy(opt),
      (_, __, ___) => _filterLimit(opt),
    );
  }

  MultiSelectable<Playlist> playlistsList(int sourceId, ListQuery opt) {
    return filterPlaylists(
      (_) => _filterPredicate('playlists', sourceId, opt),
      (_) => _filterOrderBy(opt),
      (_) => _filterLimit(opt),
    );
  }

  MultiSelectable<Playlist> playlistsListDownloaded(
      int sourceId, ListQuery opt) {
    return filterPlaylistsDownloaded(
      (_, __, ___) => _filterPredicate('playlists', sourceId, opt),
      (_, __, ___) => _filterOrderBy(opt),
      (_, __, ___) => _filterLimit(opt),
    );
  }

  MultiSelectable<Song> songsList(int sourceId, ListQuery opt) {
    return filterSongs(
      (_) => _filterPredicate('songs', sourceId, opt),
      (_) => _filterOrderBy(opt),
      (_) => _filterLimit(opt),
    );
  }

  MultiSelectable<Song> songsListDownloaded(int sourceId, ListQuery opt) {
    return filterSongsDownloaded(
      (_) => _filterPredicate('songs', sourceId, opt),
      (_) => _filterOrderBy(opt),
      (_) => _filterLimit(opt),
    );
  }

  Expression<bool> _filterPredicate(String table, int sourceId, ListQuery opt) {
    return opt.filters.map((filter) => buildFilter<bool>(filter)).fold(
          CustomExpression('$table.source_id = $sourceId'),
          (previousValue, element) => previousValue & element,
        );
  }

  OrderBy _filterOrderBy(ListQuery opt) {
    return opt.sort != null
        ? OrderBy([_buildOrder(opt.sort!)])
        : const OrderBy.nothing();
  }

  Limit _filterLimit(ListQuery opt) {
    return Limit(opt.page.limit, opt.page.offset);
  }

  MultiSelectable<Song> albumSongsList(SourceId sid, ListQuery opt) {
    return listQuery(
      select(songs)
        ..where((tbl) =>
            tbl.sourceId.equals(sid.sourceId) & tbl.albumId.equals(sid.id)),
      opt,
    );
  }

  MultiSelectable<Song> songsByAlbumList(int sourceId, ListQuery opt) {
    return filterSongsByGenre(
      (_, __) => _filterPredicate('songs', sourceId, opt),
      (_, __) => _filterOrderBy(opt),
      (_, __) => _filterLimit(opt),
    );
  }

  MultiSelectable<Song> playlistSongsList(SourceId sid, ListQuery opt) {
    return listQueryJoined(
      select(songs).join([
        innerJoin(
          playlistSongs,
          playlistSongs.sourceId.equalsExp(songs.sourceId) &
              playlistSongs.songId.equalsExp(songs.id),
          useColumns: false,
        ),
      ])
        ..where(playlistSongs.sourceId.equals(sid.sourceId) &
            playlistSongs.playlistId.equals(sid.id)),
      opt,
    ).map((row) => row.readTable(songs));
  }

  Future<void> saveArtists(Iterable<ArtistsCompanion> artists) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(this.artists, artists);
    });
  }

  Future<void> deleteArtistsNotIn(int sourceId, Set<String> ids) {
    return transaction(() async {
      final allIds = (await (selectOnly(artists)
                ..addColumns([artists.id])
                ..where(artists.sourceId.equals(sourceId)))
              .map((row) => row.read(artists.id))
              .get())
          .whereNotNull()
          .toSet();
      final downloadIds = (await artistIdsWithDownloadStatus(sourceId).get())
          .whereNotNull()
          .toSet();

      final diff = allIds.difference(downloadIds).difference(ids);
      for (var slice in diff.slices(kSqliteMaxVariableNumber)) {
        await (delete(artists)
              ..where(
                  (tbl) => tbl.sourceId.equals(sourceId) & tbl.id.isIn(slice)))
            .go();
      }
    });
  }

  Future<void> saveAlbums(Iterable<AlbumsCompanion> albums) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(this.albums, albums);
    });
  }

  Future<void> deleteAlbumsNotIn(int sourceId, Set<String> ids) {
    return transaction(() async {
      final allIds = (await (selectOnly(albums)
                ..addColumns([albums.id])
                ..where(albums.sourceId.equals(sourceId)))
              .map((row) => row.read(albums.id))
              .get())
          .whereNotNull()
          .toSet();
      final downloadIds = (await albumIdsWithDownloadStatus(sourceId).get())
          .whereNotNull()
          .toSet();

      final diff = allIds.difference(downloadIds).difference(ids);
      for (var slice in diff.slices(kSqliteMaxVariableNumber)) {
        await (delete(albums)
              ..where(
                  (tbl) => tbl.sourceId.equals(sourceId) & tbl.id.isIn(slice)))
            .go();
      }
    });
  }

  Future<void> savePlaylists(
    Iterable<PlaylistWithSongsCompanion> playlistsWithSongs,
  ) async {
    final playlists = playlistsWithSongs.map((e) => e.playist);
    final playlistSongs = playlistsWithSongs.expand((e) => e.songs);
    final sourceId = playlists.first.sourceId.value;

    await (delete(this.playlistSongs)
          ..where(
            (tbl) =>
                tbl.sourceId.equals(sourceId) &
                tbl.playlistId.isIn(playlists.map((e) => e.id.value)),
          ))
        .go();

    await batch((batch) {
      batch.insertAllOnConflictUpdate(this.playlists, playlists);
      batch.insertAllOnConflictUpdate(this.playlistSongs, playlistSongs);
    });
  }

  Future<void> deletePlaylistsNotIn(int sourceId, Set<String> ids) {
    return transaction(() async {
      final allIds = (await (selectOnly(playlists)
                ..addColumns([playlists.id])
                ..where(playlists.sourceId.equals(sourceId)))
              .map((row) => row.read(playlists.id))
              .get())
          .whereNotNull()
          .toSet();
      final downloadIds = (await playlistIdsWithDownloadStatus(sourceId).get())
          .whereNotNull()
          .toSet();

      final diff = allIds.difference(downloadIds).difference(ids);
      for (var slice in diff.slices(kSqliteMaxVariableNumber)) {
        await (delete(playlists)
              ..where(
                  (tbl) => tbl.sourceId.equals(sourceId) & tbl.id.isIn(slice)))
            .go();
        await (delete(playlistSongs)
              ..where((tbl) =>
                  tbl.sourceId.equals(sourceId) & tbl.playlistId.isIn(slice)))
            .go();
      }
    });
  }

  Future<void> savePlaylistSongs(
    int sourceId,
    List<String> ids,
    Iterable<PlaylistSongsCompanion> playlistSongs,
  ) async {
    await (delete(this.playlistSongs)
          ..where(
            (tbl) => tbl.sourceId.equals(sourceId) & tbl.playlistId.isIn(ids),
          ))
        .go();
    await batch((batch) {
      batch.insertAllOnConflictUpdate(this.playlistSongs, playlistSongs);
    });
  }

  Future<void> saveSongs(Iterable<SongsCompanion> songs) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(this.songs, songs);
    });
  }

  Future<void> deleteSongsNotIn(int sourceId, Set<String> ids) {
    return transaction(() async {
      final allIds = (await (selectOnly(songs)
                ..addColumns([songs.id])
                ..where(
                  songs.sourceId.equals(sourceId) &
                      songs.downloadFilePath.isNull() &
                      songs.downloadTaskId.isNull(),
                ))
              .map((row) => row.read(songs.id))
              .get())
          .whereNotNull()
          .toSet();

      final diff = allIds.difference(ids);
      for (var slice in diff.slices(kSqliteMaxVariableNumber)) {
        await (delete(songs)
              ..where(
                  (tbl) => tbl.sourceId.equals(sourceId) & tbl.id.isIn(slice)))
            .go();
        await (delete(playlistSongs)
              ..where(
                (tbl) => tbl.sourceId.equals(sourceId) & tbl.songId.isIn(slice),
              ))
            .go();
      }
    });
  }

  Selectable<LastBottomNavStateData> getLastBottomNavState() {
    return select(lastBottomNavState)..where((tbl) => tbl.id.equals(1));
  }

  Future<void> saveLastBottomNavState(LastBottomNavStateData update) {
    return into(lastBottomNavState).insertOnConflictUpdate(update);
  }

  Selectable<LastLibraryStateData> getLastLibraryState() {
    return select(lastLibraryState)..where((tbl) => tbl.id.equals(1));
  }

  Future<void> saveLastLibraryState(LastLibraryStateData update) {
    return into(lastLibraryState).insertOnConflictUpdate(update);
  }

  Selectable<LastAudioStateData> getLastAudioState() {
    return select(lastAudioState)..where((tbl) => tbl.id.equals(1));
  }

  Future<void> saveLastAudioState(LastAudioStateCompanion update) {
    return into(lastAudioState).insertOnConflictUpdate(update);
  }

  Future<void> insertQueue(Iterable<QueueCompanion> songs) async {
    await batch((batch) {
      batch.insertAll(queue, songs);
    });
  }

  Future<void> clearQueue() async {
    await delete(queue).go();
  }

  Future<void> setCurrentTrack(int index) async {
    await transaction(() async {
      await (update(queue)..where((tbl) => tbl.index.equals(index).not()))
          .write(const QueueCompanion(currentTrack: Value(null)));
      await (update(queue)..where((tbl) => tbl.index.equals(index)))
          .write(const QueueCompanion(currentTrack: Value(true)));
    });
  }

  Future<void> createSource(
    SourcesCompanion source,
    SubsonicSourcesCompanion subsonic,
  ) async {
    await transaction(() async {
      final count = await sourcesCount().getSingle();
      if (count == 0) {
        source = source.copyWith(isActive: const Value(true));
      }

      final id = await into(sources).insert(source);
      subsonic = subsonic.copyWith(sourceId: Value(id));
      await into(subsonicSources).insert(subsonic);
    });
  }

  Future<void> updateSource(SubsonicSettings source) async {
    await transaction(() async {
      await into(sources).insertOnConflictUpdate(source.toSourceInsertable());
      await into(subsonicSources)
          .insertOnConflictUpdate(source.toSubsonicInsertable());
    });
  }

  Future<void> deleteSource(int sourceId) async {
    await transaction(() async {
      await (delete(subsonicSources)
            ..where((tbl) => tbl.sourceId.equals(sourceId)))
          .go();
      await (delete(sources)..where((tbl) => tbl.id.equals(sourceId))).go();

      await (delete(songs)..where((tbl) => tbl.sourceId.equals(sourceId))).go();
      await (delete(albums)..where((tbl) => tbl.sourceId.equals(sourceId)))
          .go();
      await (delete(artists)..where((tbl) => tbl.sourceId.equals(sourceId)))
          .go();
      await (delete(playlistSongs)
            ..where((tbl) => tbl.sourceId.equals(sourceId)))
          .go();
      await (delete(playlists)..where((tbl) => tbl.sourceId.equals(sourceId)))
          .go();
    });
  }

  Future<void> setActiveSource(int id) async {
    await batch((batch) {
      batch.update(
        sources,
        const SourcesCompanion(isActive: Value(null)),
        where: (t) => t.id.isNotValue(id),
      );
      batch.update(
        sources,
        const SourcesCompanion(isActive: Value(true)),
        where: (t) => t.id.equals(id),
      );
    });
  }

  Future<void> updateSettings(AppSettingsCompanion settings) async {
    await into(appSettings).insertOnConflictUpdate(settings);
  }

  // Rating-related methods
  Future<void> updateSongRating(int sourceId, String songId, UserRating rating) async {
    await (update(songs)
          ..where((tbl) =>
              tbl.sourceId.equals(sourceId) &
              tbl.id.equals(songId)))
        .write(SongsCompanion(userRating: Value(rating)));
  }

  Future<List<Song>> getSongsWithRating(int sourceId, UserRating rating) async {
    return await songsWithRating(sourceId, rating).get();
  }

  Future<List<Song>> getLikedSongs(int sourceId) async {
    return await likedSongs(sourceId).get();
  }

  Future<List<Song>> getDislikedSongs(int sourceId) async {
    return await dislikedSongs(sourceId).get();
  }

  Future<Map<String, int>> getRatingStatistics(int sourceId) async {
    final results = await ratingStats(sourceId).get();
    return Map.fromEntries(
      results.map((row) => MapEntry(row.userRating.toString().split('.').last, row.count)),
    );
  }

  // Global rating counter methods

  /// Increment the thumbs_up_count for a song
  Future<void> incrementThumbsUpCount(int sourceId, String songId) async {
    await customStatement(
      'UPDATE songs SET thumbs_up_count = thumbs_up_count + 1 WHERE source_id = ? AND id = ?',
      [sourceId, songId],
    );
  }

  /// Decrement the thumbs_up_count for a song (with bounds checking)
  Future<void> decrementThumbsUpCount(int sourceId, String songId) async {
    await customStatement(
      'UPDATE songs SET thumbs_up_count = MAX(0, thumbs_up_count - 1) WHERE source_id = ? AND id = ?',
      [sourceId, songId],
    );
  }

  /// Increment the thumbs_down_count for a song
  Future<void> incrementThumbsDownCount(int sourceId, String songId) async {
    await customStatement(
      'UPDATE songs SET thumbs_down_count = thumbs_down_count + 1 WHERE source_id = ? AND id = ?',
      [sourceId, songId],
    );
  }

  /// Decrement the thumbs_down_count for a song (with bounds checking)
  Future<void> decrementThumbsDownCount(int sourceId, String songId) async {
    await customStatement(
      'UPDATE songs SET thumbs_down_count = MAX(0, thumbs_down_count - 1) WHERE source_id = ? AND id = ?',
      [sourceId, songId],
    );
  }

  /// Get the current rating for a song
  Future<UserRating?> getSongRating(int sourceId, String songId) async {
    final song = await songById(sourceId, songId).getSingleOrNull();
    return song?.userRating;
  }

  /// Get most loved songs (sorted by thumbs_up_count)
  Future<List<Song>> getMostLovedSongs(int sourceId, {int limit = 50, int offset = 0}) async {
    return await mostLovedSongs(sourceId, limit, offset).get();
  }

  /// Get most disliked songs (sorted by thumbs_down_count)
  Future<List<Song>> getMostDislikedSongs(int sourceId, {int limit = 50, int offset = 0}) async {
    return await mostDislikedSongs(sourceId, limit, offset).get();
  }

  // Discovery Radio tracking methods

  /// Create a new discovery session
  Future<int> createDiscoverySession({
    required int sourceId,
    required String seedSongId,
    String? seedArtist,
    String? seedGenre,
    required String mode, // 'online' or 'offline'
    int playlistSize = 50,
    double youtubeRatio = 0.3,
    String? stationName,
  }) async {
    final result = await into(discoverySessions).insert(
      DiscoverySessionsCompanion.insert(
        sourceId: sourceId,
        seedSongId: seedSongId,
        seedArtist: Value(seedArtist),
        seedGenre: Value(seedGenre),
        mode: mode,
        playlistSize: Value(playlistSize),
        youtubeRatio: Value(youtubeRatio),
        stationName: Value(stationName),
      ),
    );
    return result;
  }

  /// Record a discovery interaction (play, skip, etc.)
  Future<void> recordDiscoveryInteraction({
    required int sessionId,
    required String songId,
    required String interactionType, // 'played', 'skipped', 'thumbs_up', 'thumbs_down', 'completed'
    required int positionInPlaylist,
    int? songDurationMs,
    int? playDurationMs,
    String trackSource = 'local', // 'local' or 'youtube'
    String? youtubeVideoId, // NULL for local tracks, video ID for YouTube tracks
  }) async {
    await into(discoveryInteractions).insert(
      DiscoveryInteractionsCompanion.insert(
        sessionId: sessionId,
        songId: songId,
        interactionType: interactionType,
        positionInPlaylist: positionInPlaylist,
        songDurationMs: Value(songDurationMs),
        playDurationMs: Value(playDurationMs),
        trackSource: Value(trackSource),
        youtubeVideoId: Value(youtubeVideoId),
      ),
    );
  }

  /// Get discovery sessions for a source
  Future<List<DiscoverySession>> getDiscoverySessions(int sourceId, {int limit = 20, int offset = 0}) async {
    return await discoverySessionsBySource(sourceId, limit, offset).get();
  }

  /// Get interactions for a discovery session
  Future<List<DiscoveryInteraction>> getDiscoveryInteractions(int sessionId) async {
    return await discoveryInteractionsBySession(sessionId).get();
  }

  /// Get recent discovery sessions
  Future<List<DiscoverySession>> getRecentDiscoverySessions(int sourceId, DateTime since) async {
    final timestamp = since.millisecondsSinceEpoch ~/ 1000;
    return await discoveryRecentSessions(sourceId, timestamp).get();
  }

  /// Get popular songs from discovery sessions
  Future<List<DiscoveryPopularSongsResult>> getDiscoveryPopularSongs(
    int sourceId,
    DateTime since, {
    int limit = 50,
  }) async {
    final timestamp = since.millisecondsSinceEpoch ~/ 1000;
    return await discoveryPopularSongs(sourceId, timestamp, limit).get();
  }

  /// Get frequently skipped songs from discovery sessions
  Future<List<DiscoverySkippedSongsResult>> getDiscoverySkippedSongs(
    int sourceId,
    DateTime since, {
    int limit = 50,
  }) async {
    final timestamp = since.millisecondsSinceEpoch ~/ 1000;
    return await discoverySkippedSongs(sourceId, timestamp, limit).get();
  }

  // Station management methods

  /// Update the name of a discovery station
  Future<void> updateStationName(int sessionId, String stationName) async {
    await discoveryUpdateStationName(stationName, sessionId);
  }

  /// Update the YouTube ratio for a discovery station
  Future<void> updateStationYouTubeRatio(int sessionId, double ratio) async {
    await (update(discoverySessions)..where((tbl) => tbl.id.equals(sessionId)))
        .write(DiscoverySessionsCompanion(youtubeRatio: Value(ratio)));
  }

  /// Update the last played timestamp of a station
  Future<void> updateStationLastPlayed(int sessionId, DateTime timestamp) async {
    await discoveryUpdateLastPlayed(timestamp.millisecondsSinceEpoch ~/ 1000, sessionId);
  }

  /// Increment the play count of a station
  Future<void> incrementStationPlayCount(int sessionId) async {
    await discoveryIncrementPlayCount(sessionId);
  }

  /// Toggle the favorite status of a station
  Future<void> toggleStationFavorite(int sessionId, bool isFavorite) async {
    await discoveryToggleFavorite(isFavorite ? 1 : 0, sessionId);
  }

  /// Get all favorite stations for a source
  Future<List<DiscoverySession>> getFavoriteStations(int sourceId) async {
    return await discoveryFavoriteStations(sourceId).get();
  }

  /// Get stations sorted by most recently played
  Future<List<DiscoverySession>> getStationsSortedByRecent(int sourceId, {int limit = 20, int offset = 0}) async {
    return await discoveryStationsSortedByRecent(sourceId, limit, offset).get();
  }

  /// Get stations sorted by play count (most played first)
  Future<List<DiscoverySession>> getStationsSortedByPlayCount(int sourceId, {int limit = 20, int offset = 0}) async {
    return await discoveryStationsSortedByPlayCount(sourceId, limit, offset).get();
  }

  /// Get a single discovery session by ID
  Future<DiscoverySession?> getDiscoverySessionById(int sessionId) async {
    return await (select(discoverySessions)..where((tbl) => tbl.id.equals(sessionId))).getSingleOrNull();
  }

  /// Delete a discovery station and all its interactions
  /// The foreign key constraint with ON DELETE CASCADE will automatically
  /// delete all related interactions in the discovery_interactions table
  Future<void> deleteDiscoveryStation(int sessionId) async {
    await (delete(discoverySessions)..where((tbl) => tbl.id.equals(sessionId))).go();
  }

  // Station-specific personalization methods

  /// Get song IDs that were thumbs up in a specific station
  Future<Set<String>> getThumbsUpSongsForStation(int sessionId) async {
    final results = await discoveryThumbsUpSongsByStation(sessionId).get();
    return results.toSet();
  }

  /// Get song IDs that were thumbs down in a specific station
  Future<Set<String>> getThumbsDownSongsForStation(int sessionId) async {
    final results = await discoveryThumbsDownSongsByStation(sessionId).get();
    return results.toSet();
  }

  /// Get song IDs that were frequently skipped in a specific station (2+ times)
  Future<Set<String>> getFrequentlySkippedSongsForStation(int sessionId) async {
    // This query returns a result type with songId and skip_count
    final results = await discoverySkippedSongsByStation(sessionId).get();
    return results.map((r) => r.songId).toSet();
  }

  /// Get song IDs that were completed in a specific station
  Future<Set<String>> getCompletedSongsForStation(int sessionId) async {
    final results = await discoveryCompletedSongsByStation(sessionId).get();
    return results.toSet();
  }

  /// Remove a specific rating for a song in a discovery station
  Future<void> removeDiscoveryRating(int sessionId, String songId, String interactionType) async {
    await (delete(discoveryInteractions)
          ..where((tbl) =>
              tbl.sessionId.equals(sessionId) &
              tbl.songId.equals(songId) &
              tbl.interactionType.equals(interactionType)))
        .go();
  }

  /// Get songs with their interaction details for a station
  Future<List<DiscoveryInteraction>> getStationInteractionsBySongId(int sessionId, String songId) async {
    return await (select(discoveryInteractions)
          ..where((tbl) =>
              tbl.sessionId.equals(sessionId) &
              tbl.songId.equals(songId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.timestamp)]))
        .get();
  }

  // YouTube tracks management methods

  /// Get a YouTube track by video ID
  Future<YoutubeTrack?> getYouTubeTrack(String videoId) async {
    return await youTubeTrackById(videoId).getSingleOrNull();
  }

  /// Cache a YouTube track
  Future<void> cacheYouTubeTrack(YoutubeTracksCompanion track) async {
    await into(youtubeTracks).insertOnConflictUpdate(track);
  }

  /// Update access tracking for a YouTube track
  Future<void> updateYouTubeTrackAccess(String videoId) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await customStatement(
      'UPDATE youtube_tracks SET access_count = access_count + 1, last_accessed = ? WHERE id = ?',
      [now, videoId],
    );
  }

  /// Refresh the audio URL and expiry time for a YouTube track
  Future<void> refreshYouTubeTrackUrl(
    String videoId,
    String newUrl,
    DateTime expiresAt,
  ) async {
    await (update(youtubeTracks)..where((tbl) => tbl.id.equals(videoId))).write(
      YoutubeTracksCompanion(
        audioUrl: Value(newUrl),
        expiresAt: Value(expiresAt.millisecondsSinceEpoch ~/ 1000),
      ),
    );
  }

  /// Get YouTube tracks that are expiring soon
  Future<List<YoutubeTrack>> getExpiringYouTubeTracks(Duration beforeExpiry) async {
    final expiresBefore = DateTime.now().add(beforeExpiry).millisecondsSinceEpoch ~/ 1000;
    return await youTubeTracksExpiringSoon(expiresBefore).get();
  }

  /// Get expired YouTube tracks
  Future<List<YoutubeTrack>> getExpiredYouTubeTracks() async {
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return await youTubeTracksExpired(currentTime).get();
  }

  /// Delete all expired YouTube tracks from cache
  Future<void> deleteExpiredYouTubeTracks() async {
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await (delete(youtubeTracks)..where((tbl) => tbl.expiresAt.isSmallerThanValue(currentTime))).go();
  }

  /// Add a YouTube track to a discovery session
  Future<void> addYouTubeToDiscoverySession(
    int sessionId,
    String youtubeTrackId,
    int position,
  ) async {
    await into(youtubeDiscoveryItems).insert(
      YoutubeDiscoveryItemsCompanion.insert(
        sessionId: sessionId,
        youtubeTrackId: youtubeTrackId,
        positionInPlaylist: position,
      ),
    );
  }

  /// Get all YouTube tracks for a discovery session
  Future<List<YoutubeTrack>> getYouTubeTracksForSession(int sessionId) async {
    // This uses a custom query that joins youtube_tracks with youtube_discovery_items
    final results = await youTubeTracksForSession(sessionId).get();
    // Extract just the youtube track from the joined result
    return results.map((r) => YoutubeTrack(
      id: r.id,
      title: r.title,
      artist: r.artist,
      channelName: r.channelName,
      durationSeconds: r.durationSeconds,
      thumbnailUrl: r.thumbnailUrl,
      audioUrl: r.audioUrl,
      audioBitrate: r.audioBitrate,
      audioCodec: r.audioCodec,
      audioQuality: r.audioQuality,
      cachedAt: r.cachedAt,
      expiresAt: r.expiresAt,
      accessCount: r.accessCount,
      lastAccessed: r.lastAccessed,
    )).toList();
  }

  /// Get the count of cached YouTube tracks
  Future<int> getYouTubeCacheCount() async {
    return await youTubeCacheCount().getSingle();
  }

  /// Get cache size information
  Future<Map<String, int>> getYouTubeCacheSize() async {
    final result = await youTubeCacheSize().getSingle();
    return {
      'track_count': result.trackCount ?? 0,
      'approx_bytes': result.approxBytes ?? 0,
    };
  }

  /// Prune old/unused YouTube tracks from cache
  ///
  /// Keeps tracks that are:
  /// - Recently accessed (within maxAgeDays)
  /// - Frequently accessed (top maxEntries by access count)
  Future<void> pruneYouTubeCache({
    int maxEntries = 500,
    int maxAgeDays = 7,
  }) async {
    await transaction(() async {
      final cutoffTime = DateTime.now()
          .subtract(Duration(days: maxAgeDays))
          .millisecondsSinceEpoch ~/
          1000;

      // Get IDs of tracks to keep (recently accessed or frequently accessed)
      final recentTracks = await (select(youtubeTracks)
            ..where((tbl) => tbl.lastAccessed.isBiggerOrEqualValue(cutoffTime))
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.lastAccessed)])
            ..limit(maxEntries))
          .map((row) => row.id)
          .get();

      final frequentTracks = await (select(youtubeTracks)
            ..where((tbl) => tbl.accessCount.isBiggerThanValue(0))
            ..orderBy([
              (tbl) => OrderingTerm.desc(tbl.accessCount),
              (tbl) => OrderingTerm.desc(tbl.lastAccessed),
            ])
            ..limit(maxEntries))
          .map((row) => row.id)
          .get();

      final idsToKeep = {...recentTracks, ...frequentTracks};

      if (idsToKeep.isNotEmpty) {
        // Delete tracks not in the keep list
        await (delete(youtubeTracks)
              ..where((tbl) => tbl.id.isNotIn(idsToKeep)))
            .go();
      }
    });
  }

  /// Get most recently accessed YouTube tracks
  Future<List<YoutubeTrack>> getRecentYouTubeTracks({
    int limit = 20,
    int offset = 0,
  }) async {
    return await youTubeTracksByLastAccessed(limit, offset).get();
  }

  /// Get most frequently accessed YouTube tracks
  Future<List<YoutubeTrack>> getFrequentYouTubeTracks({
    int limit = 20,
    int offset = 0,
  }) async {
    return await youTubeTracksByAccessCount(limit, offset).get();
  }

  /// Delete a specific YouTube track from cache
  Future<void> deleteYouTubeTrack(String videoId) async {
    await (delete(youtubeTracks)..where((tbl) => tbl.id.equals(videoId))).go();
  }

  /// Get discovery sessions that used a specific YouTube track
  Future<List<DiscoverySession>> getDiscoverySessionsForYouTubeTrack(
    String youtubeTrackId,
  ) async {
    return await discoverySessionsForYouTubeTrack(youtubeTrackId).get();
  }

  // Lidarr download requests tracking methods

  /// Record a Lidarr download request
  Future<void> recordLidarrRequest({
    required String youtubeVideoId,
    required String artistName,
    required String? foreignArtistId,
    required String status,
    String? errorMessage,
  }) async {
    await into(lidarrRequests).insertOnConflictUpdate(
      LidarrRequestsCompanion.insert(
        youtubeVideoId: youtubeVideoId,
        artistName: artistName,
        foreignArtistId: Value(foreignArtistId),
        status: status,
        completedAt: Value(status == 'added' || status == 'already_exists'
            ? DateTime.now().millisecondsSinceEpoch ~/ 1000
            : null),
        errorMessage: Value(errorMessage),
      ),
    );
  }

  /// Get Lidarr request for a specific YouTube video
  Future<LidarrRequest?> getLidarrRequestForVideo(String videoId) async {
    return await lidarrRequestByVideoId(videoId).getSingleOrNull();
  }

  /// Get Lidarr requests by status
  Future<List<LidarrRequest>> getLidarrRequestsByStatus(
    String status, {
    int limit = 50,
    int offset = 0,
  }) async {
    return await lidarrRequestsByStatus(status, limit, offset).get();
  }

  /// Get recent Lidarr requests
  Future<List<LidarrRequest>> getRecentLidarrRequests({
    int limit = 50,
    int offset = 0,
  }) async {
    return await lidarrRequestsRecent(limit, offset).get();
  }

  /// Get count of all Lidarr requests
  Future<int> getLidarrRequestsCount() async {
    return await lidarrRequestsCount().getSingle();
  }

  /// Get count of Lidarr requests by status
  Future<Map<String, int>> getLidarrRequestsCountByStatus() async {
    final results = await lidarrRequestsCountByStatus().get();
    return Map.fromEntries(
      results.map((row) => MapEntry(row.status, row.count)),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'subtracks.sqlite'));
    // return NativeDatabase.createInBackground(file, logStatements: true);

    return ErrorLoggingDatabase(
      NativeDatabase.createInBackground(file),
      (e, s) => log.severe('SQL error', e, s),
    );
  });
}

@Riverpod(keepAlive: true)
SubtracksDatabase database(DatabaseRef ref) {
  return SubtracksDatabase();
}

OrderingTerm _buildOrder(SortBy sort) {
  OrderingMode? mode =
      sort.dir == SortDirection.asc ? OrderingMode.asc : OrderingMode.desc;
  return OrderingTerm(
    expression: CustomExpression(sort.column),
    mode: mode,
  );
}

SimpleSelectStatement<T, R> listQuery<T extends HasResultSet, R>(
  SimpleSelectStatement<T, R> query,
  ListQuery opt,
) {
  if (opt.page.limit > 0) {
    query.limit(opt.page.limit, offset: opt.page.offset);
  }

  if (opt.sort != null) {
    OrderingMode? mode = opt.sort != null && opt.sort!.dir == SortDirection.asc
        ? OrderingMode.asc
        : OrderingMode.desc;
    query.orderBy([
      (t) => OrderingTerm(
            expression: CustomExpression(opt.sort!.column),
            mode: mode,
          )
    ]);
  }

  for (var filter in opt.filters) {
    query.where((tbl) => buildFilter(filter));
  }

  return query;
}

JoinedSelectStatement<T, R> listQueryJoined<T extends HasResultSet, R>(
  JoinedSelectStatement<T, R> query,
  ListQuery opt,
) {
  if (opt.page.limit > 0) {
    query.limit(opt.page.limit, offset: opt.page.offset);
  }

  if (opt.sort != null) {
    OrderingMode? mode = opt.sort != null && opt.sort!.dir == SortDirection.asc
        ? OrderingMode.asc
        : OrderingMode.desc;
    query.orderBy([
      OrderingTerm(
        expression: CustomExpression(opt.sort!.column),
        mode: mode,
      )
    ]);
  }

  for (var filter in opt.filters) {
    query.where(buildFilter(filter));
  }

  return query;
}

CustomExpression<T> buildFilter<T extends Object>(
  FilterWith filter,
) {
  return filter.when(
    equals: (column, value, invert) => CustomExpression<T>(
      '$column ${invert ? '<>' : '='} \'$value\'',
    ),
    greaterThan: (column, value, orEquals) => CustomExpression<T>(
      '$column ${orEquals ? '>=' : '>'} $value',
    ),
    isNull: (column, invert) => CustomExpression<T>(
      '$column ${invert ? 'IS NOT' : 'IS'} NULL',
    ),
    betweenInt: (column, from, to) => CustomExpression<T>(
      '$column BETWEEN $from AND $to',
    ),
    isIn: (column, invert, values) => CustomExpression<T>(
      '$column ${invert ? 'NOT IN' : 'IN'} (${values.join(',')})',
    ),
  );
}

class AlbumSongsCompanion {
  final AlbumsCompanion album;
  final Iterable<SongsCompanion> songs;

  AlbumSongsCompanion(this.album, this.songs);
}

class ArtistAlbumsCompanion {
  final ArtistsCompanion artist;
  final Iterable<AlbumsCompanion> albums;

  ArtistAlbumsCompanion(this.artist, this.albums);
}

class PlaylistWithSongsCompanion {
  final PlaylistsCompanion playist;
  final Iterable<PlaylistSongsCompanion> songs;

  PlaylistWithSongsCompanion(this.playist, this.songs);
}

// Future<void> saveArtist(
//   SubtracksDatabase db,
//   ArtistAlbumsCompanion artistAlbums,
// ) async {
//   return db.background((db) async {
//     final artist = artistAlbums.artist;
//     final albums = artistAlbums.albums;

//     await db.batch((batch) {
//       batch.insertAllOnConflictUpdate(db.artists, [artist]);
//       batch.insertAllOnConflictUpdate(db.albums, albums);

//       // remove this artistId from albums not found in source
//       // don't delete them since they coud have been moved to another artist
//       // that we haven't synced yet
//       final albumIds = {for (var a in albums) a.id.value};
//       batch.update(
//         db.albums,
//         const AlbumsCompanion(artistId: Value(null)),
//         where: (tbl) =>
//             tbl.sourceId.equals(artist.sourceId.value) &
//             tbl.artistId.equals(artist.id.value) &
//             tbl.id.isNotIn(albumIds),
//       );
//     });
//   });
// }

// Future<void> saveAlbum(
//   SubtracksDatabase db,
//   AlbumSongsCompanion albumSongs,
// ) async {
//   return db.background((db) async {
//     final album = albumSongs.album.copyWith(synced: Value(DateTime.now()));
//     final songs = albumSongs.songs;

//     final songIds = {for (var a in songs) a.id.value};
//     final hardDeletedSongIds = (await (db.selectOnly(db.songs)
//               ..addColumns([db.songs.id])
//               ..where(
//                 db.songs.sourceId.equals(album.sourceId.value) &
//                     db.songs.albumId.equals(album.id.value) &
//                     db.songs.id.isNotIn(songIds) &
//                     db.songs.downloadFilePath.isNull() &
//                     db.songs.downloadTaskId.isNull(),
//               ))
//             .map((row) => row.read(db.songs.id))
//             .get())
//         .whereNotNull();

//     await db.batch((batch) {
//       batch.insertAllOnConflictUpdate(db.albums, [album]);
//       batch.insertAllOnConflictUpdate(db.songs, songs);

//       // soft delete songs that have been downloaded so that the user
//       // can decide to keep or remove them later
//       // TODO: add a setting to skip soft delete and just remove download too
//       batch.update(
//         db.songs,
//         const SongsCompanion(isDeleted: Value(true)),
//         where: (tbl) =>
//             tbl.sourceId.equals(album.sourceId.value) &
//             tbl.albumId.equals(album.id.value) &
//             tbl.id.isNotIn(songIds) &
//             (tbl.downloadFilePath.isNotNull() | tbl.downloadTaskId.isNotNull()),
//       );

//       // safe to hard delete songs that have not been downloaded
//       batch.deleteWhere(
//         db.songs,
//         (tbl) =>
//             tbl.sourceId.equals(album.sourceId.value) &
//             tbl.id.isIn(hardDeletedSongIds),
//       );

//       // also need to remove these songs from any playlists that contain them
//       batch.deleteWhere(
//         db.playlistSongs,
//         (tbl) =>
//             tbl.sourceId.equals(album.sourceId.value) &
//             tbl.songId.isIn(hardDeletedSongIds),
//       );
//     });
//   });
// }

// Future<void> savePlaylist(
//   SubtracksDatabase db,
//   PlaylistWithSongsCompanion playlistWithSongs,
// ) async {
//   return db.background((db) async {
//     final playlist =
//         playlistWithSongs.playist.copyWith(synced: Value(DateTime.now()));
//     final songs = playlistWithSongs.songs;

//     await db.batch((batch) {
//       batch.insertAllOnConflictUpdate(db.playlists, [playlist]);
//       batch.insertAllOnConflictUpdate(db.songs, songs);

//       batch.insertAllOnConflictUpdate(
//         db.playlistSongs,
//         songs.mapIndexed(
//           (index, song) => PlaylistSongsCompanion.insert(
//             sourceId: playlist.sourceId.value,
//             playlistId: playlist.id.value,
//             songId: song.id.value,
//             position: index,
//           ),
//         ),
//       );

//       // the new playlist could be shorter than the old one, so we delete
//       // playlist songs above our new playlist's length
//       batch.deleteWhere(
//         db.playlistSongs,
//         (tbl) =>
//             tbl.sourceId.equals(playlist.sourceId.value) &
//             tbl.playlistId.equals(playlist.id.value) &
//             tbl.position.isBiggerOrEqualValue(songs.length),
//       );
//     });
//   });
// }
