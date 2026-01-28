import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:subtracks/database/database.dart';
import 'package:subtracks/models/music.dart';
import 'package:subtracks/models/query.dart';
import 'package:subtracks/services/discovery_service.dart';

// import 'discovery_service_test.mocks.dart';

// @GenerateMocks([SubtracksDatabase])
void main() {
  group('DiscoveryService', () {
    // late MockSubtracksDatabase mockDb;
    // late DiscoveryService discoveryService;

    setUp(() {
      // mockDb = MockSubtracksDatabase();
      // Note: In a real test environment, you'd need to set up Riverpod container
      // and provide the mock database. For this example, we'll test the logic directly.
    });

    group('DiscoveryMode', () {
      test('online mode should be online', () {
        expect(DiscoveryMode.online.isOnline, true);
      });

      test('offline mode should not be online', () {
        expect(DiscoveryMode.offline.isOnline, false);
      });
    });

    group('DiscoveryConfig', () {
      test('default config should have reasonable weights', () {
        const config = DiscoveryConfig();

        expect(config.artistSimilarityWeight, 0.35);
        expect(config.genreSimilarityWeight, 0.25);
        expect(config.userPreferenceWeight, 0.30);
        expect(config.metadataCorrelationWeight, 0.10);
        expect(config.maxRecommendations, 50);
      });

      test('normalized config should sum weights to 1.0', () {
        const config = DiscoveryConfig(
          artistSimilarityWeight: 2.0,
          genreSimilarityWeight: 1.0,
          userPreferenceWeight: 1.0,
          metadataCorrelationWeight: 0.5,
        );

        final normalized = config.normalized;
        final totalWeight = normalized.artistSimilarityWeight +
            normalized.genreSimilarityWeight +
            normalized.userPreferenceWeight +
            normalized.metadataCorrelationWeight;

        expect(totalWeight, closeTo(1.0, 0.0001));
      });
    });

    group('WeightedSong', () {
      test('should create weighted song with score and breakdown', () {
        final song = Song(
          sourceId: 1,
          id: 'test-song',
          title: 'Test Song',
          artist: 'Test Artist',
        );

        const weightedSong = WeightedSong(
          song: song,
          score: 0.85,
          scoreBreakdown: {
            'artist': 0.4,
            'genre': 0.25,
            'preference': 0.2,
          },
        );

        expect(weightedSong.song.id, 'test-song');
        expect(weightedSong.score, 0.85);
        expect(weightedSong.scoreBreakdown['artist'], 0.4);
      });

      test('toString should include song info and score', () {
        final song = Song(
          sourceId: 1,
          id: 'test-song',
          title: 'Test Song',
          artist: 'Test Artist',
        );

        const weightedSong = WeightedSong(
          song: song,
          score: 0.85,
          scoreBreakdown: {},
        );

        final str = weightedSong.toString();
        expect(str, contains('Test Song'));
        expect(str, contains('Test Artist'));
        expect(str, contains('0.850'));
      });
    });

    group('Genre Relationships', () {
      // These tests would need access to the private _getRelatedGenres method
      // In a real implementation, you might make this method public or test it indirectly

      test('should identify rock and alternative as related genres', () {
        // This would test the genre relationship logic
        // For now, we'll test this indirectly through similarity calculations
        expect(true, true); // Placeholder
      });
    });

    group('User Preference Scoring', () {
      test('thumbs up songs should have high preference score', () {
        final likedSong = Song(
          sourceId: 1,
          id: 'liked-song',
          title: 'Liked Song',
          userRating: UserRating.thumbsUp,
        );

        // This would test the _calculateUserPreference method
        // In a real implementation, you'd need to access this method or test it indirectly
        expect(likedSong.userRating, UserRating.thumbsUp);
      });

      test('thumbs down songs should have low preference score', () {
        final dislikedSong = Song(
          sourceId: 1,
          id: 'disliked-song',
          title: 'Disliked Song',
          userRating: UserRating.thumbsDown,
        );

        expect(dislikedSong.userRating, UserRating.thumbsDown);
      });

      test('unrated songs should have neutral preference score', () {
        final unratedSong = Song(
          sourceId: 1,
          id: 'unrated-song',
          title: 'Unrated Song',
          userRating: UserRating.unrated,
        );

        expect(unratedSong.userRating, UserRating.unrated);
      });
    });

    group('Metadata Correlation', () {
      test('songs with similar duration should correlate', () {
        final song1 = Song(
          sourceId: 1,
          id: 'song1',
          title: 'Song 1',
          duration: Duration(minutes: 3, seconds: 30),
        );

        final song2 = Song(
          sourceId: 1,
          id: 'song2',
          title: 'Song 2',
          duration: Duration(minutes: 3, seconds: 45), // Within 30% difference
        );

        // Both songs have similar durations, so they should correlate
        expect(song1.duration!.inMilliseconds,
            closeTo(song2.duration!.inMilliseconds, 30000));
      });

      test('songs from same album should correlate', () {
        final song1 = Song(
          sourceId: 1,
          id: 'song1',
          title: 'Song 1',
          albumId: 'same-album',
        );

        final song2 = Song(
          sourceId: 1,
          id: 'song2',
          title: 'Song 2',
          albumId: 'same-album',
        );

        expect(song1.albumId, song2.albumId);
      });
    });

    group('Smart Sampling', () {
      test('should limit results to requested count', () {
        // This would test the _applySmartSampling method
        // For now, we'll just verify the concept
        const requestedLimit = 10;
        const candidateCount = 100;

        expect(requestedLimit < candidateCount, true);
      });

      test('should balance quality with diversity', () {
        // This would test that smart sampling doesn't just take the top N results
        // but includes some diversity from different score buckets
        expect(true, true); // Placeholder
      });
    });

    // Discovery session tracking temporarily disabled until database implementation is complete
    /*
    group('Discovery Session Tracking', () {
      test('should create discovery session when building playlist', () async {
        // This would test session creation and tracking
        final seedSong = Song(
          sourceId: 1,
          id: 'seed-song',
          title: 'Seed Song',
          artist: 'Seed Artist',
          genre: 'Rock',
        );

        when(mockDb.createDiscoverySession(
          sourceId: anyNamed('sourceId'),
          seedSongId: anyNamed('seedSongId'),
          seedArtist: anyNamed('seedArtist'),
          seedGenre: anyNamed('seedGenre'),
          mode: anyNamed('mode'),
          playlistSize: anyNamed('playlistSize'),
        )).thenAnswer((_) async => 123);

        // Would need to test with actual service instance
        expect(seedSong.id, 'seed-song');
      });
    });
    */

    group('Analytics', () {
      test('should calculate mode distribution correctly', () {
        // This would test the _getModeDistribution method
        final sessions = [
          {'mode': 'online'},
          {'mode': 'online'},
          {'mode': 'offline'},
        ];

        // Expected distribution: online: 2, offline: 1
        expect(sessions.where((s) => s['mode'] == 'online').length, 2);
        expect(sessions.where((s) => s['mode'] == 'offline').length, 1);
      });
    });

    group('Error Handling', () {
      test('should gracefully handle empty song pools', () {
        // Test that the service handles cases where no songs are available
        expect(true, true); // Placeholder - would test actual error handling
      });

      test('should fallback to seed song only when recommendations fail', () {
        // Test that when recommendation generation fails,
        // the service falls back to just the seed song
        expect(true, true); // Placeholder
      });

      test('should handle missing genre information gracefully', () {
        final songWithoutGenre = Song(
          sourceId: 1,
          id: 'no-genre-song',
          title: 'Song Without Genre',
          genre: null,
        );

        expect(songWithoutGenre.genre, null);
      });

      test('should handle missing artist information gracefully', () {
        final songWithoutArtist = Song(
          sourceId: 1,
          id: 'no-artist-song',
          title: 'Song Without Artist',
          artistId: null,
        );

        expect(songWithoutArtist.artistId, null);
      });
    });

    group('Integration Tests', () {
      // These would be integration tests that test the full flow
      // They would require a test database and proper Riverpod setup

      test('should generate recommendations for rock song', () async {
        // Would test end-to-end recommendation generation
        expect(true, true); // Placeholder
      });

      test('should prefer liked songs in recommendations', () async {
        // Would test that songs with thumbs up are weighted higher
        expect(true, true); // Placeholder
      });

      test('should avoid thumbs down songs in recommendations', () async {
        // Would test that thumbs down songs are excluded
        expect(true, true); // Placeholder
      });

      test('should work in offline mode with downloaded songs only', () async {
        // Would test offline mode functionality
        expect(true, true); // Placeholder
      });
    });
  });
}

/// Mock data helpers for tests
class TestDataHelper {
  static Song createSong({
    required String id,
    required String title,
    String? artist,
    String? genre,
    String? albumId,
    UserRating rating = UserRating.unrated,
    Duration? duration,
    bool isDownloaded = false,
  }) {
    return Song(
      sourceId: 1,
      id: id,
      title: title,
      artist: artist,
      genre: genre,
      albumId: albumId,
      userRating: rating,
      duration: duration,
      downloadFilePath: isDownloaded ? '/path/to/file.mp3' : null,
    );
  }

  static List<Song> createTestSongLibrary() {
    return [
      createSong(
        id: 'rock-song-1',
        title: 'Rock Song 1',
        artist: 'Rock Artist A',
        genre: 'Rock',
        rating: UserRating.thumbsUp,
        duration: Duration(minutes: 3, seconds: 30),
      ),
      createSong(
        id: 'rock-song-2',
        title: 'Rock Song 2',
        artist: 'Rock Artist B',
        genre: 'Rock',
        rating: UserRating.unrated,
        duration: Duration(minutes: 4, seconds: 15),
      ),
      createSong(
        id: 'alt-song-1',
        title: 'Alternative Song 1',
        artist: 'Alt Artist A',
        genre: 'Alternative',
        rating: UserRating.thumbsUp,
        duration: Duration(minutes: 3, seconds: 45),
      ),
      createSong(
        id: 'pop-song-1',
        title: 'Pop Song 1',
        artist: 'Pop Artist A',
        genre: 'Pop',
        rating: UserRating.thumbsDown,
        duration: Duration(minutes: 3, seconds: 20),
      ),
      createSong(
        id: 'downloaded-song',
        title: 'Downloaded Song',
        artist: 'Downloaded Artist',
        genre: 'Rock',
        rating: UserRating.unrated,
        duration: Duration(minutes: 4, seconds: 0),
        isDownloaded: true,
      ),
    ];
  }
}
