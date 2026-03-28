import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/youtube_config.dart';
import '../exceptions/youtube_exceptions.dart';
import '../log.dart';
import '../models/youtube_models.dart';

part 'youtube_discovery_service.g.dart';

/// Service for discovering music on YouTube using self-hosted Invidious API
///
/// This service provides:
/// - Music search functionality
/// - Audio stream URL extraction
/// - Rate limiting and retry logic
/// - Comprehensive error handling
@Riverpod(keepAlive: true)
class YouTubeDiscoveryService extends _$YouTubeDiscoveryService {
  late http.Client _httpClient;
  final List<DateTime> _requestTimestamps = [];

  @override
  void build() {
    _httpClient = http.Client();
    log.info('YouTubeDiscoveryService initialized with base URL: ${YouTubeConfig.invidiousBaseUrl}');
  }

  /// Inject HTTP client for testing
  void setHttpClient(http.Client client) {
    _httpClient = client;
  }

  /// Search for music videos on YouTube
  ///
  /// Parameters:
  /// - [query]: Search query (artist + song name recommended)
  /// - [limit]: Maximum number of results to return (default: 20)
  ///
  /// Returns list of search results or empty list on failure
  ///
  /// Example:
  /// ```dart
  /// final results = await service.searchMusic('Radiohead Creep', limit: 5);
  /// ```
  Future<List<YouTubeSearchResult>> searchMusic(
    String query, {
    int limit = 20,
  }) async {
    try {
      log.info('Searching YouTube for: "$query" (limit: $limit)');

      await _enforceRateLimit();

      final uri = Uri.parse(
        '${YouTubeConfig.invidiousBaseUrl}/api/v1/search',
      ).replace(queryParameters: {
        'q': query,
        'type': 'video',
      });

      final response = await _makeRequest(uri);
      final List<dynamic> jsonList = json.decode(response.body) as List<dynamic>;

      log.fine('Search returned ${jsonList.length} raw results');

      // Parse search results
      final results = <YouTubeSearchResult>[];
      for (final item in jsonList) {
        try {
          if (item is! Map<String, dynamic>) continue;

          final searchResponse = InvidiousSearchResponse.fromJson(item);

          // Filter: only include video type
          if (searchResponse.type != 'video') continue;

          // Filter: music content heuristics
          if (!_isVideoMusic(searchResponse)) {
            log.fine('Filtered out non-music video: ${searchResponse.title}');
            continue;
          }

          results.add(searchResponse.toSearchResult());

          if (results.length >= limit) break;
        } catch (e) {
          log.warning('Failed to parse search result item: $e');
          continue;
        }
      }

      log.info('Search completed: ${results.length} music videos found');
      return results;
    } on YouTubeServiceException {
      rethrow;
    } catch (e, stackTrace) {
      log.severe('Error searching YouTube', e, stackTrace);
      throw YouTubeServiceException(
        'Failed to search YouTube',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get audio stream URL for a specific video
  ///
  /// Parameters:
  /// - [videoId]: YouTube video ID
  ///
  /// Returns audio stream with URL and metadata, or null if no suitable stream found
  ///
  /// Example:
  /// ```dart
  /// final stream = await service.getAudioStream('dQw4w9WgXcQ');
  /// if (stream != null) {
  ///   print('Audio URL: ${stream.url}');
  ///   print('Bitrate: ${stream.bitrate}');
  /// }
  /// ```
  Future<YouTubeAudioStream?> getAudioStream(String videoId) async {
    try {
      log.info('Getting audio stream for video: $videoId');

      await _enforceRateLimit();

      final uri = Uri.parse(
        '${YouTubeConfig.invidiousBaseUrl}/api/v1/videos/$videoId',
      );

      final response = await _makeRequest(uri);
      final Map<String, dynamic> jsonData = json.decode(response.body) as Map<String, dynamic>;

      final videoResponse = InvidiousVideoResponse.fromJson(jsonData);
      final videoInfo = videoResponse.toVideoInfo();

      log.fine('Video has ${videoInfo.adaptiveFormats.length} audio formats available');

      // Extract best audio stream
      final audioStream = _extractBestAudioStream(videoInfo);

      if (audioStream != null) {
        log.info(
          'Selected audio stream: ${audioStream.bitrate} bps, '
          'quality: ${audioStream.audioQuality}, '
          'codec: ${audioStream.codec}',
        );
      } else {
        log.warning('No suitable audio stream found for video: $videoId');
      }

      return audioStream;
    } on VideoNotFoundException {
      rethrow;
    } on NoAudioStreamException {
      rethrow;
    } on YouTubeServiceException {
      rethrow;
    } catch (e, stackTrace) {
      log.severe('Error getting audio stream for video: $videoId', e, stackTrace);
      throw YouTubeServiceException(
        'Failed to get audio stream',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Search for music and get the best audio stream from top result
  ///
  /// This is a convenience method that combines search and stream extraction
  ///
  /// Parameters:
  /// - [artist]: Artist name
  /// - [song]: Song title
  ///
  /// Returns audio stream from best match, or null if no suitable video found
  ///
  /// Example:
  /// ```dart
  /// final stream = await service.searchAndGetBestAudio('Radiohead', 'Creep');
  /// if (stream != null) {
  ///   // Play the audio stream
  /// }
  /// ```
  Future<YouTubeAudioStream?> searchAndGetBestAudio(
    String artist,
    String song,
  ) async {
    try {
      log.info('Searching for audio: $artist - $song');

      // Search for the track
      final query = '$artist $song';
      final results = await searchMusic(query, limit: 5);

      if (results.isEmpty) {
        log.warning('No search results found for: $query');
        return null;
      }

      // Try to get audio stream from top results
      // Parallelize requests to find the best stream faster
      final futures = results.map((result) async {
        try {
          final stream = await getAudioStream(result.videoId);
          if (stream != null) {
            log.info('Found audio stream from: ${result.title}');
            return stream;
          }
        } catch (e) {
          log.warning('Failed to get stream for video ${result.videoId}: $e');
        }
        return null;
      }).toList();

      final stream = await _firstSuccess(futures);

      if (stream != null) {
        return stream;
      }

      log.warning('No audio stream found for any search result');
      return null;
    } catch (e, stackTrace) {
      log.severe('Error in searchAndGetBestAudio', e, stackTrace);
      return null;
    }
  }

  /// Check if Invidious service is available
  ///
  /// Returns true if service responds successfully
  Future<bool> isServiceAvailable() async {
    try {
      await _enforceRateLimit();

      final uri = Uri.parse('${YouTubeConfig.invidiousBaseUrl}/api/v1/stats');
      final response = await _httpClient
          .get(uri)
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      log.warning('Invidious service unavailable: $e');
      return false;
    }
  }

  /// Make HTTP request with retry logic
  Future<http.Response> _makeRequest(
    Uri uri, {
    int retryCount = 0,
  }) async {
    try {
      log.fine('Making request to: $uri');

      final response = await _httpClient
          .get(uri)
          .timeout(YouTubeConfig.requestTimeout);

      // Handle error status codes
      if (response.statusCode == 404) {
        // For search endpoint, 404 means no results found - return empty response
        // For video endpoint, 404 means video not found - throw exception
        if (uri.path.contains('/search')) {
          log.fine('Search returned 404 - no results found');
          return http.Response('[]', 200); // Return empty array
        } else {
          throw VideoNotFoundException(
            uri.pathSegments.last,
            responseBody: response.body,
          );
        }
      } else if (response.statusCode == 429) {
        throw const RateLimitException(
          YouTubeConfig.rateLimitPerSecond,
          Duration(seconds: 60),
        );
      } else if (response.statusCode >= 500) {
        throw InvidiousApiException(
          'Invidious server error',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      } else if (response.statusCode != 200) {
        throw InvidiousApiException(
          'Unexpected status code',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }

      return response;
    } on TimeoutException {
      if (retryCount < YouTubeConfig.maxRetries) {
        log.warning('Request timeout, retrying (${retryCount + 1}/${YouTubeConfig.maxRetries})');
        await Future.delayed(YouTubeConfig.retryDelay * (retryCount + 1));
        return _makeRequest(uri, retryCount: retryCount + 1);
      }
      throw const NetworkException(
        'Request timeout after ${YouTubeConfig.maxRetries} retries',
      );
    } on InvidiousApiException catch (e) {
      if (e.statusCode != null && e.statusCode! >= 500 && retryCount < YouTubeConfig.maxRetries) {
        log.warning('Server error, retrying (${retryCount + 1}/${YouTubeConfig.maxRetries})');
        await Future.delayed(YouTubeConfig.retryDelay * (retryCount + 1));
        return _makeRequest(uri, retryCount: retryCount + 1);
      }
      rethrow;
    } catch (e, stackTrace) {
      if (retryCount < YouTubeConfig.maxRetries) {
        log.warning('Request failed, retrying (${retryCount + 1}/${YouTubeConfig.maxRetries}): $e');
        await Future.delayed(YouTubeConfig.retryDelay * (retryCount + 1));
        return _makeRequest(uri, retryCount: retryCount + 1);
      }
      throw NetworkException(
        'Network request failed after ${YouTubeConfig.maxRetries} retries',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Enforce rate limiting using token bucket algorithm
  Future<void> _enforceRateLimit() async {
    final now = DateTime.now();

    // Remove timestamps older than 1 second
    _requestTimestamps.removeWhere(
      (timestamp) => now.difference(timestamp).inSeconds >= 1,
    );

    // Check if we've hit the rate limit
    if (_requestTimestamps.length >= YouTubeConfig.rateLimitPerSecond) {
      final oldestTimestamp = _requestTimestamps.first;
      final delay = const Duration(seconds: 1) - now.difference(oldestTimestamp);

      if (delay.inMilliseconds > 0) {
        log.fine('Rate limit reached, waiting ${delay.inMilliseconds}ms');
        await Future.delayed(delay);
      }

      // Clean up old timestamps after waiting
      _requestTimestamps.removeWhere(
        (timestamp) => DateTime.now().difference(timestamp).inSeconds >= 1,
      );
    }

    _requestTimestamps.add(DateTime.now());
  }

  /// Extract best audio stream from video info
  YouTubeAudioStream? _extractBestAudioStream(YouTubeVideoInfo videoInfo) {
    if (videoInfo.adaptiveFormats.isEmpty) {
      throw NoAudioStreamException(videoInfo.videoId);
    }

    // Score each audio format
    final scoredFormats = <({YouTubeAudioFormat format, double score})>[];

    for (final format in videoInfo.adaptiveFormats) {
      double score = 0.0;

      // Score by bitrate (higher is better)
      final bitrate = format.bitrate ?? 0;
      if (bitrate >= YouTubeConfig.minAudioBitrate) {
        score += (bitrate / 1000000.0) * 10; // Normalize to 0-10 range
      }

      // Score by audio quality
      final quality = format.audioQuality?.toUpperCase() ?? '';
      if (quality == 'AUDIO_QUALITY_HIGH') {
        score += 5.0;
      } else if (quality == 'AUDIO_QUALITY_MEDIUM') {
        score += 3.0;
      } else if (quality == 'AUDIO_QUALITY_LOW') {
        score += 1.0;
      }

      // Score by codec preference
      // Prefer MP4A (AAC) over Opus for better Android compatibility
      // Android MediaCodec handles AAC more reliably than Opus
      final codec = YouTubeAudioFormat.extractCodec(format.type) ?? '';
      if (codec.contains('mp4a')) {
        score += 3.0; // Prefer AAC for Android compatibility
      } else if (codec.contains('opus')) {
        score += 2.0; // Opus works but may have codec issues on some devices
      } else if (codec.contains('vorbis')) {
        score += 1.0;
      }

      scoredFormats.add((format: format, score: score));
    }

    // Sort by score (highest first)
    scoredFormats.sort((a, b) => b.score.compareTo(a.score));

    if (scoredFormats.isEmpty) {
      throw NoAudioStreamException(videoInfo.videoId);
    }

    final bestFormat = scoredFormats.first.format;

    // Calculate URL expiry time
    final expiresAt = _extractUrlExpiry(bestFormat.url);

    return YouTubeAudioStream(
      url: bestFormat.url,
      videoId: videoInfo.videoId,
      bitrate: bestFormat.bitrate ?? 0,
      audioQuality: bestFormat.audioQuality ?? 'UNKNOWN',
      audioSampleRate: int.tryParse(bestFormat.audioSampleRate ?? '0') ?? 0,
      codec: YouTubeAudioFormat.extractCodec(bestFormat.type) ?? 'unknown',
      expiresAt: expiresAt,
      container: bestFormat.container,
      contentLength: bestFormat.clen,
    );
  }

  /// Extract URL expiry time from YouTube stream URL
  ///
  /// YouTube URLs contain an 'expire' parameter with Unix timestamp
  DateTime _extractUrlExpiry(String url) {
    try {
      final uri = Uri.parse(url);
      final expireParam = uri.queryParameters['expire'];

      if (expireParam != null) {
        final expireTimestamp = int.parse(expireParam);
        return DateTime.fromMillisecondsSinceEpoch(expireTimestamp * 1000);
      }
    } catch (e) {
      log.warning('Failed to extract URL expiry time: $e');
    }

    // Default: assume 6 hours from now
    return DateTime.now().add(const Duration(hours: 6));
  }

  /// Filter out non-music content using heuristics
  bool _isVideoMusic(InvidiousSearchResponse result) {
    final titleLower = result.title.toLowerCase();
    final authorLower = result.author.toLowerCase();

    // Check for non-music keywords
    for (final keyword in YouTubeConfig.nonMusicKeywords) {
      if (titleLower.contains(keyword.toLowerCase())) {
        return false;
      }
    }

    // Check video duration (music typically 2-10 minutes)
    final duration = Duration(seconds: result.lengthSeconds);
    if (duration < YouTubeConfig.minMusicDuration ||
        duration > YouTubeConfig.maxMusicDuration) {
      return false;
    }

    // Boost confidence for official channels
    for (final suffix in YouTubeConfig.officialChannelSuffixes) {
      if (authorLower.endsWith(suffix.toLowerCase())) {
        return true;
      }
    }

    // Boost confidence for music keywords
    for (final keyword in YouTubeConfig.musicKeywords) {
      if (titleLower.contains(keyword.toLowerCase())) {
        return true;
      }
    }

    // Default: assume it's music if it passed basic filters
    return true;
  }

  /// Enhanced quality filtering for discovery playlists
  ///
  /// Uses a scoring system to rank videos by quality confidence.
  /// Higher scores indicate higher confidence that this is official,
  /// high-quality music content.
  ///
  /// Returns a quality score from 0.0 to 1.0, or null if should be filtered out
  double? _calculateQualityScore(InvidiousSearchResponse result) {
    final titleLower = result.title.toLowerCase();
    final authorLower = result.author.toLowerCase();
    double score = 0.5; // Start at neutral

    // Immediately reject non-music content
    if (!_isVideoMusic(result)) {
      return null;
    }

    // Strong indicators of official content (+0.3)
    if (authorLower.endsWith(' - topic')) {
      score += 0.3; // YouTube Music auto-generated topics
    } else if (authorLower.contains('vevo')) {
      score += 0.3; // VEVO official channels
    } else if (titleLower.contains('official audio') ||
               titleLower.contains('official video') ||
               titleLower.contains('official music video')) {
      score += 0.2;
    }

    // Negative indicators
    final lowQualityKeywords = [
      'cover', 'acoustic', 'live', 'karaoke', 'remix',
      'lyrics', 'slowed', 'sped up', '8d audio', 'bass boosted',
      'nightcore', 'mashup', 'reaction', 'tutorial', 'how to',
    ];

    for (final keyword in lowQualityKeywords) {
      if (titleLower.contains(keyword)) {
        score -= 0.4; // Strong penalty
        break; // Only apply once
      }
    }

    // View count bonus (if available)
    if (result.viewCount != null) {
      if (result.viewCount! > 10000000) {
        score += 0.1; // Very popular = likely official
      } else if (result.viewCount! > 1000000) {
        score += 0.05;
      }
    }

    // Duration sweet spot (3-5 minutes is typical for singles)
    final durationMins = result.lengthSeconds / 60;
    if (durationMins >= 3 && durationMins <= 5) {
      score += 0.1;
    }

    // Clamp score between 0 and 1
    return score.clamp(0.0, 1.0);
  }

  /// Filter and sort search results by quality
  ///
  /// Parameters:
  /// - [results]: Raw search results
  /// - [strictFilter]: If true, only return results with score >= 0.6
  /// - [preferOfficial]: If true, sort by quality score (high to low)
  ///
  /// Returns filtered and optionally sorted results
  List<YouTubeSearchResult> filterByQuality(
    List<YouTubeSearchResult> results, {
    bool strictFilter = true,
    bool preferOfficial = true,
  }) {
    // Convert to InvidiousSearchResponse for scoring
    final scoredResults = <({YouTubeSearchResult result, double score})>[];

    for (final result in results) {
      // Create a temporary InvidiousSearchResponse for scoring
      final response = InvidiousSearchResponse(
        type: 'video',
        videoId: result.videoId,
        title: result.title,
        author: result.author,
        lengthSeconds: result.lengthSeconds,
        description: result.description,
        viewCount: result.viewCount,
      );

      final score = _calculateQualityScore(response);
      if (score == null) continue; // Filtered out

      // Apply threshold if strict filtering
      if (strictFilter && score < 0.6) continue;

      scoredResults.add((result: result, score: score));
    }

    // Sort by score if preferOfficial is enabled
    if (preferOfficial) {
      scoredResults.sort((a, b) => b.score.compareTo(a.score));
    }

    return scoredResults.map((r) => r.result).toList();
  }

  /// Helper to return first successful future result
  Future<T?> _firstSuccess<T>(Iterable<Future<T?>> futures) {
    final completer = Completer<T?>();
    int pending = futures.length;

    if (pending == 0) return Future.value(null);

    for (final future in futures) {
      future.then((result) {
        if (result != null) {
          if (!completer.isCompleted) completer.complete(result);
        } else {
          pending--;
          if (pending == 0 && !completer.isCompleted) completer.complete(null);
        }
      }).catchError((Object e) {
        pending--;
        if (pending == 0 && !completer.isCompleted) completer.complete(null);
      });
    }

    return completer.future;
  }

  /// Dispose resources
  void dispose() {
    _httpClient.close();
    _requestTimestamps.clear();
    log.fine('YouTubeDiscoveryService disposed');
  }
}
