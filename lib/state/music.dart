import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/database.dart';
import '../models/music.dart';
import '../models/query.dart';
import '../models/support.dart';
import 'settings.dart';

part 'music.g.dart';

@riverpod
Stream<Artist> artist(ArtistRef ref, String id) {
  final db = ref.watch(databaseProvider);
  final sourceId = ref.watch(sourceIdProvider);

  return db.artistById(sourceId, id).watchSingle();
}

@riverpod
Stream<Album> album(AlbumRef ref, String id) async* {
  final db = ref.watch(databaseProvider);

  // First try local music (sourceId = 0) for local albums
  final localAlbum = await db.albumById(0, id).getSingleOrNull();
  if (localAlbum != null) {
    yield localAlbum;
    // Watch for changes to local album
    yield* db.albumById(0, id).watchSingle();
    return;
  }

  // Fall back to active source for server albums
  final sourceId = ref.watch(sourceIdProvider);
  yield* db.albumById(sourceId, id).watchSingle();
}

/// Helper to get an album's sourceId from the database
/// This is needed because local albums have sourceId = 0, not the active source
Future<int> _getAlbumSourceId(AlbumSongsListRef ref, String albumId) async {
  final db = ref.read(databaseProvider);

  // First try local music (sourceId = 0)
  final localAlbum = await db.albumById(0, albumId).getSingleOrNull();
  if (localAlbum != null) {
    return 0;
  }

  // Fall back to active source
  return ref.read(sourceIdProvider);
}

@riverpod
Stream<ListDownloadStatus> albumDownloadStatus(
  AlbumDownloadStatusRef ref,
  String id,
) {
  final db = ref.watch(databaseProvider);
  final sourceId = ref.watch(sourceIdProvider);

  return db.albumDownloadStatus(sourceId, id).watchSingle();
}

@riverpod
Stream<ListDownloadStatus> playlistDownloadStatus(
  PlaylistDownloadStatusRef ref,
  String id,
) {
  final db = ref.watch(databaseProvider);
  final sourceId = ref.watch(sourceIdProvider);

  return db.playlistDownloadStatus(sourceId, id).watchSingle();
}

@riverpod
Stream<Song> song(SongRef ref, String id) {
  final db = ref.watch(databaseProvider);
  final sourceId = ref.watch(sourceIdProvider);

  return db.songById(sourceId, id).watchSingle();
}

@riverpod
Future<List<Song>> albumSongsList(
  AlbumSongsListRef ref,
  String id,
  ListQuery opt,
) async {
  final db = ref.watch(databaseProvider);

  // Get the correct sourceId (handles both server and local albums)
  final sourceId = await _getAlbumSourceId(ref, id);

  return db.albumSongsList(SourceId(sourceId: sourceId, id: id), opt).get();
}

@riverpod
Future<List<Song>> songsByAlbumList(
  SongsByAlbumListRef ref,
  ListQuery opt,
) {
  final db = ref.watch(databaseProvider);
  final sourceId = ref.watch(sourceIdProvider);

  return db.songsByAlbumList(sourceId, opt).get();
}

@riverpod
Stream<Playlist> playlist(PlaylistRef ref, String id) {
  final db = ref.watch(databaseProvider);
  final sourceId = ref.watch(sourceIdProvider);

  return db.playlistById(sourceId, id).watchSingle();
}

@riverpod
Future<List<Song>> playlistSongsList(
  PlaylistSongsListRef ref,
  String id,
  ListQuery opt,
) {
  final db = ref.watch(databaseProvider);
  final sourceId = ref.watch(sourceIdProvider);

  return db.playlistSongsList(SourceId(sourceId: sourceId, id: id), opt).get();
}

@riverpod
Future<List<Album>> albumsInIds(AlbumsInIdsRef ref, IList<String> ids) {
  final db = ref.watch(databaseProvider);
  final sourceId = ref.watch(sourceIdProvider);

  return db.albumsInIds(sourceId, ids.toList()).get();
}

@riverpod
Stream<IList<Album>> albumsByArtistId(AlbumsByArtistIdRef ref, String id) {
  final db = ref.watch(databaseProvider);
  final sourceId = ref.watch(sourceIdProvider);

  return db
      .albumsByArtistId(sourceId, id)
      .watch()
      .map((event) => event.toIList());
}

@riverpod
Stream<IList<String>> albumGenres(AlbumGenresRef ref, Pagination page) {
  final db = ref.watch(databaseProvider);
  final sourceId = ref.watch(sourceIdProvider);

  return db
      .albumGenres(sourceId, page.limit, page.offset)
      .watch()
      .map((event) => event.withNullsRemoved().toIList());
}

@riverpod
Stream<IList<Album>> albumsByGenre(
  AlbumsByGenreRef ref,
  String genre,
  Pagination page,
) {
  final db = ref.watch(databaseProvider);
  final sourceId = ref.watch(sourceIdProvider);

  return db
      .albumsByGenre(sourceId, genre, page.limit, page.offset)
      .watch()
      .map((event) => event.toIList());
}

@riverpod
Stream<int> songsByGenreCount(SongsByGenreCountRef ref, String genre) {
  final db = ref.watch(databaseProvider);
  final sourceId = ref.watch(sourceIdProvider);

  return db.songsByGenreCount(sourceId, genre).watchSingle();
}

@riverpod
Stream<IList<Song>> songsList(SongsListRef ref, ListQuery opt) {
  final db = ref.watch(databaseProvider);
  final sourceId = ref.watch(sourceIdProvider);

  return db
      .songsList(sourceId, opt)
      .watch()
      .map((event) => event.withNullsRemoved().toIList());
}
