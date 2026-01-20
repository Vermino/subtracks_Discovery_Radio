import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:subtracks/database/database.dart';
import 'package:subtracks/models/music.dart';
import 'package:subtracks/services/discovery_service.dart';

void main() {
  group('DiscoveryService Performance', () {
    late SubtracksDatabase db;
    late ProviderContainer container;
    late DiscoveryService service;

    setUp(() async {
      // Use in-memory database for testing
      db = SubtracksDatabase.connection(NativeDatabase.memory());

      // Setup Riverpod container with overridden database provider
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );

      service = container.read(discoveryServiceProvider.notifier);

      // Initialize database schema
      await db.customStatement('PRAGMA foreign_keys = ON');
      // We need to run migrations or create tables?
      // NativeDatabase.memory() creates empty DB. Drift usually handles creation if we use standard open.
      // But here we use .connection().
      // SubtracksDatabase has `schemaVersion`. We might need to manually create tables or rely on drift's `beforeOpen`.
      // Actually, when we use the generated class, it should handle creation on first access if configured correctly.
      // However, `SubtracksDatabase` constructor calls `super(_openConnection())`.
      // The `connection` constructor calls `super(e)`.
      // We might need to ensure schema is created.
      await db.doWhenOpened((e) {}); // Trigger opening?
    });

    tearDown(() async {
      await db.close();
      container.dispose();
    });

    test('benchmark generateSimilarSongs', () async {
      // 1. Setup Data
      const sourceId = 1;

      // Create Source
      await db.createSource(
        SourcesCompanion(
          name: Value('Test Source'),
          address: Value(Uri.parse('http://localhost')),
          isActive: Value(true),
        ),
        SubsonicSourcesCompanion(
          username: Value('user'),
          password: Value('pass'),
        ),
      );

      // Create Seed Artist and Albums
      final seedArtistId = 'seed-artist';
      await db.into(db.artists).insert(ArtistsCompanion.insert(
        sourceId: sourceId,
        id: seedArtistId,
        name: 'Seed Artist',
        albumCount: 10,
      ));

      for (int i = 0; i < 10; i++) {
        await db.into(db.albums).insert(AlbumsCompanion.insert(
          sourceId: sourceId,
          id: 'seed-album-$i',
          artistId: Value(seedArtistId),
          name: 'Seed Album $i',
          songCount: 10,
          created: DateTime.now(),
          genre: Value('Rock'),
        ));
      }

      // Create Seed Song
      final seedSongId = 'seed-song';
      await db.into(db.songs).insert(SongsCompanion.insert(
        sourceId: sourceId,
        id: seedSongId,
        artistId: Value(seedArtistId),
        title: 'Seed Song',
        userRating: Value(UserRating.thumbsUp),
      ));

      final seedSong = await db.songById(sourceId, seedSongId).getSingle();

      // Create Candidate Artists (100) and Albums (5 each)
      for (int i = 0; i < 100; i++) {
        final artistId = 'artist-$i';
        await db.into(db.artists).insert(ArtistsCompanion.insert(
          sourceId: sourceId,
          id: artistId,
          name: 'Artist $i',
          albumCount: 5,
        ));

        for (int j = 0; j < 5; j++) {
           await db.into(db.albums).insert(AlbumsCompanion.insert(
            sourceId: sourceId,
            id: 'album-$i-$j',
            artistId: Value(artistId),
            name: 'Album $i $j',
            songCount: 2,
            created: DateTime.now(),
            genre: Value(i % 2 == 0 ? 'Rock' : 'Pop'), // Some overlap with seed
          ));
        }

        // Create Songs for this artist (10 songs per artist = 1000 songs total)
        for (int k = 0; k < 10; k++) {
           await db.into(db.songs).insert(SongsCompanion.insert(
            sourceId: sourceId,
            id: 'song-$i-$k',
            artistId: Value(artistId),
            title: 'Song $i $k',
            genre: Value(i % 2 == 0 ? 'Rock' : 'Pop'),
            userRating: Value(UserRating.unrated),
          ));
        }
      }

      print('Database populated. Starting benchmark...');

      // 2. Measure
      final stopwatch = Stopwatch()..start();

      final recommendations = await service.generateSimilarSongs(
        seedSong,
        limit: 50,
        mode: DiscoveryMode.online,
      );

      stopwatch.stop();

      print('generateSimilarSongs took ${stopwatch.elapsedMilliseconds} ms');
      print('Generated ${recommendations.length} recommendations');

      expect(recommendations.length, greaterThan(0));
    });
  });
}
