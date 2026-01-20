import 'dart:convert';
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:subtracks/services/youtube_discovery_service.dart';

// Mock data
const mockSearchResponse = '''
[
  {
    "type": "video",
    "title": "Video 1",
    "videoId": "VIDEO1",
    "author": "Artist",
    "lengthSeconds": 180,
    "viewCount": 1000,
    "description": "Desc"
  },
  {
    "type": "video",
    "title": "Video 2",
    "videoId": "VIDEO2",
    "author": "Artist",
    "lengthSeconds": 180,
    "viewCount": 1000,
    "description": "Desc"
  }
]
''';

const mockVideoResponse1 = '''
{
  "videoId": "VIDEO1",
  "title": "Video 1",
  "author": "Artist",
  "lengthSeconds": 180,
  "adaptiveFormats": [
    {
      "url": "https://example.com/audio1.mp4",
      "type": "audio/mp4; codecs=\\"mp4a.40.2\\"",
      "bitrate": 130000
    }
  ]
}
''';

const mockVideoResponse2 = '''
{
  "videoId": "VIDEO2",
  "title": "Video 2",
  "author": "Artist",
  "lengthSeconds": 180,
  "adaptiveFormats": [
    {
      "url": "https://example.com/audio2.mp4",
      "type": "audio/mp4; codecs=\\"mp4a.40.2\\"",
      "bitrate": 130000
    }
  ]
}
''';

void main() {
  test('Benchmark searchAndGetBestAudio sequential vs parallel', () async {
    final container = ProviderContainer();
    final service = container.read(youTubeDiscoveryServiceProvider.notifier);

    // Setup mock client
    final client = MockClient((request) async {
      if (request.url.path.contains('/search')) {
        return http.Response(mockSearchResponse, 200);
      } else if (request.url.path.contains('/videos/VIDEO1')) {
        // VIDEO1 is slow
        await Future.delayed(const Duration(seconds: 1));
        return http.Response(mockVideoResponse1, 200);
      } else if (request.url.path.contains('/videos/VIDEO2')) {
        // VIDEO2 is slow
        await Future.delayed(const Duration(seconds: 1));
        return http.Response(mockVideoResponse2, 200);
      }
      return http.Response('', 404);
    });

    service.setHttpClient(client);

    final stopwatch = Stopwatch()..start();
    final result = await service.searchAndGetBestAudio('Artist', 'Song');
    stopwatch.stop();

    expect(result, isNotNull);

    // In sequential execution:
    // 1. Search (fast)
    // 2. VIDEO1 (1s) -> Success. Returns.
    // Total ~1s.

    // Wait, if the first one succeeds, sequential is fast too!
    // I need the first one to FAIL or be SLOWER than the second one if I want to show parallel benefits for "first success" where the first one fails.
    // Or if I want to find *any* success.

    // If VIDEO1 fails (e.g. 404 or exception) after 1s.
    // And VIDEO2 succeeds after 1s.
    // Sequential: VIDEO1 (1s fail) -> VIDEO2 (1s success). Total 2s.
    // Parallel: Both start. VIDEO1 fails at 1s. VIDEO2 succeeds at 1s. Total 1s.
  });

  test('Benchmark searchAndGetBestAudio with first failure', () async {
    final container = ProviderContainer();
    final service = container.read(youTubeDiscoveryServiceProvider.notifier);

    final client = MockClient((request) async {
      if (request.url.path.contains('/search')) {
        return http.Response(mockSearchResponse, 200);
      } else if (request.url.path.contains('/videos/VIDEO1')) {
        // VIDEO1 fails after 1s
        await Future.delayed(const Duration(seconds: 1));
        return http.Response('', 404);
      } else if (request.url.path.contains('/videos/VIDEO2')) {
        // VIDEO2 succeeds after 1s
        await Future.delayed(const Duration(seconds: 1));
        return http.Response(mockVideoResponse2, 200);
      }
      return http.Response('', 404);
    });

    service.setHttpClient(client);

    final stopwatch = Stopwatch()..start();
    final result = await service.searchAndGetBestAudio('Artist', 'Song');
    stopwatch.stop();

    print('Elapsed: ${stopwatch.elapsedMilliseconds}ms');
    expect(result, isNotNull);
    expect(result!.videoId, 'VIDEO2');

    // With current sequential implementation, this should take > 2000ms
    // With parallel implementation, this should take ~1000ms

    // We assert that it takes > 1500ms to prove it is currently sequential (assuming overhead is small)
    // But since I am writing the test to verify the optimization later, I should write expectations that match the *current* state if I want to "Establish a Baseline".
    // Or I can just output the time.

    // I will assert that it works. The time check will be done manually or via print for now,
    // or I can assert > 1900ms to confirm baseline.
  });
}
