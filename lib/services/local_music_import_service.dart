import 'dart:io';
import 'dart:typed_data';
import 'package:id3/id3.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/drift.dart' show InsertMode;
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/database.dart';
import '../models/music.dart';
import '../state/settings.dart';
import '../log.dart';

part 'local_music_import_service.g.dart';

/// Source ID reserved for local music files
const int kLocalMusicSourceId = 0;

/// Service for importing local music files from device storage
@Riverpod(keepAlive: true)
class LocalMusicImportService extends _$LocalMusicImportService {
  late final SubtracksDatabase _db;

  @override
  Future<void> build() async {
    _db = ref.read(databaseProvider);

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

  /// Open folder picker and import music with Artist/Album structure
  ///
  /// Expected folder structure:
  /// ```
  /// Music/
  /// ├── Artist Name/
  /// │   ├── artist.jpg (optional)
  /// │   ├── Album 1/
  /// │   │   ├── cover.jpg
  /// │   │   └── songs...
  /// │   └── Album 2/
  /// │       └── songs...
  /// ```
  Future<ImportResult> importFromFolder() async {
    try {
      // Open folder picker
      final selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) {
        return const ImportResult(
          success: 0,
          failed: 0,
          errors: [],
        );
      }

      log.info('Importing from folder: $selectedDirectory');

      final directory = Directory(selectedDirectory);
      if (!await directory.exists()) {
        return ImportResult(
          success: 0,
          failed: 1,
          errors: ['Selected directory does not exist'],
        );
      }

      final importedSongs = <Song>[];
      final errors = <String>[];

      // Scan for Artist/Album structure
      await _scanArtistFolder(directory, importedSongs, errors);

      log.info('Import complete: ${importedSongs.length} songs imported, ${errors.length} errors');

      return ImportResult(
        success: importedSongs.length,
        failed: errors.length,
        errors: errors,
      );
    } catch (e, stackTrace) {
      log.severe('Failed to import from folder', e, stackTrace);
      return ImportResult(
        success: 0,
        failed: 1,
        errors: ['Failed to open folder picker: $e'],
      );
    }
  }

  /// Scan a directory for artist folders
  Future<void> _scanArtistFolder(
    Directory rootDir,
    List<Song> importedSongs,
    List<String> errors,
  ) async {
    try {
      // Check if this directory contains audio files directly
      final audioFiles = await _findAudioFiles(rootDir);

      if (audioFiles.isNotEmpty) {
        // This directory contains audio files, treat it as an album
        log.fine('Found ${audioFiles.length} audio files in ${rootDir.path}');
        await _importAlbumFolder(rootDir, null, importedSongs, errors);
        return;
      }

      // Otherwise, scan subdirectories for artist/album structure
      await for (final entity in rootDir.list()) {
        if (entity is Directory) {
          final dirName = path.basename(entity.path);

          // Skip hidden folders and system folders
          if (dirName.startsWith('.') || dirName.startsWith('_')) {
            continue;
          }

          log.fine('Scanning artist folder: $dirName');

          // Check for artist image
          final artistImage = await _findArtistImage(entity);

          // Scan for album folders within artist folder
          await for (final albumEntity in entity.list()) {
            if (albumEntity is Directory) {
              final albumName = path.basename(albumEntity.path);

              if (albumName.startsWith('.') || albumName.startsWith('_')) {
                continue;
              }

              log.fine('  Scanning album folder: $albumName');
              await _importAlbumFolder(
                albumEntity,
                artistImage,
                importedSongs,
                errors,
                artistName: dirName,
              );
            }
          }
        }
      }
    } catch (e, stackTrace) {
      log.warning('Error scanning artist folder: ${rootDir.path}', e, stackTrace);
      errors.add('Error scanning ${rootDir.path}: $e');
    }
  }

  /// Import all songs from an album folder
  Future<void> _importAlbumFolder(
    Directory albumDir,
    File? artistImage,
    List<Song> importedSongs,
    List<String> errors, {
    String? artistName,
  }) async {
    try {
      // Find album cover
      final albumCover = await _findAlbumCover(albumDir);

      // Find all audio files
      final audioFiles = await _findAudioFiles(albumDir);

      if (audioFiles.isEmpty) {
        log.fine('No audio files found in ${albumDir.path}');
        return;
      }

      log.info('Importing ${audioFiles.length} songs from ${path.basename(albumDir.path)}');

      // Import each audio file
      for (final audioFile in audioFiles) {
        try {
          final song = await _importFile(
            audioFile.path,
            albumCoverFile: albumCover,
            artistImageFile: artistImage,
            albumNameOverride: artistName != null ? path.basename(albumDir.path) : null,
            artistNameOverride: artistName,
          );

          if (song != null) {
            importedSongs.add(song);
          } else {
            errors.add('Failed to import ${path.basename(audioFile.path)}');
          }
        } catch (e) {
          log.warning('Error importing ${audioFile.path}', e);
          errors.add('Error importing ${path.basename(audioFile.path)}: $e');
        }
      }
    } catch (e, stackTrace) {
      log.warning('Error importing album folder: ${albumDir.path}', e, stackTrace);
      errors.add('Error importing album ${path.basename(albumDir.path)}: $e');
    }
  }

  /// Find audio files in a directory
  Future<List<File>> _findAudioFiles(Directory dir) async {
    final audioExtensions = {'.mp3', '.flac', '.ogg', '.opus', '.m4a', '.aac', '.wav'};
    final audioFiles = <File>[];

    try {
      await for (final entity in dir.list()) {
        if (entity is File) {
          final ext = path.extension(entity.path).toLowerCase();
          if (audioExtensions.contains(ext)) {
            audioFiles.add(entity);
          }
        }
      }
    } catch (e) {
      log.warning('Error finding audio files in ${dir.path}', e);
    }

    return audioFiles;
  }

  /// Find artist image in artist folder
  Future<File?> _findArtistImage(Directory artistDir) async {
    final imageNames = ['artist', 'folder', 'artist-image', 'photo'];
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.webp'];

    try {
      await for (final entity in artistDir.list()) {
        if (entity is File) {
          final fileName = path.basenameWithoutExtension(entity.path).toLowerCase();
          final ext = path.extension(entity.path).toLowerCase();

          if (imageNames.contains(fileName) && imageExtensions.contains(ext)) {
            log.fine('Found artist image: ${entity.path}');
            return entity;
          }
        }
      }
    } catch (e) {
      log.warning('Error finding artist image in ${artistDir.path}', e);
    }

    return null;
  }

  /// Find album cover in album folder
  Future<File?> _findAlbumCover(Directory albumDir) async {
    final coverNames = ['cover', 'folder', 'albumart', 'album', 'front', 'artwork'];
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.webp'];

    try {
      await for (final entity in albumDir.list()) {
        if (entity is File) {
          final fileName = path.basenameWithoutExtension(entity.path).toLowerCase();
          final ext = path.extension(entity.path).toLowerCase();

          if (coverNames.contains(fileName) && imageExtensions.contains(ext)) {
            log.fine('Found album cover: ${entity.path}');
            return entity;
          }
        }
      }

      // If no named cover found, look for any image file
      await for (final entity in albumDir.list()) {
        if (entity is File) {
          final ext = path.extension(entity.path).toLowerCase();
          if (imageExtensions.contains(ext)) {
            log.fine('Using image as album cover: ${entity.path}');
            return entity;
          }
        }
      }
    } catch (e) {
      log.warning('Error finding album cover in ${albumDir.path}', e);
    }

    return null;
  }

  /// Import a single audio file
  Future<Song?> _importFile(
    String filePath, {
    File? albumCoverFile,
    File? artistImageFile,
    String? albumNameOverride,
    String? artistNameOverride,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return null;
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

    // Extract metadata from ID3 tags (for MP3) or use filename
    String title = path.basenameWithoutExtension(fileName);
    String artist = artistNameOverride ?? 'Unknown Artist';
    String album = albumNameOverride ?? 'Unknown Album';
    String? genre;
    int? year;
    int? trackNumber;
    int? discNumber;
    Duration? duration;
    Uint8List? embeddedAlbumArt;

    // Try to read ID3 tags for MP3 files
    if (path.extension(filePath).toLowerCase() == '.mp3') {
      try {
        final bytes = await File(destinationPath).readAsBytes();
        final mp3Instance = MP3Instance(bytes);

        if (mp3Instance.parseTagsSync()) {
          // Extract tags from mp3Instance properties
          if (mp3Instance.metaTags != null) {
            final tags = mp3Instance.metaTags!;

            title = tags['Title']?.trim().isNotEmpty == true
                ? tags['Title']!
                : title;

            // Only use ID3 artist/album if not overridden by folder structure
            if (artistNameOverride == null) {
              artist = tags['Artist']?.trim().isNotEmpty == true
                  ? tags['Artist']!
                  : artist;
            }

            if (albumNameOverride == null) {
              album = tags['Album']?.trim().isNotEmpty == true
                  ? tags['Album']!
                  : album;
            }

            genre = tags['Genre']?.trim().isNotEmpty == true
                ? tags['Genre']
                : null;

            if (tags['Year'] != null) {
              year = int.tryParse(tags['Year']!);
            }

            if (tags['Track'] != null) {
              // Handle track numbers like "1/12" or just "1"
              final trackStr = tags['Track']!.split('/').first;
              trackNumber = int.tryParse(trackStr);
            }

            if (tags['Disc'] != null) {
              final discStr = tags['Disc']!.split('/').first;
              discNumber = int.tryParse(discStr);
            }
          }

          // Extract embedded album art from ID3 tags
          if (mp3Instance.metaTags?['APIC'] != null) {
            try {
              // APIC contains the picture data
              final apicData = mp3Instance.metaTags!['APIC'];
              if (apicData is Map && apicData['Picture'] != null) {
                embeddedAlbumArt = apicData['Picture'] as Uint8List?;
                log.fine('Extracted embedded album art from MP3');
              }
            } catch (e) {
              log.warning('Failed to extract embedded album art', e);
            }
          }

          // Note: id3 package doesn't provide duration extraction
          // Duration will remain null for now
        }
      } catch (e) {
        log.warning('Failed to extract ID3 tags from $filePath', e);
      }
    }

    // Generate IDs for album and artist
    final albumId = 'local_album_${album.hashCode}';
    final artistId = 'local_artist_${artist.hashCode}';

    // Save artist image if provided
    String? artistImagePath;
    if (artistImageFile != null) {
      artistImagePath = await _saveArtistImage(artistId, artistImageFile);
    }

    // Create or update artist
    await _db.into(_db.artists).insert(
          ArtistsCompanion.insert(
            sourceId: kLocalMusicSourceId,
            id: artistId,
            name: artist,
            albumCount: 0, // Will be updated by trigger
            // Note: artistImagePath would need a new column in the artists table
          ),
          mode: InsertMode.insertOrIgnore,
        );

    // Save album cover (prioritize: folder image > embedded art)
    String? albumCoverPath;
    if (albumCoverFile != null) {
      albumCoverPath = await _saveAlbumCover(albumId, albumCoverFile);
    } else if (embeddedAlbumArt != null) {
      albumCoverPath = await _saveAlbumCoverFromBytes(albumId, embeddedAlbumArt);
    }

    // Create or update album with cover art path
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
            coverArt: drift.Value(albumCoverPath), // Store album cover path
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
      duration: duration,
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

  /// Get or create the album art cache directory
  Future<String> _getAlbumArtDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final albumArtDir = Directory(path.join(appDir.path, 'album_art'));

    if (!await albumArtDir.exists()) {
      await albumArtDir.create(recursive: true);
    }

    return albumArtDir.path;
  }

  /// Get or create the artist image cache directory
  Future<String> _getArtistImageDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final artistImageDir = Directory(path.join(appDir.path, 'artist_images'));

    if (!await artistImageDir.exists()) {
      await artistImageDir.create(recursive: true);
    }

    return artistImageDir.path;
  }

  /// Save album cover from file
  Future<String?> _saveAlbumCover(String albumId, File coverFile) async {
    try {
      final albumArtDir = await _getAlbumArtDirectory();
      final extension = path.extension(coverFile.path);
      final fileName = '${albumId}$extension';
      final destinationPath = path.join(albumArtDir, fileName);

      await coverFile.copy(destinationPath);
      log.fine('Saved album cover: $destinationPath');

      return destinationPath;
    } catch (e) {
      log.warning('Failed to save album cover', e);
      return null;
    }
  }

  /// Save album cover from bytes (embedded art)
  Future<String?> _saveAlbumCoverFromBytes(String albumId, Uint8List imageBytes) async {
    try {
      final albumArtDir = await _getAlbumArtDirectory();
      final fileName = '$albumId.jpg'; // Assume JPEG for embedded art
      final destinationPath = path.join(albumArtDir, fileName);

      final file = File(destinationPath);
      await file.writeAsBytes(imageBytes);
      log.fine('Saved embedded album cover: $destinationPath');

      return destinationPath;
    } catch (e) {
      log.warning('Failed to save embedded album cover', e);
      return null;
    }
  }

  /// Save artist image from file
  Future<String?> _saveArtistImage(String artistId, File imageFile) async {
    try {
      final artistImageDir = await _getArtistImageDirectory();
      final extension = path.extension(imageFile.path);
      final fileName = '${artistId}$extension';
      final destinationPath = path.join(artistImageDir, fileName);

      await imageFile.copy(destinationPath);
      log.fine('Saved artist image: $destinationPath');

      return destinationPath;
    } catch (e) {
      log.warning('Failed to save artist image', e);
      return null;
    }
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
      sourceId: this.sourceId,
      id: this.id,
      title: this.title,
      albumId: drift.Value(this.albumId),
      artistId: drift.Value(this.artistId),
      artist: drift.Value(this.artist),
      album: drift.Value(this.album),
      duration: drift.Value(this.duration),
      track: drift.Value(this.track),
      disc: drift.Value(this.disc),
      genre: drift.Value(this.genre),
      downloadFilePath: drift.Value(this.downloadFilePath),
      starred: drift.Value(this.starred),
      userRating: drift.Value(this.userRating),
      thumbsUpCount: drift.Value(this.thumbsUpCount),
      thumbsDownCount: drift.Value(this.thumbsDownCount),
    );
  }
}
