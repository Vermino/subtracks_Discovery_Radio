import 'dart:async';
import 'dart:collection';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/database.dart';
import '../log.dart';
import '../models/youtube_models.dart';
import 'youtube_discovery_service.dart';

part 'youtube_cache_service.g.dart';

/// Two-tier caching service for YouTube tracks
///
/// Provides:
/// - In-memory LRU cache for hot data (max 100 entries)
/// - Database persistence for all cached tracks
/// - Automatic URL expiry detection and refresh
/// - Background cleanup of expired/old tracks
/// - Proactive refresh of tracks expiring soon
///
/// Cache strategy:
/// 1. Check memory cache (fast)
/// 2. Check database cache (medium)
/// 3. Fetch from API and cache (slow)
@Riverpod(keepAlive: true)
class YouTubeCacheService extends _$YouTubeCacheService {
  // In-memory LRU cache
  final LinkedHashMap<String, YoutubeTrack> _memoryCache = LinkedHashMap();
  static const int _maxMemoryCacheSize = 100;

  // Track recent refreshes to prevent redundant API calls
  final Map<String, DateTime> _recentRefreshes = {};
  static const Duration _refreshCooldown = Duration(seconds: 10);

  // Background cleanup timer
  Timer? _cleanupTimer;
  Timer? _proactiveRefreshTimer;

  @override
  void build() {
    log.info('YouTubeCacheService initialized');
    _startBackgroundCleanup();
    _startProactiveRefresh();
  }

  /// Get a YouTube track with automatic URL refresh if expired
  ///
  /// Cache lookup order:
  /// 1. Memory cache (LRU)
  /// 2. Database cache
  /// 3. API fetch (if not cached or refresh needed)
  ///
  /// Parameters:
  /// - [videoId]: YouTube video ID
  /// - [refreshIfExpired]: Automatically refresh URL if expired (default: true)
  ///
  /// Returns cached track or null if not found
  Future<YoutubeTrack?> getTrack(
    String videoId, {
    bool refreshIfExpired = true,
  }) async {
    try {
      // Check memory cache first
      if (_memoryCache.containsKey(videoId)) {
        log.fine('Memory cache hit for video: $videoId');
        final track = _memoryCache[videoId]!;

        // Move to end (most recently used)
        _memoryCache.remove(videoId);
        _memoryCache[videoId] = track;

        // Check if URL is expired
        if (refreshIfExpired && _isExpired(track)) {
          log.info('Track URL expired in memory cache, refreshing: $videoId');
          return await _refreshTrackUrl(videoId, track);
        }

        // Update database access tracking
        _updateAccessTracking(videoId);
        return track;
      }

      // Check database cache
      final db = ref.read(databaseProvider);
      final cachedTrack = await db.getYouTubeTrack(videoId);

      if (cachedTrack != null) {
        log.fine('Database cache hit for video: $videoId');

        // Add to memory cache
        _addToMemoryCache(videoId, cachedTrack);

        // Check if URL is expired
        if (refreshIfExpired && _isExpired(cachedTrack)) {
          log.info('Track URL expired in database cache, refreshing: $videoId');
          return await _refreshTrackUrl(videoId, cachedTrack);
        }

        // Update access tracking
        await db.updateYouTubeTrackAccess(videoId);
        return cachedTrack;
      }

      log.fine('Cache miss for video: $videoId');
      return null;
    } catch (e, stackTrace) {
      log.severe('Error getting track from cache: $videoId', e, stackTrace);
      return null;
    }
  }

  /// Cache a YouTube track from search result and audio stream
  ///
  /// This creates a complete cache entry with metadata and audio URL
  ///
  /// Parameters:
  /// - [searchResult]: YouTube search result with video metadata
  /// - [audioStream]: Audio stream with URL and expiry info
  Future<void> cacheTrack(
    YouTubeSearchResult searchResult,
    YouTubeAudioStream audioStream,
  ) async {
    try {
      final now = DateTime.now();
      final db = ref.read(databaseProvider);

      final trackCompanion = YoutubeTracksCompanion.insert(
        id: searchResult.videoId,
        title: searchResult.title,
        artist: Value(searchResult.author),
        channelName: searchResult.author,
        durationSeconds: searchResult.lengthSeconds,
        thumbnailUrl: Value(searchResult.thumbnail),
        audioUrl: audioStream.url,
        audioBitrate: audioStream.bitrate,
        audioCodec: audioStream.codec,
        audioQuality: audioStream.audioQuality,
        cachedAt: now.millisecondsSinceEpoch ~/ 1000,
        expiresAt: audioStream.expiresAt.millisecondsSinceEpoch ~/ 1000,
        accessCount: const Value(0),
        lastAccessed: Value.absent(),
      );

      // Store in database
      await db.cacheYouTubeTrack(trackCompanion);

      // Get the full track data back
      final cachedTrack = await db.getYouTubeTrack(searchResult.videoId);
      if (cachedTrack != null) {
        // Add to memory cache
        _addToMemoryCache(searchResult.videoId, cachedTrack);

        log.info(
          'Cached YouTube track: ${searchResult.videoId} - ${searchResult.title} '
          '(expires: ${audioStream.expiresAt})',
        );
      }
    } catch (e, stackTrace) {
      log.severe(
        'Error caching track: ${searchResult.videoId}',
        e,
        stackTrace,
      );
    }
  }

  /// Refresh the audio URL for a specific track
  ///
  /// Fetches fresh stream URL from API and updates cache
  ///
  /// Parameters:
  /// - [videoId]: YouTube video ID to refresh
  ///
  /// Returns updated track or null if refresh failed
  Future<YoutubeTrack?> refreshTrackUrl(String videoId) async {
    try {
      // Check if we recently refreshed this video (within cooldown period)
      final lastRefresh = _recentRefreshes[videoId];
      if (lastRefresh != null) {
        final timeSinceRefresh = DateTime.now().difference(lastRefresh);
        if (timeSinceRefresh < _refreshCooldown) {
          log.fine(
              'Skipping refresh for $videoId (refreshed ${timeSinceRefresh.inSeconds}s ago)');
          // Return cached track instead
          return await getTrack(videoId, refreshIfExpired: false);
        }
      }

      log.info('Refreshing URL for video: $videoId');

      final youtubeService = ref.read(youTubeDiscoveryServiceProvider.notifier);
      final audioStream = await youtubeService.getAudioStream(videoId);

      if (audioStream == null) {
        log.warning('Failed to get audio stream for refresh: $videoId');
        return null;
      }

      final db = ref.read(databaseProvider);

      // Update database
      await db.refreshYouTubeTrackUrl(
        videoId,
        audioStream.url,
        audioStream.expiresAt,
      );

      // Get updated track
      final updatedTrack = await db.getYouTubeTrack(videoId);

      if (updatedTrack != null) {
        // Update memory cache
        _memoryCache[videoId] = updatedTrack;

        // Mark as recently refreshed
        _recentRefreshes[videoId] = DateTime.now();

        log.info(
          'Refreshed URL for video: $videoId '
          '(new expiry: ${audioStream.expiresAt})',
        );
      }

      return updatedTrack;
    } catch (e, stackTrace) {
      log.severe('Error refreshing track URL: $videoId', e, stackTrace);
      return null;
    }
  }

  /// Proactively refresh tracks that are expiring soon
  ///
  /// This runs in the background to refresh URLs before they expire,
  /// ensuring seamless playback without interruption
  ///
  /// Refreshes tracks expiring within 1 hour
  Future<void> refreshExpiringSoon() async {
    try {
      final db = ref.read(databaseProvider);
      final expiringTracks = await db.getExpiringYouTubeTracks(
        const Duration(hours: 1),
      );

      if (expiringTracks.isEmpty) {
        log.fine('No tracks expiring soon');
        return;
      }

      log.info('Refreshing ${expiringTracks.length} tracks expiring soon');

      for (final track in expiringTracks) {
        try {
          await refreshTrackUrl(track.id);
          // Add small delay to avoid rate limiting
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e) {
          log.warning('Failed to refresh expiring track: ${track.id}', e);
          continue;
        }
      }

      log.info('Completed proactive refresh of expiring tracks');
    } catch (e, stackTrace) {
      log.severe('Error in proactive refresh', e, stackTrace);
    }
  }

  /// Clean up expired tracks from cache
  ///
  /// Removes tracks with expired URLs from database
  /// Memory cache entries are retained if still valid
  Future<void> cleanupExpired() async {
    try {
      final db = ref.read(databaseProvider);
      final expiredTracks = await db.getExpiredYouTubeTracks();

      if (expiredTracks.isEmpty) {
        log.fine('No expired tracks to clean up');
        return;
      }

      log.info('Cleaning up ${expiredTracks.length} expired tracks');

      await db.deleteExpiredYouTubeTracks();

      // Remove from memory cache
      for (final track in expiredTracks) {
        _memoryCache.remove(track.id);
      }

      log.info('Cleaned up expired tracks from cache');
    } catch (e, stackTrace) {
      log.severe('Error cleaning up expired tracks', e, stackTrace);
    }
  }

  /// Prune old/unused entries from cache
  ///
  /// Removes tracks that haven't been accessed recently and aren't
  /// frequently used, keeping cache size manageable
  ///
  /// Parameters:
  /// - [maxEntries]: Maximum number of tracks to keep (default: 500)
  /// - [maxAgeDays]: Maximum age in days for tracks (default: 7)
  Future<void> pruneOldEntries({
    int maxEntries = 500,
    int maxAgeDays = 7,
  }) async {
    try {
      final db = ref.read(databaseProvider);
      final cacheSize = await db.getYouTubeCacheCount();

      if (cacheSize <= maxEntries) {
        log.fine('Cache size ($cacheSize) below threshold ($maxEntries)');
        return;
      }

      log.info('Pruning cache (current: $cacheSize, target: $maxEntries)');

      await db.pruneYouTubeCache(
        maxEntries: maxEntries,
        maxAgeDays: maxAgeDays,
      );

      final newSize = await db.getYouTubeCacheCount();
      log.info('Cache pruned: $cacheSize -> $newSize entries');

      // Clear memory cache to force reload of valid entries
      _memoryCache.clear();
    } catch (e, stackTrace) {
      log.severe('Error pruning cache', e, stackTrace);
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final db = ref.read(databaseProvider);
      final sizeInfo = await db.getYouTubeCacheSize();
      final expiringTracks = await db.getExpiringYouTubeTracks(
        const Duration(hours: 1),
      );

      return {
        'memory_cache_size': _memoryCache.length,
        'database_cache_size': sizeInfo['track_count'] ?? 0,
        'approx_bytes': sizeInfo['approx_bytes'] ?? 0,
        'tracks_expiring_soon': expiringTracks.length,
      };
    } catch (e) {
      log.warning('Error getting cache stats: $e');
      return {
        'memory_cache_size': _memoryCache.length,
        'database_cache_size': 0,
        'approx_bytes': 0,
        'tracks_expiring_soon': 0,
      };
    }
  }

  /// Clear all cache (memory and database)
  ///
  /// WARNING: This will delete all cached YouTube tracks
  Future<void> clearAllCache() async {
    try {
      log.warning('Clearing all YouTube cache');

      _memoryCache.clear();

      final db = ref.read(databaseProvider);
      await db.customStatement('DELETE FROM youtube_tracks');

      log.info('All cache cleared');
    } catch (e, stackTrace) {
      log.severe('Error clearing cache', e, stackTrace);
    }
  }

  // Private helper methods

  /// Add track to memory cache with LRU eviction
  void _addToMemoryCache(String videoId, YoutubeTrack track) {
    // Remove if already exists (to update position)
    _memoryCache.remove(videoId);

    // Add to end (most recently used)
    _memoryCache[videoId] = track;

    // Evict oldest entry if cache is full
    if (_memoryCache.length > _maxMemoryCacheSize) {
      final oldestKey = _memoryCache.keys.first;
      _memoryCache.remove(oldestKey);
      log.fine('Evicted from memory cache (LRU): $oldestKey');
    }
  }

  /// Check if track URL is expired or expiring soon
  bool _isExpired(YoutubeTrack track) {
    final expiryTime = DateTime.fromMillisecondsSinceEpoch(
      track.expiresAt * 1000,
    );
    final now = DateTime.now();

    // Consider expired if less than 5 minutes remaining
    return expiryTime.difference(now) < const Duration(minutes: 5);
  }

  /// Update access tracking in database (async, non-blocking)
  void _updateAccessTracking(String videoId) {
    // Fire and forget - don't wait for completion
    ref
        .read(databaseProvider)
        .updateYouTubeTrackAccess(videoId)
        .catchError((e) {
      log.warning('Failed to update access tracking for: $videoId', e);
    });
  }

  /// Refresh track URL with existing track data
  Future<YoutubeTrack?> _refreshTrackUrl(
    String videoId,
    YoutubeTrack existingTrack,
  ) async {
    final refreshed = await refreshTrackUrl(videoId);
    return refreshed ?? existingTrack; // Fallback to existing if refresh fails
  }

  /// Start background cleanup task
  ///
  /// Runs every 30 minutes to clean up expired tracks
  void _startBackgroundCleanup() {
    _cleanupTimer?.cancel();

    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) async {
        log.fine('Running background cleanup');
        await cleanupExpired();
        await pruneOldEntries();
      },
    );

    log.info('Background cleanup task started (interval: 30 minutes)');
  }

  /// Start proactive refresh task
  ///
  /// Runs every 30 minutes to refresh tracks expiring within 1 hour
  void _startProactiveRefresh() {
    _proactiveRefreshTimer?.cancel();

    _proactiveRefreshTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) async {
        log.fine('Running proactive URL refresh');
        await refreshExpiringSoon();
      },
    );

    log.info('Proactive refresh task started (interval: 30 minutes)');
  }

  /// Dispose resources
  void dispose() {
    _cleanupTimer?.cancel();
    _proactiveRefreshTimer?.cancel();
    _memoryCache.clear();
    log.fine('YouTubeCacheService disposed');
  }
}
