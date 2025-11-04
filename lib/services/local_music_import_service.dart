import 'dart:io';
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:drift/drift.dart' as drift;
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/database.dart';
import '../models/music.dart';
import '../state/settings.dart';

part 'local_music_import_service.g.dart';

/// Source ID reserved for local music files
const int kLocalMusicSourceId = 0;

/// Service for importing local music files from device storage
@Riverpod(keepAlive: true)
class LocalMusicImportService extends _$LocalMusicImportService {
  late final SubtracksDatabase _db;
  late final Audiotagger _tagger;

  @override
  Future<void> build() async {
    _db = ref.read(databaseProvider);
    _tagger = Audiotagger();

    // Ensure local music source exists in database
    await _ensureLocalMusicSource();
  }

  /// Ensure the local music source exists in the database
  Future<void> _ensureLocalMusicSource() async {
    final existingSource = await (_db.select(_db.sources)
          ..where((tbl) => tbl.id.equals(kLocalMusicSourceId)))
        .getSingleOrNull();

    if (existingSource == null) {
      await _db.into(_db.sources).insert(
            SourcesCompanion.insert(
              id: const drift.Value(kLocalMusicSourceId),
              name: 'Local Music',
              address: Uri.parse('local://'),
              createdAt: drift.Value(DateTime.now()),
              isActive: const drift.Value(null),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  /// Open file picker and import selected audio files
  Future<ImportResult> importFromDevice() async {
    try {
      // Open file picker for audio files
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'flac', 'ogg', 'opus', 'm4a', 'aac', 'wav'],
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        return const ImportResult(
          success: 0,
          failed: 0,
          errors: [],
        );
      }

      final importedSongs = <Song>[];
      final errors = <String>[];

      for (final file in result.files) {
        if (file.path == null) {
          errors.add('File ${file.name} has no valid path');
          continue;
        }

        try {
          final song = await _importFile(file.path!);
          if (song != null) {
            importedSongs.add(song);
          } else {
            errors.add('Failed to import ${file.name}');
          }
        } catch (e) {
          errors.add('Error importing ${file.name}: $e');
        }
      }

      return ImportResult(
        success: importedSongs.length,
        failed: errors.length,
        errors: errors,
      );
    } catch (e) {
      return ImportResult(
        success: 0,
        failed: 1,
        errors: ['Failed to open file picker: $e'],
      );
    }
  }

  /// Import a single audio file
  Future<Song?> _importFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return null;
    }

    // Extract metadata from audio file
    Tag? tag;
    try {
      tag = await _tagger.readTags(path: filePath);
    } catch (e) {
      // If metadata extraction fails, use filename
      print('Failed to extract metadata from $filePath: $e');
    }

    // Generate unique ID for this local song
    final fileName = path.basename(filePath);
    final songId = 'local_${DateTime.now().millisecondsSinceEpoch}_${fileName.hashCode}';

    // Get local music directory
    final localMusicDir = await _getLocalMusicDirectory();
    final newFileName = '${songId}${path.extension(filePath)}';
    final destinationPath = path.join(localMusicDir, newFileName);

    // Copy file to app storage
    await file.copy(destinationPath);

    // Extract metadata
    final title = tag?.title?.trim().isNotEmpty == true
        ? tag!.title!
        : path.basenameWithoutExtension(fileName);
    final artist = tag?.artist?.trim().isNotEmpty == true ? tag!.artist : 'Unknown Artist';
    final album = tag?.album?.trim().isNotEmpty == true ? tag!.album : 'Unknown Album';
    final genre = tag?.genre?.trim().isNotEmpty == true ? tag!.genre : null;
    final year = tag?.year != null ? int.tryParse(tag!.year!) : null;
    final trackNumber = tag?.trackNumber != null ? int.tryParse(tag!.trackNumber!) : null;
    final discNumber = tag?.discNumber != null ? int.tryParse(tag!.discNumber!) : null;

    // Generate IDs for album and artist
    final albumId = 'local_album_${album.hashCode}';
    final artistId = 'local_artist_${artist?.hashCode ?? 0}';

    // Create or update artist
    await _db.into(_db.artists).insert(
          ArtistsCompanion.insert(
            sourceId: kLocalMusicSourceId,
            id: artistId,
            name: artist ?? 'Unknown Artist',
            albumCount: 0, // Will be updated by trigger
          ),
          mode: InsertMode.insertOrIgnore,
        );

    // Create or update album
    await _db.into(_db.albums).insert(
          AlbumsCompanion.insert(
            sourceId: kLocalMusicSourceId,
            id: albumId,
            name: album,
            created: DateTime.now(),
            songCount: 0, // Will be updated when songs are added
            albumArtist: drift.Value(artist),
            artistId: drift.Value(artistId),
            genre: drift.Value(genre),
            year: drift.Value(year),
          ),
          mode: InsertMode.insertOrIgnore,
        );

    // Update album song count
    final existingAlbum = await (_db.select(_db.albums)
          ..where((tbl) =>
              tbl.sourceId.equals(kLocalMusicSourceId) &
              tbl.id.equals(albumId)))
        .getSingleOrNull();

    if (existingAlbum != null) {
      await (_db.update(_db.albums)
            ..where((tbl) =>
                tbl.sourceId.equals(kLocalMusicSourceId) &
                tbl.id.equals(albumId)))
          .write(
            AlbumsCompanion(
              songCount: drift.Value(existingAlbum.songCount + 1),
            ),
          );
    }

    // Create song entry
    final song = Song(
      sourceId: kLocalMusicSourceId,
      id: songId,
      title: title,
      artist: artist,
      album: album,
      albumId: albumId,
      artistId: artistId,
      genre: genre,
      track: trackNumber,
      disc: discNumber,
      downloadFilePath: destinationPath,
      duration: tag?.duration != null
          ? Duration(milliseconds: (tag!.duration! * 1000).toInt())
          : null,
    );

    // Save song to database
    await _db.into(_db.songs).insert(
          song.toCompanion(),
          mode: InsertMode.insertOrReplace,
        );

    return song;
  }

  /// Get or create the local music directory
  Future<String> _getLocalMusicDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final localMusicDir = Directory(path.join(appDir.path, 'local_music'));

    if (!await localMusicDir.exists()) {
      await localMusicDir.create(recursive: true);
    }

    return localMusicDir.path;
  }

  /// Delete a local music file and its database entry
  Future<bool> deleteLocalSong(Song song) async {
    if (song.sourceId != kLocalMusicSourceId) {
      return false;
    }

    try {
      // Delete the file if it exists
      if (song.downloadFilePath != null) {
        final file = File(song.downloadFilePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // Remove from database
      await (_db.delete(_db.songs)
            ..where((tbl) =>
                tbl.sourceId.equals(kLocalMusicSourceId) &
                tbl.id.equals(song.id)))
          .go();

      // Update album song count
      if (song.albumId != null) {
        final album = await (_db.select(_db.albums)
              ..where((tbl) =>
                  tbl.sourceId.equals(kLocalMusicSourceId) &
                  tbl.id.equals(song.albumId!)))
            .getSingleOrNull();

        if (album != null) {
          final newCount = album.songCount - 1;
          if (newCount <= 0) {
            // Delete album if no songs remain
            await (_db.delete(_db.albums)
                  ..where((tbl) =>
                      tbl.sourceId.equals(kLocalMusicSourceId) &
                      tbl.id.equals(song.albumId!)))
                .go();
          } else {
            // Update song count
            await (_db.update(_db.albums)
                  ..where((tbl) =>
                      tbl.sourceId.equals(kLocalMusicSourceId) &
                      tbl.id.equals(song.albumId!)))
                .write(
                  AlbumsCompanion(
                    songCount: drift.Value(newCount),
                  ),
                );
          }
        }
      }

      return true;
    } catch (e) {
      print('Error deleting local song: $e');
      return false;
    }
  }

  /// Get all local music songs
  Future<List<Song>> getLocalSongs() async {
    final songs = await (_db.select(_db.songs)
          ..where((tbl) => tbl.sourceId.equals(kLocalMusicSourceId))
          ..orderBy([
            (tbl) => drift.OrderingTerm(
                  expression: tbl.album,
                  mode: drift.OrderingMode.asc,
                ),
            (tbl) => drift.OrderingTerm(
                  expression: tbl.disc,
                  mode: drift.OrderingMode.asc,
                ),
            (tbl) => drift.OrderingTerm(
                  expression: tbl.track,
                  mode: drift.OrderingMode.asc,
                ),
          ]))
        .get();

    return songs;
  }

  /// Get count of local music files
  Future<int> getLocalSongsCount() async {
    final count = await (_db.selectOnly(_db.songs)
          ..addColumns([_db.songs.id.count()])
          ..where(_db.songs.sourceId.equals(kLocalMusicSourceId)))
        .getSingle();

    return count.read(_db.songs.id.count()) ?? 0;
  }
}

/// Result of an import operation
class ImportResult {
  final int success;
  final int failed;
  final List<String> errors;

  const ImportResult({
    required this.success,
    required this.failed,
    required this.errors,
  });

  bool get hasErrors => errors.isNotEmpty;
  String get message {
    if (success > 0 && failed == 0) {
      return 'Successfully imported $success ${success == 1 ? 'song' : 'songs'}';
    } else if (success > 0 && failed > 0) {
      return 'Imported $success ${success == 1 ? 'song' : 'songs'}, $failed failed';
    } else if (failed > 0) {
      return 'Failed to import $failed ${failed == 1 ? 'file' : 'files'}';
    } else {
      return 'No files selected';
    }
  }
}

/// Extension to convert Song to Companion for database operations
extension SongToCompanion on Song {
  SongsCompanion toCompanion() {
    return SongsCompanion.insert(
      sourceId: sourceId,
      id: id,
      title: title,
      albumId: drift.Value(albumId),
      artistId: drift.Value(artistId),
      artist: drift.Value(artist),
      album: drift.Value(album),
      duration: drift.Value(duration),
      track: drift.Value(track),
      disc: drift.Value(disc),
      genre: drift.Value(genre),
      downloadFilePath: drift.Value(downloadFilePath),
      starred: drift.Value(starred),
      userRating: drift.Value(userRating),
      thumbsUpCount: drift.Value(thumbsUpCount),
      thumbsDownCount: drift.Value(thumbsDownCount),
    );
  }
}
