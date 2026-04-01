import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:subtracks/database/database.dart';
import 'package:subtracks/services/discovery_service.dart';

void main() {
  test('DiscoveryService benchmark', () async {
    final db = SubtracksDatabase.connection(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
    );

    addTearDown(() {
      container.dispose();
      db.close();
    });

    final discoveryService = container.read(discoveryServiceProvider.notifier);

    // Setup data
    await db.into(db.sources).insert(
      SourcesCompanion.insert(name: 'TestSource', address: Uri.parse('http://test.com')),
    );
    final sourceId = 1;

    // Seed Data
    final seedArtistId = 'seed-artist';
    await db.into(db.artists).insert(ArtistsCompanion.insert(
      sourceId: sourceId,
      id: seedArtistId,
      name: 'Seed Artist',
      albumCount: 1,
    ));

    final seedAlbumId = 'seed-album';
    await db.into(db.albums).insert(AlbumsCompanion.insert(
      sourceId: sourceId,
      id: seedAlbumId,
      name: 'Seed Album',
      artistId: Value(seedArtistId),
      songCount: 1,
      genre: Value('Rock'),
      created: DateTime.now(),
    ));

    final seedSongId = 'seed-song';
    await db.into(db.songs).insert(SongsCompanion.insert(
      sourceId: sourceId,
      id: seedSongId,
      title: 'Seed Song',
      artistId: Value(seedArtistId),
      albumId: Value(seedAlbumId),
      genre: Value('Rock'),
    ));

    // Candidate Data
    final numCandidates = 500; // Increased to make it more noticeable
    for (var i = 0; i < numCandidates; i++) {
      final artistId = 'artist-$i';
      await db.into(db.artists).insert(ArtistsCompanion.insert(
        sourceId: sourceId,
        id: artistId,
        name: 'Artist $i',
        albumCount: 1,
      ));

      final albumId = 'album-$i';
      await db.into(db.albums).insert(AlbumsCompanion.insert(
        sourceId: sourceId,
        id: albumId,
        name: 'Album $i',
        artistId: Value(artistId),
        songCount: 1,
        genre: Value('Rock'), // Same genre to trigger some similarity logic
        created: DateTime.now(),
      ));

      await db.into(db.songs).insert(SongsCompanion.insert(
        sourceId: sourceId,
        id: 'song-$i',
        title: 'Song $i',
        artistId: Value(artistId),
        albumId: Value(albumId),
        genre: Value('Rock'),
      ));
    }

    // Fetch seed song
    final seedSong = await db.songById(sourceId, seedSongId).getSingle();

    // Warmup (optional, but might help with JIT)
    // await discoveryService.generateSimilarSongs(seedSong, limit: 1);

    // Benchmark
    print('Starting benchmark with $numCandidates candidates...');
    final stopwatch = Stopwatch()..start();
    await discoveryService.generateSimilarSongs(seedSong, limit: 10);
    stopwatch.stop();

    print('Benchmark time: ${stopwatch.elapsedMilliseconds} ms');
  });
}
