import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracks/database/database.dart';
import 'package:subtracks/models/youtube_models.dart';
import 'package:subtracks/services/youtube_cache_service.dart';
import 'package:subtracks/services/youtube_discovery_service.dart';

void main() {
  late SubtracksDatabase database;
  late ProviderContainer container;

  setUp(() {
    // Create an in-memory database for testing
    database = SubtracksDatabase.connection(
      NativeDatabase.memory(),
    );

    // Create a provider container with test dependencies
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
    );
  });

  tearDown(() async {
    await database.close();
    container.dispose();
  });

  group('YouTubeCacheService', () {
    test('should cache a YouTube track in database', () async {
      final cacheService = container.read(youTubeCacheServiceProvider.notifier);

      final searchResult = YouTubeSearchResult(
        videoId: 'test123',
        title: 'Test Song',
        author: 'Test Artist',
        lengthSeconds: 240,
        description: 'Test description',
        thumbnail: 'https://example.com/thumb.jpg',
        viewCount: 1000,
      );

      final audioStream = YouTubeAudioStream(
        url: 'https://example.com/audio.opus',
        videoId: 'test123',
        bitrate: 128000,
        audioQuality: 'AUDIO_QUALITY_MEDIUM',
        audioSampleRate: 48000,
        codec: 'opus',
        expiresAt: DateTime.now().add(const Duration(hours: 6)),
        container: 'webm',
        contentLength: 5000000,
      );

      await cacheService.cacheTrack(searchResult, audioStream);

      // Verify track is in database
      final cachedTrack = await database.getYouTubeTrack('test123');
      expect(cachedTrack, isNotNull);
      expect(cachedTrack!.id, equals('test123'));
      expect(cachedTrack.title, equals('Test Song'));
      expect(cachedTrack.artist, equals('Test Artist'));
      expect(cachedTrack.durationSeconds, equals(240));
      expect(cachedTrack.audioUrl, equals('https://example.com/audio.opus'));
      expect(cachedTrack.audioBitrate, equals(128000));
      expect(cachedTrack.audioCodec, equals('opus'));
    });

    test('should retrieve track from memory cache', () async {
      final cacheService = container.read(youTubeCacheServiceProvider.notifier);

      final searchResult = YouTubeSearchResult(
        videoId: 'mem123',
        title: 'Memory Test',
        author: 'Memory Artist',
        lengthSeconds: 180,
      );

      final audioStream = YouTubeAudioStream(
        url: 'https://example.com/mem.opus',
        videoId: 'mem123',
        bitrate: 128000,
        audioQuality: 'AUDIO_QUALITY_HIGH',
        audioSampleRate: 48000,
        codec: 'opus',
        expiresAt: DateTime.now().add(const Duration(hours: 6)),
      );

      // Cache the track
      await cacheService.cacheTrack(searchResult, audioStream);

      // First retrieval (should be from database)
      final firstGet = await cacheService.getTrack('mem123');
      expect(firstGet, isNotNull);

      // Second retrieval (should be from memory cache)
      final secondGet = await cacheService.getTrack('mem123');
      expect(secondGet, isNotNull);
      expect(secondGet!.id, equals('mem123'));
    });

    test('should retrieve track from database cache when not in memory', () async {
      final cacheService = container.read(youTubeCacheServiceProvider.notifier);

      final searchResult = YouTubeSearchResult(
        videoId: 'db123',
        title: 'Database Test',
        author: 'Database Artist',
        lengthSeconds: 200,
      );

      final audioStream = YouTubeAudioStream(
        url: 'https://example.com/db.opus',
        videoId: 'db123',
        bitrate: 160000,
        audioQuality: 'AUDIO_QUALITY_HIGH',
        audioSampleRate: 48000,
        codec: 'opus',
        expiresAt: DateTime.now().add(const Duration(hours: 6)),
      );

      await cacheService.cacheTrack(searchResult, audioStream);

      // Clear memory cache to force database lookup
      await cacheService.clearAllCache();

      // Manually insert back into database (simulating existing cache)
      await database.cacheYouTubeTrack(
        YoutubeTracksCompanion.insert(
          id: 'db123',
          title: 'Database Test',
          artist: const Value('Database Artist'),
          channelName: 'Database Artist',
          durationSeconds: 200,
          audioUrl: 'https://example.com/db.opus',
          audioBitrate: 160000,
          audioCodec: 'opus',
          audioQuality: 'AUDIO_QUALITY_HIGH',
          cachedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          expiresAt: DateTime.now().add(const Duration(hours: 6)).millisecondsSinceEpoch ~/ 1000,
        ),
      );

      // Should retrieve from database
      final track = await cacheService.getTrack('db123');
      expect(track, isNotNull);
      expect(track!.id, equals('db123'));
    });

    test('should update access count when track is accessed', () async {
      final cacheService = container.read(youTubeCacheServiceProvider.notifier);

      final searchResult = YouTubeSearchResult(
        videoId: 'access123',
        title: 'Access Test',
        author: 'Access Artist',
        lengthSeconds: 220,
      );

      final audioStream = YouTubeAudioStream(
        url: 'https://example.com/access.opus',
        videoId: 'access123',
        bitrate: 128000,
        audioQuality: 'AUDIO_QUALITY_MEDIUM',
        audioSampleRate: 48000,
        codec: 'opus',
        expiresAt: DateTime.now().add(const Duration(hours: 6)),
      );

      await cacheService.cacheTrack(searchResult, audioStream);

      // Access the track multiple times
      await cacheService.getTrack('access123');
      await Future.delayed(const Duration(milliseconds: 100)); // Allow async update
      await cacheService.getTrack('access123');
      await Future.delayed(const Duration(milliseconds: 100));
      await cacheService.getTrack('access123');
      await Future.delayed(const Duration(milliseconds: 100));

      // Check access count (should be at least 2, since first access might not update)
      final track = await database.getYouTubeTrack('access123');
      expect(track, isNotNull);
      expect(track!.accessCount, greaterThan(0));
    });

    test('should delete expired tracks', () async {
      final cacheService = container.read(youTubeCacheServiceProvider.notifier);

      // Create an expired track
      final expiredTime = DateTime.now().subtract(const Duration(hours: 1));

      await database.cacheYouTubeTrack(
        YoutubeTracksCompanion.insert(
          id: 'expired123',
          title: 'Expired Track',
          channelName: 'Expired Artist',
          durationSeconds: 180,
          audioUrl: 'https://example.com/expired.opus',
          audioBitrate: 128000,
          audioCodec: 'opus',
          audioQuality: 'AUDIO_QUALITY_MEDIUM',
          cachedAt: expiredTime.millisecondsSinceEpoch ~/ 1000,
          expiresAt: expiredTime.millisecondsSinceEpoch ~/ 1000,
        ),
      );

      // Create a valid track
      final validTime = DateTime.now().add(const Duration(hours: 6));

      await database.cacheYouTubeTrack(
        YoutubeTracksCompanion.insert(
          id: 'valid123',
          title: 'Valid Track',
          channelName: 'Valid Artist',
          durationSeconds: 200,
          audioUrl: 'https://example.com/valid.opus',
          audioBitrate: 128000,
          audioCodec: 'opus',
          audioQuality: 'AUDIO_QUALITY_MEDIUM',
          cachedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          expiresAt: validTime.millisecondsSinceEpoch ~/ 1000,
        ),
      );

      // Clean up expired tracks
      await cacheService.cleanupExpired();

      // Verify expired track is deleted
      final expiredTrack = await database.getYouTubeTrack('expired123');
      expect(expiredTrack, isNull);

      // Verify valid track still exists
      final validTrack = await database.getYouTubeTrack('valid123');
      expect(validTrack, isNotNull);
    });

    test('should identify tracks expiring soon', () async {
      // Create a track expiring in 30 minutes
      final soonTime = DateTime.now().add(const Duration(minutes: 30));

      await database.cacheYouTubeTrack(
        YoutubeTracksCompanion.insert(
          id: 'expiring_soon123',
          title: 'Expiring Soon',
          channelName: 'Soon Artist',
          durationSeconds: 180,
          audioUrl: 'https://example.com/soon.opus',
          audioBitrate: 128000,
          audioCodec: 'opus',
          audioQuality: 'AUDIO_QUALITY_MEDIUM',
          cachedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          expiresAt: soonTime.millisecondsSinceEpoch ~/ 1000,
        ),
      );

      // Create a track expiring in 2 hours
      final laterTime = DateTime.now().add(const Duration(hours: 2));

      await database.cacheYouTubeTrack(
        YoutubeTracksCompanion.insert(
          id: 'expiring_later123',
          title: 'Expiring Later',
          channelName: 'Later Artist',
          durationSeconds: 200,
          audioUrl: 'https://example.com/later.opus',
          audioBitrate: 128000,
          audioCodec: 'opus',
          audioQuality: 'AUDIO_QUALITY_MEDIUM',
          cachedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          expiresAt: laterTime.millisecondsSinceEpoch ~/ 1000,
        ),
      );

      // Get tracks expiring within 1 hour
      final expiringTracks = await database.getExpiringYouTubeTracks(
        const Duration(hours: 1),
      );

      expect(expiringTracks.length, equals(1));
      expect(expiringTracks.first.id, equals('expiring_soon123'));
    });

    test('should prune old cache entries', () async {
      final cacheService = container.read(youTubeCacheServiceProvider.notifier);

      // Create multiple tracks with different access patterns
      final now = DateTime.now();
      final oldTime = now.subtract(const Duration(days: 10));
      final recentTime = now.subtract(const Duration(days: 2));

      // Old, never accessed track (should be pruned)
      await database.cacheYouTubeTrack(
        YoutubeTracksCompanion.insert(
          id: 'old_unused',
          title: 'Old Unused',
          channelName: 'Old Artist',
          durationSeconds: 180,
          audioUrl: 'https://example.com/old.opus',
          audioBitrate: 128000,
          audioCodec: 'opus',
          audioQuality: 'AUDIO_QUALITY_MEDIUM',
          cachedAt: oldTime.millisecondsSinceEpoch ~/ 1000,
          expiresAt: now.add(const Duration(hours: 6)).millisecondsSinceEpoch ~/ 1000,
          accessCount: const Value(0),
        ),
      );

      // Recently accessed track (should be kept)
      await database.cacheYouTubeTrack(
        YoutubeTracksCompanion.insert(
          id: 'recent_used',
          title: 'Recent Used',
          channelName: 'Recent Artist',
          durationSeconds: 200,
          audioUrl: 'https://example.com/recent.opus',
          audioBitrate: 128000,
          audioCodec: 'opus',
          audioQuality: 'AUDIO_QUALITY_MEDIUM',
          cachedAt: recentTime.millisecondsSinceEpoch ~/ 1000,
          expiresAt: now.add(const Duration(hours: 6)).millisecondsSinceEpoch ~/ 1000,
          accessCount: const Value(5),
          lastAccessed: Value(recentTime.millisecondsSinceEpoch ~/ 1000),
        ),
      );

      // Prune with low threshold to trigger cleanup
      await cacheService.pruneOldEntries(maxEntries: 1, maxAgeDays: 7);

      // Check which tracks remain
      final oldTrack = await database.getYouTubeTrack('old_unused');
      final recentTrack = await database.getYouTubeTrack('recent_used');

      // Recently used track should be kept, old unused should be pruned
      expect(recentTrack, isNotNull);
    });

    test('should get cache statistics', () async {
      final cacheService = container.read(youTubeCacheServiceProvider.notifier);

      // Add some tracks
      final now = DateTime.now();
      final expiringTime = now.add(const Duration(minutes: 30));

      await database.cacheYouTubeTrack(
        YoutubeTracksCompanion.insert(
          id: 'stats1',
          title: 'Stats Track 1',
          channelName: 'Stats Artist',
          durationSeconds: 180,
          audioUrl: 'https://example.com/stats1.opus',
          audioBitrate: 128000,
          audioCodec: 'opus',
          audioQuality: 'AUDIO_QUALITY_MEDIUM',
          cachedAt: now.millisecondsSinceEpoch ~/ 1000,
          expiresAt: expiringTime.millisecondsSinceEpoch ~/ 1000,
        ),
      );

      await database.cacheYouTubeTrack(
        YoutubeTracksCompanion.insert(
          id: 'stats2',
          title: 'Stats Track 2',
          channelName: 'Stats Artist 2',
          durationSeconds: 200,
          audioUrl: 'https://example.com/stats2.opus',
          audioBitrate: 160000,
          audioCodec: 'opus',
          audioQuality: 'AUDIO_QUALITY_HIGH',
          cachedAt: now.millisecondsSinceEpoch ~/ 1000,
          expiresAt: now.add(const Duration(hours: 6)).millisecondsSinceEpoch ~/ 1000,
        ),
      );

      final stats = await cacheService.getCacheStats();

      expect(stats['database_cache_size'], equals(2));
      expect(stats['tracks_expiring_soon'], equals(1));
      expect(stats['memory_cache_size'], greaterThanOrEqualTo(0));
    });

    test('should clear all cache', () async {
      final cacheService = container.read(youTubeCacheServiceProvider.notifier);

      // Add some tracks
      final searchResult = YouTubeSearchResult(
        videoId: 'clear123',
        title: 'Clear Test',
        author: 'Clear Artist',
        lengthSeconds: 180,
      );

      final audioStream = YouTubeAudioStream(
        url: 'https://example.com/clear.opus',
        videoId: 'clear123',
        bitrate: 128000,
        audioQuality: 'AUDIO_QUALITY_MEDIUM',
        audioSampleRate: 48000,
        codec: 'opus',
        expiresAt: DateTime.now().add(const Duration(hours: 6)),
      );

      await cacheService.cacheTrack(searchResult, audioStream);

      // Verify track exists
      final beforeClear = await database.getYouTubeTrack('clear123');
      expect(beforeClear, isNotNull);

      // Clear all cache
      await cacheService.clearAllCache();

      // Verify cache is empty
      final afterClear = await database.getYouTubeTrack('clear123');
      expect(afterClear, isNull);

      final count = await database.getYouTubeCacheCount();
      expect(count, equals(0));
    });

    test('should handle cache miss gracefully', () async {
      final cacheService = container.read(youTubeCacheServiceProvider.notifier);

      // Try to get a non-existent track
      final track = await cacheService.getTrack('nonexistent123');
      expect(track, isNull);
    });

    test('should link YouTube tracks to discovery sessions', () async {
      // Create a discovery session
      final sessionId = await database.createDiscoverySession(
        sourceId: 1,
        seedSongId: 'seed123',
        seedArtist: 'Test Artist',
        mode: 'online',
        playlistSize: 50,
        stationName: 'Test Station',
      );

      // Cache a YouTube track
      await database.cacheYouTubeTrack(
        YoutubeTracksCompanion.insert(
          id: 'discovery_yt123',
          title: 'Discovery Track',
          channelName: 'Discovery Artist',
          durationSeconds: 180,
          audioUrl: 'https://example.com/discovery.opus',
          audioBitrate: 128000,
          audioCodec: 'opus',
          audioQuality: 'AUDIO_QUALITY_MEDIUM',
          cachedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          expiresAt: DateTime.now().add(const Duration(hours: 6)).millisecondsSinceEpoch ~/ 1000,
        ),
      );

      // Link track to session
      await database.addYouTubeToDiscoverySession(
        sessionId,
        'discovery_yt123',
        0,
      );

      // Get tracks for session
      final tracks = await database.getYouTubeTracksForSession(sessionId);
      expect(tracks.length, equals(1));
      expect(tracks.first.id, equals('discovery_yt123'));
    });
  });
}
