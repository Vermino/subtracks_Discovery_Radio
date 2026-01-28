import 'package:flutter_test/flutter_test.dart';
import 'package:subtracks/models/hybrid_track.dart';
import 'package:subtracks/models/music.dart';
import 'package:subtracks/models/youtube_models.dart';
import 'package:subtracks/services/discovery_service.dart';

void main() {
  group('HybridTrack', () {
    test('creates local track correctly', () {
      final song = Song(
        sourceId: 1,
        id: 'song1',
        title: 'Test Song',
        artist: 'Test Artist',
        duration: Duration(seconds: 180),
      );

      final track = HybridTrack.local(song: song);

      expect(track.isLocal, isTrue);
      expect(track.isYouTube, isFalse);
      expect(track.id, equals('song1'));
      expect(track.title, equals('Test Song'));
      expect(track.artist, equals('Test Artist'));
      expect(track.duration, equals(Duration(seconds: 180)));
      expect(track.sourceType, equals('local'));
      expect(track.localSong, equals(song));
      expect(track.youTubeVideoId, isNull);
    });

    test('creates YouTube track correctly', () {
      final track = HybridTrack.youtube(
        videoId: 'abc123',
        title: 'YouTube Song',
        artist: 'YouTube Artist',
        durationSeconds: 200,
        thumbnailUrl: 'https://example.com/thumb.jpg',
      );

      expect(track.isLocal, isFalse);
      expect(track.isYouTube, isTrue);
      expect(track.id, equals('abc123'));
      expect(track.title, equals('YouTube Song'));
      expect(track.artist, equals('YouTube Artist'));
      expect(track.duration, equals(Duration(seconds: 200)));
      expect(track.sourceType, equals('youtube'));
      expect(track.localSong, isNull);
      expect(track.youTubeVideoId, equals('abc123'));
      expect(track.thumbnailUrl, equals('https://example.com/thumb.jpg'));
    });

    test('creates from Song using factory', () {
      final song = Song(
        sourceId: 1,
        id: 'song1',
        title: 'Test Song',
        artist: 'Test Artist',
      );

      final track = HybridTrackFactory.fromSong(song);

      expect(track.isLocal, isTrue);
      expect(track.id, equals('song1'));
    });

    test('creates from YouTubeSearchResult using factory', () {
      final result = YouTubeSearchResult(
        videoId: 'xyz789',
        title: 'Search Result',
        author: 'Channel Name',
        lengthSeconds: 240,
        thumbnail: 'https://example.com/thumb.jpg',
      );

      final track = HybridTrackFactory.fromYouTubeSearchResult(result);

      expect(track.isYouTube, isTrue);
      expect(track.id, equals('xyz789'));
      expect(track.title, equals('Search Result'));
      expect(track.artist, equals('Channel Name'));
      expect(track.thumbnailUrl, equals('https://example.com/thumb.jpg'));
    });

    test('creates list from Songs', () {
      final songs = [
        Song(sourceId: 1, id: 'song1', title: 'Song 1', artist: 'Artist 1'),
        Song(sourceId: 1, id: 'song2', title: 'Song 2', artist: 'Artist 2'),
      ];

      final tracks = HybridTrackFactory.fromSongs(songs);

      expect(tracks.length, equals(2));
      expect(tracks[0].isLocal, isTrue);
      expect(tracks[0].id, equals('song1'));
      expect(tracks[1].id, equals('song2'));
    });

    test('creates list from YouTube search results', () {
      final results = [
        YouTubeSearchResult(
          videoId: 'vid1',
          title: 'Video 1',
          author: 'Channel 1',
          lengthSeconds: 180,
        ),
        YouTubeSearchResult(
          videoId: 'vid2',
          title: 'Video 2',
          author: 'Channel 2',
          lengthSeconds: 200,
        ),
      ];

      final tracks = HybridTrackFactory.fromYouTubeSearchResults(results);

      expect(tracks.length, equals(2));
      expect(tracks[0].isYouTube, isTrue);
      expect(tracks[0].id, equals('vid1'));
      expect(tracks[1].id, equals('vid2'));
    });
  });

  group('DiscoveryConfig - YouTube Settings', () {
    test('has correct defaults', () {
      const config = DiscoveryConfig();

      expect(config.youtubeEnabled, isFalse);
      expect(config.youtubeRatio, equals(0.3));
      expect(config.youtubeQualityFilter, equals(YouTubeQualityFilter.strict));
      expect(config.youtubePreferOfficial, isTrue);
    });

    test('copyWith updates YouTube settings', () {
      const config = DiscoveryConfig();

      final updated = config.copyWith(
        youtubeEnabled: true,
        youtubeRatio: 0.5,
        youtubeQualityFilter: YouTubeQualityFilter.moderate,
        youtubePreferOfficial: false,
      );

      expect(updated.youtubeEnabled, isTrue);
      expect(updated.youtubeRatio, equals(0.5));
      expect(
          updated.youtubeQualityFilter, equals(YouTubeQualityFilter.moderate));
      expect(updated.youtubePreferOfficial, isFalse);

      // Original unchanged
      expect(config.youtubeEnabled, isFalse);
    });

    test('normalized preserves YouTube settings', () {
      const config = DiscoveryConfig(
        youtubeEnabled: true,
        youtubeRatio: 0.4,
      );

      final normalized = config.normalized;

      expect(normalized.youtubeEnabled, isTrue);
      expect(normalized.youtubeRatio, equals(0.4));
    });
  });

  group('Blending Algorithm', () {
    test('blends empty lists correctly', () {
      final service = _MockDiscoveryService();

      final result = service.testBlendTracks([], [], 0.3);

      expect(result, isEmpty);
    });

    test('returns all local when no YouTube tracks', () {
      final service = _MockDiscoveryService();

      final localSongs = [
        Song(sourceId: 1, id: 'song1', title: 'Song 1', artist: 'Artist 1'),
        Song(sourceId: 1, id: 'song2', title: 'Song 2', artist: 'Artist 2'),
        Song(sourceId: 1, id: 'song3', title: 'Song 3', artist: 'Artist 3'),
      ];

      final result = service.testBlendTracks(localSongs, [], 0.3);

      expect(result.length, equals(3));
      expect(result.every((t) => t.isLocal), isTrue);
    });

    test('returns all YouTube when no local tracks', () {
      final service = _MockDiscoveryService();

      final youtubeTracks = [
        HybridTrack.youtube(
          videoId: 'vid1',
          title: 'Video 1',
          artist: 'Channel 1',
          durationSeconds: 180,
        ),
        HybridTrack.youtube(
          videoId: 'vid2',
          title: 'Video 2',
          artist: 'Channel 2',
          durationSeconds: 200,
        ),
      ];

      final result = service.testBlendTracks([], youtubeTracks, 0.3);

      expect(result.length, equals(2));
      expect(result.every((t) => t.isYouTube), isTrue);
    });

    test('blends 70/30 ratio correctly', () {
      final service = _MockDiscoveryService();

      final localSongs = List.generate(
        7,
        (i) => Song(
          sourceId: 1,
          id: 'song$i',
          title: 'Song $i',
          artist: 'Artist',
        ),
      );

      final youtubeTracks = List.generate(
        3,
        (i) => HybridTrack.youtube(
          videoId: 'vid$i',
          title: 'Video $i',
          artist: 'Channel',
          durationSeconds: 180,
        ),
      );

      final result = service.testBlendTracks(localSongs, youtubeTracks, 0.3);

      expect(result.length, equals(10));

      final localCount = result.where((t) => t.isLocal).length;
      final youtubeCount = result.where((t) => t.isYouTube).length;

      expect(localCount, equals(7));
      expect(youtubeCount, equals(3));
    });

    test('blends 50/50 ratio correctly', () {
      final service = _MockDiscoveryService();

      final localSongs = List.generate(
        5,
        (i) => Song(
          sourceId: 1,
          id: 'song$i',
          title: 'Song $i',
          artist: 'Artist',
        ),
      );

      final youtubeTracks = List.generate(
        5,
        (i) => HybridTrack.youtube(
          videoId: 'vid$i',
          title: 'Video $i',
          artist: 'Channel',
          durationSeconds: 180,
        ),
      );

      final result = service.testBlendTracks(localSongs, youtubeTracks, 0.5);

      expect(result.length, equals(10));

      final localCount = result.where((t) => t.isLocal).length;
      final youtubeCount = result.where((t) => t.isYouTube).length;

      expect(localCount, equals(5));
      expect(youtubeCount, equals(5));
    });

    test('distributes YouTube tracks evenly throughout playlist', () {
      final service = _MockDiscoveryService();

      final localSongs = List.generate(
        7,
        (i) => Song(
          sourceId: 1,
          id: 'song$i',
          title: 'Song $i',
          artist: 'Artist',
        ),
      );

      final youtubeTracks = List.generate(
        3,
        (i) => HybridTrack.youtube(
          videoId: 'vid$i',
          title: 'Video $i',
          artist: 'Channel',
          durationSeconds: 180,
        ),
      );

      final result = service.testBlendTracks(localSongs, youtubeTracks, 0.3);

      // Check that YouTube tracks are spread out (not clustered)
      final youtubeIndices = <int>[];
      for (int i = 0; i < result.length; i++) {
        if (result[i].isYouTube) {
          youtubeIndices.add(i);
        }
      }

      // YouTube tracks should not be consecutive
      for (int i = 1; i < youtubeIndices.length; i++) {
        final gap = youtubeIndices[i] - youtubeIndices[i - 1];
        expect(gap, greaterThan(1),
            reason: 'YouTube tracks should be distributed');
      }
    });

    test('handles partial YouTube availability', () {
      final service = _MockDiscoveryService();

      final localSongs = List.generate(
        10,
        (i) => Song(
          sourceId: 1,
          id: 'song$i',
          title: 'Song $i',
          artist: 'Artist',
        ),
      );

      // Only 1 YouTube track available (should be 30% = 3)
      final youtubeTracks = [
        HybridTrack.youtube(
          videoId: 'vid1',
          title: 'Video 1',
          artist: 'Channel',
          durationSeconds: 180,
        ),
      ];

      final result = service.testBlendTracks(localSongs, youtubeTracks, 0.3);

      expect(result.length, equals(10));

      final localCount = result.where((t) => t.isLocal).length;
      final youtubeCount = result.where((t) => t.isYouTube).length;

      // Should fill rest with local tracks
      expect(localCount, equals(9));
      expect(youtubeCount, equals(1));
    });

    test('handles 100% YouTube ratio', () {
      final service = _MockDiscoveryService();

      final localSongs = List.generate(
        3,
        (i) => Song(
          sourceId: 1,
          id: 'song$i',
          title: 'Song $i',
          artist: 'Artist',
        ),
      );

      final youtubeTracks = List.generate(
        5,
        (i) => HybridTrack.youtube(
          videoId: 'vid$i',
          title: 'Video $i',
          artist: 'Channel',
          durationSeconds: 180,
        ),
      );

      final result = service.testBlendTracks(localSongs, youtubeTracks, 1.0);

      expect(result.length, equals(3));
      // All tracks should be YouTube (up to local length)
      expect(result.every((t) => t.isYouTube), isTrue);
    });

    test('handles 0% YouTube ratio', () {
      final service = _MockDiscoveryService();

      final localSongs = List.generate(
        3,
        (i) => Song(
          sourceId: 1,
          id: 'song$i',
          title: 'Song $i',
          artist: 'Artist',
        ),
      );

      final youtubeTracks = List.generate(
        5,
        (i) => HybridTrack.youtube(
          videoId: 'vid$i',
          title: 'Video $i',
          artist: 'Channel',
          durationSeconds: 180,
        ),
      );

      final result = service.testBlendTracks(localSongs, youtubeTracks, 0.0);

      expect(result.length, equals(3));
      expect(result.every((t) => t.isLocal), isTrue);
    });
  });

  group('WeightedHybridTrack', () {
    test('stores track and score correctly', () {
      final track = HybridTrack.local(
        song: Song(
          sourceId: 1,
          id: 'song1',
          title: 'Test Song',
          artist: 'Artist',
        ),
      );

      final weighted = WeightedHybridTrack(
        track: track,
        score: 0.85,
        scoreBreakdown: {
          'artist': 0.35,
          'genre': 0.25,
          'preference': 0.25,
        },
      );

      expect(weighted.track, equals(track));
      expect(weighted.score, equals(0.85));
      expect(weighted.scoreBreakdown['artist'], equals(0.35));
      expect(weighted.scoreBreakdown['genre'], equals(0.25));
    });

    test('toString includes source type', () {
      final localTrack = HybridTrack.local(
        song: Song(
          sourceId: 1,
          id: 'song1',
          title: 'Local Song',
          artist: 'Artist',
        ),
      );

      final weighted = WeightedHybridTrack(
        track: localTrack,
        score: 0.75,
        scoreBreakdown: {},
      );

      final str = weighted.toString();
      expect(str, contains('Local Song'));
      expect(str, contains('Artist'));
      expect(str, contains('local'));
      expect(str, contains('0.750'));
    });
  });
}

/// Mock service to test blending algorithm
class _MockDiscoveryService {
  /// Expose the blending algorithm for testing
  List<HybridTrack> testBlendTracks(
    List<Song> localTracks,
    List<HybridTrack> youtubeTracks,
    double youtubeRatio,
  ) {
    if (youtubeTracks.isEmpty) {
      return HybridTrackFactory.fromSongs(localTracks);
    }

    if (localTracks.isEmpty) {
      return youtubeTracks;
    }

    final blended = <HybridTrack>[];
    final totalTracks = localTracks.length;
    final youtubeCount =
        (totalTracks * youtubeRatio).round().clamp(0, youtubeTracks.length);
    final localCount = totalTracks - youtubeCount;

    final localPerYoutube =
        youtubeCount > 0 ? (localCount / youtubeCount).round() : localCount;

    int localIndex = 0;
    int youtubeIndex = 0;
    int localStreak = 0;

    while (blended.length < totalTracks) {
      if (localIndex < localCount &&
          (localStreak < localPerYoutube || youtubeIndex >= youtubeCount)) {
        blended.add(HybridTrack.local(song: localTracks[localIndex++]));
        localStreak++;
      } else if (youtubeIndex < youtubeCount) {
        blended.add(youtubeTracks[youtubeIndex++]);
        localStreak = 0;
      } else if (localIndex < localCount) {
        blended.add(HybridTrack.local(song: localTracks[localIndex++]));
      } else {
        break;
      }
    }

    return blended;
  }
}
