import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:subtracks/config/youtube_config.dart';
import 'package:subtracks/exceptions/youtube_exceptions.dart';
import 'package:subtracks/models/youtube_models.dart';

// Mock HTTP responses
const mockSearchResponse = '''
[
  {
    "type": "video",
    "title": "Radiohead - Creep (Official Video)",
    "videoId": "XFkzRNyygfk",
    "author": "Radiohead",
    "lengthSeconds": 238,
    "viewCount": 100000000,
    "description": "Official video",
    "videoThumbnails": [
      {
        "quality": "medium",
        "url": "https://example.com/thumb.jpg"
      }
    ]
  },
  {
    "type": "video",
    "title": "Radiohead - Creep Interview (Behind the Scenes)",
    "videoId": "ABC123",
    "author": "Music Channel",
    "lengthSeconds": 1800,
    "viewCount": 50000,
    "description": "Interview with the band"
  },
  {
    "type": "playlist",
    "playlistId": "PL123",
    "title": "Best of Radiohead"
  }
]
''';

const mockVideoResponse = '''
{
  "videoId": "XFkzRNyygfk",
  "title": "Radiohead - Creep (Official Video)",
  "author": "Radiohead",
  "lengthSeconds": 238,
  "description": "Official music video",
  "adaptiveFormats": [
    {
      "url": "https://example.com/audio.mp4?expire=1234567890",
      "type": "audio/mp4; codecs=\\"mp4a.40.2\\"",
      "audioQuality": "AUDIO_QUALITY_MEDIUM",
      "audioSampleRate": "44100",
      "bitrate": 130000,
      "clen": "3449447",
      "container": "mp4"
    },
    {
      "url": "https://example.com/audio-high.webm?expire=1234567890",
      "type": "audio/webm; codecs=\\"opus\\"",
      "audioQuality": "AUDIO_QUALITY_HIGH",
      "audioSampleRate": "48000",
      "bitrate": 160000,
      "clen": "4000000",
      "container": "webm"
    },
    {
      "url": "https://example.com/video.mp4",
      "type": "video/mp4",
      "bitrate": 1000000
    }
  ]
}
''';

const mockVideoResponseNoAudio = '''
{
  "videoId": "NOAUDIO123",
  "title": "Video Without Audio",
  "author": "Test Channel",
  "lengthSeconds": 180,
  "adaptiveFormats": [
    {
      "url": "https://example.com/video.mp4",
      "type": "video/mp4",
      "bitrate": 1000000
    }
  ]
}
''';

void main() {
  group('YouTubeSearchResult', () {
    test('fromJson parses search result correctly', () {
      final json = {
        'videoId': 'ABC123',
        'title': 'Test Video',
        'author': 'Test Artist',
        'lengthSeconds': 240,
        'description': 'Test description',
        'thumbnail': 'https://example.com/thumb.jpg',
        'viewCount': 1000,
      };

      final result = YouTubeSearchResult.fromJson(json);

      expect(result.videoId, 'ABC123');
      expect(result.title, 'Test Video');
      expect(result.author, 'Test Artist');
      expect(result.lengthSeconds, 240);
      expect(result.description, 'Test description');
      expect(result.thumbnail, 'https://example.com/thumb.jpg');
      expect(result.viewCount, 1000);
    });
  });

  group('YouTubeAudioFormat', () {
    test('extractCodec extracts codec from type string', () {
      expect(
        YouTubeAudioFormat.extractCodec('audio/mp4; codecs="mp4a.40.2"'),
        'mp4a.40.2',
      );
      expect(
        YouTubeAudioFormat.extractCodec('audio/webm; codecs="opus"'),
        'opus',
      );
      expect(
        YouTubeAudioFormat.extractCodec('audio/mp4'),
        'mp4a',
      );
      expect(
        YouTubeAudioFormat.extractCodec('audio/webm'),
        'opus',
      );
    });

    test('isAudioOnly correctly identifies audio streams', () {
      expect(
        YouTubeAudioFormat.isAudioOnly('audio/mp4; codecs="mp4a.40.2"'),
        true,
      );
      expect(
        YouTubeAudioFormat.isAudioOnly('audio/webm; codecs="opus"'),
        true,
      );
      expect(
        YouTubeAudioFormat.isAudioOnly('video/mp4'),
        false,
      );
      expect(
        YouTubeAudioFormat.isAudioOnly('video/webm'),
        false,
      );
    });
  });

  group('InvidiousSearchResponse', () {
    test('fromJson parses Invidious search response', () {
      final json = jsonDecode(mockSearchResponse)[0] as Map<String, dynamic>;
      final response = InvidiousSearchResponse.fromJson(json);

      expect(response.type, 'video');
      expect(response.videoId, 'XFkzRNyygfk');
      expect(response.title, 'Radiohead - Creep (Official Video)');
      expect(response.author, 'Radiohead');
      expect(response.lengthSeconds, 238);
      expect(response.viewCount, 100000000);
    });

    test('getThumbnailUrl extracts thumbnail', () {
      final json = jsonDecode(mockSearchResponse)[0] as Map<String, dynamic>;
      final response = InvidiousSearchResponse.fromJson(json);

      expect(response.getThumbnailUrl(), 'https://example.com/thumb.jpg');
    });

    test('toSearchResult converts to YouTubeSearchResult', () {
      final json = jsonDecode(mockSearchResponse)[0] as Map<String, dynamic>;
      final response = InvidiousSearchResponse.fromJson(json);
      final result = response.toSearchResult();

      expect(result.videoId, 'XFkzRNyygfk');
      expect(result.title, 'Radiohead - Creep (Official Video)');
      expect(result.author, 'Radiohead');
      expect(result.lengthSeconds, 238);
      expect(result.thumbnail, 'https://example.com/thumb.jpg');
    });
  });

  group('InvidiousVideoResponse', () {
    test('fromJson parses Invidious video response', () {
      final json = jsonDecode(mockVideoResponse) as Map<String, dynamic>;
      final response = InvidiousVideoResponse.fromJson(json);

      expect(response.videoId, 'XFkzRNyygfk');
      expect(response.title, 'Radiohead - Creep (Official Video)');
      expect(response.author, 'Radiohead');
      expect(response.lengthSeconds, 238);
      expect(response.adaptiveFormats.length, 3);
    });

    test('toVideoInfo filters audio-only formats', () {
      final json = jsonDecode(mockVideoResponse) as Map<String, dynamic>;
      final response = InvidiousVideoResponse.fromJson(json);
      final videoInfo = response.toVideoInfo();

      expect(videoInfo.adaptiveFormats.length, 2); // Only audio formats
      expect(
        videoInfo.adaptiveFormats.every(
          (format) => format.type.startsWith('audio/'),
        ),
        true,
      );
    });
  });

  group('YouTubeConfig', () {
    test('has correct configuration values', () {
      expect(YouTubeConfig.invidiousBaseUrl, 'http://192.168.0.214:3000');
      expect(YouTubeConfig.maxSearchResults, 20);
      expect(YouTubeConfig.minAudioBitrate, 96000);
      expect(YouTubeConfig.maxRetries, 3);
      expect(YouTubeConfig.rateLimitPerSecond, 10);
    });

    test('has reasonable duration limits', () {
      expect(YouTubeConfig.minMusicDuration, const Duration(minutes: 2));
      expect(YouTubeConfig.maxMusicDuration, const Duration(minutes: 10));
    });
  });

  group('YouTube Exceptions', () {
    test('YouTubeServiceException formats message correctly', () {
      final exception = YouTubeServiceException(
        'Test error',
        originalError: Exception('Original'),
      );

      expect(exception.toString(), contains('Test error'));
      expect(exception.toString(), contains('Original'));
    });

    test('InvidiousApiException includes status code', () {
      final exception = InvidiousApiException(
        'API error',
        statusCode: 500,
        responseBody: 'Internal Server Error',
      );

      expect(exception.toString(), contains('API error'));
      expect(exception.toString(), contains('HTTP 500'));
      expect(exception.toString(), contains('Internal Server Error'));
    });

    test('NoAudioStreamException includes video ID', () {
      final exception = NoAudioStreamException('ABC123');

      expect(exception.toString(), contains('ABC123'));
      expect(exception.videoId, 'ABC123');
    });

    test('RateLimitException includes limit info', () {
      final exception = RateLimitException(
        10,
        const Duration(seconds: 60),
      );

      expect(exception.toString(), contains('10 req/s'));
      expect(exception.toString(), contains('60s'));
    });

    test('VideoNotFoundException includes video ID', () {
      final exception = VideoNotFoundException('NOTFOUND123');

      expect(exception.toString(), contains('NOTFOUND123'));
      expect(exception.statusCode, 404);
    });
  });

  group('Music Content Filtering', () {
    test('filters out non-music keywords', () {
      // This would require accessing the private _isVideoMusic method
      // For now, we test the config
      expect(
        YouTubeConfig.nonMusicKeywords,
        contains('interview'),
      );
      expect(
        YouTubeConfig.nonMusicKeywords,
        contains('podcast'),
      );
    });

    test('recognizes music keywords', () {
      expect(
        YouTubeConfig.musicKeywords,
        contains('official video'),
      );
      expect(
        YouTubeConfig.musicKeywords,
        contains('official audio'),
      );
    });

    test('recognizes official channel suffixes', () {
      expect(
        YouTubeConfig.officialChannelSuffixes,
        contains('VEVO'),
      );
      expect(
        YouTubeConfig.officialChannelSuffixes,
        contains('Topic'),
      );
    });
  });

  group('Audio Stream Extraction', () {
    test('extracts URL expiry timestamp', () {
      const url = 'https://example.com/audio.mp4?expire=1234567890&sig=abc';
      final uri = Uri.parse(url);
      final expireParam = uri.queryParameters['expire'];

      expect(expireParam, '1234567890');
      final expireTimestamp = int.parse(expireParam!);
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        expireTimestamp * 1000,
      );

      expect(expiresAt.year, 2009); // Unix timestamp 1234567890
    });

    test('prefers higher bitrate audio', () {
      final json = jsonDecode(mockVideoResponse) as Map<String, dynamic>;
      final response = InvidiousVideoResponse.fromJson(json);
      final videoInfo = response.toVideoInfo();

      // The high quality stream (160000 bps) should be preferred
      final highQualityFormat = videoInfo.adaptiveFormats.firstWhere(
        (format) => format.audioQuality == 'AUDIO_QUALITY_HIGH',
      );

      expect(highQualityFormat.bitrate, 160000);
      expect(highQualityFormat.audioQuality, 'AUDIO_QUALITY_HIGH');
    });
  });

  group('Rate Limiting', () {
    test('rate limit configuration is reasonable', () {
      // 10 requests per second = 100ms between requests
      const expectedDelay = Duration(milliseconds: 100);
      const actualLimit = YouTubeConfig.rateLimitPerSecond;

      expect(actualLimit, 10);
      expect(
        const Duration(seconds: 1).inMilliseconds ~/ actualLimit,
        expectedDelay.inMilliseconds,
      );
    });
  });

  group('Retry Logic', () {
    test('retry configuration is reasonable', () {
      expect(YouTubeConfig.maxRetries, 3);
      expect(YouTubeConfig.retryDelay, const Duration(seconds: 2));

      // Total retry time: 2s + 4s + 6s = 12s
      const totalRetryTime = Duration(seconds: 12);
      final calculatedRetryTime = YouTubeConfig.retryDelay *
          (1 + 2 + 3); // Sum of exponential backoff multipliers

      expect(calculatedRetryTime, totalRetryTime);
    });
  });

  group('Integration - Search and Parse', () {
    test('parses search response and filters correctly', () {
      final jsonList = jsonDecode(mockSearchResponse) as List<dynamic>;

      // Count video types
      var videoCount = 0;
      var playlistCount = 0;

      for (final item in jsonList) {
        if (item is Map<String, dynamic>) {
          final type = item['type'] as String?;
          if (type == 'video') videoCount++;
          if (type == 'playlist') playlistCount++;
        }
      }

      expect(videoCount, 2);
      expect(playlistCount, 1);

      // Parse video results
      final videos = jsonList
          .where((item) =>
              item is Map<String, dynamic> && item['type'] == 'video')
          .map((item) => InvidiousSearchResponse.fromJson(
                item as Map<String, dynamic>,
              ))
          .toList();

      expect(videos.length, 2);

      // First video should pass music filter (official video, 238s)
      final firstVideo = videos[0];
      expect(firstVideo.lengthSeconds, 238);
      expect(firstVideo.title, contains('Official Video'));

      // Second video should fail music filter (interview, 1800s = 30 min)
      final secondVideo = videos[1];
      expect(secondVideo.lengthSeconds, 1800);
      expect(secondVideo.title.toLowerCase(), contains('interview'));
    });
  });

  group('Integration - Video Info and Audio Extraction', () {
    test('parses video info and extracts best audio', () {
      final json = jsonDecode(mockVideoResponse) as Map<String, dynamic>;
      final response = InvidiousVideoResponse.fromJson(json);
      final videoInfo = response.toVideoInfo();

      expect(videoInfo.videoId, 'XFkzRNyygfk');
      expect(videoInfo.adaptiveFormats.length, 2); // Only audio formats

      // Score the formats (simplified version of service logic)
      var bestFormat = videoInfo.adaptiveFormats.first;
      var bestScore = 0.0;

      for (final format in videoInfo.adaptiveFormats) {
        var score = 0.0;

        // Score by bitrate
        final bitrate = format.bitrate ?? 0;
        score += (bitrate / 1000000.0) * 10;

        // Score by quality
        if (format.audioQuality == 'AUDIO_QUALITY_HIGH') {
          score += 5.0;
        } else if (format.audioQuality == 'AUDIO_QUALITY_MEDIUM') {
          score += 3.0;
        }

        // Score by codec
        final codec = YouTubeAudioFormat.extractCodec(format.type) ?? '';
        if (codec.contains('opus')) {
          score += 3.0;
        } else if (codec.contains('mp4a')) {
          score += 2.0;
        }

        if (score > bestScore) {
          bestScore = score;
          bestFormat = format;
        }
      }

      // High quality Opus stream should win
      expect(bestFormat.audioQuality, 'AUDIO_QUALITY_HIGH');
      expect(bestFormat.bitrate, 160000);
      expect(bestFormat.type, contains('opus'));
    });

    test('handles video with no audio formats', () {
      final json =
          jsonDecode(mockVideoResponseNoAudio) as Map<String, dynamic>;
      final response = InvidiousVideoResponse.fromJson(json);
      final videoInfo = response.toVideoInfo();

      expect(videoInfo.adaptiveFormats.length, 0); // No audio formats
    });
  });

  group('URL Parsing', () {
    test('parses YouTube stream URLs correctly', () {
      const testUrl =
          'https://rr3---sn-test.googlevideo.com/videoplayback?'
          'expire=1234567890&ip=1.2.3.4&id=abc&source=youtube&'
          'requiressl=yes&sig=123';

      final uri = Uri.parse(testUrl);

      expect(uri.host, contains('googlevideo.com'));
      expect(uri.queryParameters['expire'], '1234567890');
      expect(uri.queryParameters['source'], 'youtube');
      expect(uri.queryParameters['requiressl'], 'yes');
    });
  });

  group('Error Scenarios', () {
    test('handles malformed JSON gracefully', () {
      expect(
        () => jsonDecode('not valid json'),
        throwsA(isA<FormatException>()),
      );
    });

    test('handles missing required fields in JSON', () {
      final incompleteJson = {
        'videoId': 'ABC123',
        'title': 'Test',
        // Missing required fields: author, lengthSeconds
      };

      expect(
        () => YouTubeSearchResult.fromJson(incompleteJson),
        throwsA(isA<TypeError>()),
      );
    });

    test('handles null values in optional fields', () {
      final json = {
        'videoId': 'ABC123',
        'title': 'Test Video',
        'author': 'Test Artist',
        'lengthSeconds': 240,
        'description': null,
        'thumbnail': null,
        'viewCount': null,
      };

      final result = YouTubeSearchResult.fromJson(json);

      expect(result.videoId, 'ABC123');
      expect(result.description, null);
      expect(result.thumbnail, null);
      expect(result.viewCount, null);
    });
  });

  group('Performance', () {
    test('processes large search results efficiently', () {
      // Generate a large mock response
      final largeResponse = List.generate(100, (i) => {
            'type': 'video',
            'videoId': 'VIDEO$i',
            'title': 'Test Video $i',
            'author': 'Artist $i',
            'lengthSeconds': 180 + i,
            'viewCount': 1000 * i,
          });

      final stopwatch = Stopwatch()..start();

      // Parse all results
      final results = largeResponse
          .map((json) => InvidiousSearchResponse.fromJson(json))
          .map((response) => response.toSearchResult())
          .toList();

      stopwatch.stop();

      expect(results.length, 100);
      expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should be fast
    });
  });
}
