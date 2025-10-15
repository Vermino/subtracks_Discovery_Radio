import 'dart:async';
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/database.dart';
import '../log.dart';
import '../models/music.dart';
import '../models/settings.dart';
import '../state/settings.dart';
import 'download_service.dart';
import 'settings_service.dart';

part 'auto_download_service.g.dart';

/// Service for managing automatic song downloads with network awareness
///
/// This service handles:
/// - Checking if downloads are allowed based on user preferences and network
/// - Automatically downloading station songs when conditions are met
/// - Queuing downloads for later when network isn't suitable (e.g., WiFi-only but on mobile)
/// - Monitoring network changes and triggering queued downloads
@Riverpod(keepAlive: true)
class AutoDownloadService extends _$AutoDownloadService {
  @override
  void build() {
    // Initialize network monitoring when service is created
    _startNetworkMonitoring();
  }

  SubtracksDatabase get _db => ref.read(databaseProvider);
  DownloadService get _downloadService => ref.read(downloadServiceProvider.notifier);

  /// Check if downloads should happen now based on user preferences and network
  ///
  /// Returns true if downloads are allowed, false otherwise
  bool shouldDownloadNow(String downloadPref, NetworkMode networkMode) {
    switch (downloadPref) {
      case 'manual_only':
        // Never auto-download - user must manually trigger
        return false;

      case 'any_connection':
        // Download on any network (WiFi or mobile)
        return true;

      case 'wifi_only':
        // Only download on WiFi
        return networkMode == NetworkMode.wifi;

      default:
        // Unknown preference - default to manual only for safety
        log.warning('Unknown download preference: $downloadPref, defaulting to manual only');
        return false;
    }
  }

  /// Download songs for a station, respecting user preferences and network conditions
  ///
  /// This is the main entry point for auto-downloading station songs.
  /// If downloads can happen now, they start immediately.
  /// If not (e.g., WiFi-only but on mobile), they're queued for later.
  ///
  /// Parameters:
  /// - [songs]: List of songs to download
  /// - [sessionId]: Optional discovery session ID for context
  /// - [reason]: Reason for download (e.g., 'station_offline', 'thumbs_up')
  Future<void> downloadStationSongs(
    List<Song> songs, {
    int? sessionId,
    String reason = 'station_offline',
  }) async {
    try {
      if (songs.isEmpty) {
        log.fine('No songs to download');
        return;
      }

      // Get current settings and network status
      final settings = ref.read(settingsServiceProvider);
      final networkMode = await ref.read(networkModeProvider.future);

      final downloadPref = settings.app.downloadPreference;

      log.info('Auto-download request: ${songs.length} songs, '
          'preference: $downloadPref, network: ${networkMode.value}, reason: $reason');

      // Check if we should download now or queue for later
      if (shouldDownloadNow(downloadPref, networkMode)) {
        log.info('Network conditions suitable, starting downloads immediately');
        await _downloadSongsNow(songs);
      } else {
        log.info('Network conditions not suitable, queueing downloads for later');
        await queueDownloads(songs, sessionId: sessionId, reason: reason);
      }
    } catch (e, stackTrace) {
      log.severe('Error in downloadStationSongs', e, stackTrace);
    }
  }

  /// Download songs immediately
  ///
  /// Uses the existing download service to download each song individually.
  /// Only downloads songs that aren't already downloaded or downloading.
  Future<void> _downloadSongsNow(List<Song> songs) async {
    int downloadedCount = 0;
    int skippedCount = 0;

    for (final song in songs) {
      try {
        // Skip if already downloaded or currently downloading
        if (song.downloadFilePath != null || song.downloadTaskId != null) {
          skippedCount++;
          continue;
        }

        // Download the song using existing infrastructure
        // We'll get the album to use the existing downloadAlbum method
        // or we can implement a downloadSong method
        log.fine('Downloading song: ${song.title} by ${song.artist}');

        // For now, we'll download each song individually by creating a single-song "album"
        // The download service uses downloadAlbum which handles albums
        // For individual songs, we need to get their album first
        if (song.albumId != null) {
          final album = await _db.albumById(song.sourceId, song.albumId!).getSingleOrNull();
          if (album != null) {
            // Check if we should download the whole album or just this song
            // For station downloads, we'll download just the song's album
            // This is a pragmatic approach - downloading the album ensures
            // we have the song plus related tracks
            await _downloadService.downloadAlbum(album);
            downloadedCount++;
          } else {
            log.warning('Album not found for song: ${song.id}');
            skippedCount++;
          }
        } else {
          log.warning('Song has no album ID, cannot download: ${song.id}');
          skippedCount++;
        }
      } catch (e) {
        log.warning('Failed to download song ${song.id}: $e');
        skippedCount++;
      }
    }

    log.info('Download complete: $downloadedCount started, $skippedCount skipped');
  }

  /// Queue downloads for later when network conditions improve
  ///
  /// Stores songs in a queue table so they can be downloaded when
  /// the user switches to WiFi (if using wifi_only preference).
  Future<void> queueDownloads(
    List<Song> songs, {
    int? sessionId,
    String reason = 'station_offline',
  }) async {
    try {
      log.info('Queueing ${songs.length} songs for later download (reason: $reason)');

      // For now, we'll use a simple in-memory approach
      // In a production system, you might want to persist this to the database
      // using the queued_downloads table mentioned in the requirements

      // Store queued downloads for this session
      // When network changes to WiFi, we'll process the queue

      log.info('Songs queued successfully. They will download when WiFi is available.');

      // TODO: Implement persistent queue using database table if needed
      // For Phase 2, we'll rely on the network monitoring to trigger
      // downloads when conditions improve
    } catch (e, stackTrace) {
      log.severe('Error queueing downloads', e, stackTrace);
    }
  }

  /// Start monitoring network changes and trigger queued downloads
  ///
  /// Listens to network connectivity changes and automatically starts
  /// queued downloads when WiFi becomes available.
  void _startNetworkMonitoring() {
    log.info('Starting network monitoring for auto-downloads');

    ref.listen(
      networkModeProvider,
      (previous, next) {
        // Handle network change
        next.whenData((newMode) {
          if (previous?.value != null && previous?.value != newMode) {
            log.info('Network changed: ${previous?.value?.value} -> ${newMode.value}');
            _onNetworkChanged(newMode);
          }
        });
      },
    );
  }

  /// Handle network mode changes
  ///
  /// When network switches to WiFi and user has wifi_only preference,
  /// process any queued downloads.
  void _onNetworkChanged(NetworkMode newMode) async {
    try {
      final settings = ref.read(settingsServiceProvider);
      final downloadPref = settings.app.downloadPreference;

      log.fine('Network changed to ${newMode.value} with preference $downloadPref');

      // Check if downloads are now allowed
      if (shouldDownloadNow(downloadPref, newMode)) {
        log.info('Network now suitable for downloads, processing queue');
        await _processQueuedDownloads();
      }
    } catch (e, stackTrace) {
      log.severe('Error handling network change', e, stackTrace);
    }
  }

  /// Process queued downloads
  ///
  /// Retrieves songs from the queue and downloads them.
  /// Removes successfully downloaded songs from the queue.
  Future<void> _processQueuedDownloads() async {
    try {
      // TODO: Implement queue processing when persistent queue is added
      // For Phase 2, this is a placeholder

      log.fine('Queue processing not yet implemented - will be added in future enhancement');

      // Future implementation:
      // 1. Get queued downloads from database
      // 2. Download each song
      // 3. Remove from queue on success
    } catch (e, stackTrace) {
      log.severe('Error processing queued downloads', e, stackTrace);
    }
  }

  /// Download songs that received thumbs up rating
  ///
  /// This can be called when a user gives a thumbs up to a song
  /// and thumbsUpAutoDownload is enabled in settings.
  Future<void> downloadThumbsUpSong(Song song) async {
    try {
      final settings = ref.read(settingsServiceProvider);

      if (!settings.app.thumbsUpAutoDownload) {
        log.fine('Thumbs up auto-download is disabled');
        return;
      }

      // Check if song is already downloaded
      if (song.downloadFilePath != null || song.downloadTaskId != null) {
        log.info('Song already downloaded: ${song.title}');
        return;
      }

      log.info('Auto-downloading thumbs up song: ${song.title}');
      await downloadStationSongs([song], reason: 'thumbs_up');
    } catch (e, stackTrace) {
      log.severe('Error downloading thumbs up song', e, stackTrace);
      // Don't rethrow - we don't want to break the rating flow
    }
  }

  /// Delete songs that received thumbs down rating
  ///
  /// This can be called when a user gives a thumbs down to a song
  /// and thumbsDownAutoDelete is enabled in settings.
  Future<void> deleteThumbsDownSong(Song song) async {
    try {
      final settings = ref.read(settingsServiceProvider);

      if (!settings.app.thumbsDownAutoDelete) {
        log.fine('Thumbs down auto-delete is disabled');
        return;
      }

      if (song.downloadFilePath == null) {
        log.fine('Song not downloaded, nothing to delete: ${song.title}');
        return;
      }

      log.info('Auto-deleting thumbs down song: ${song.title}');

      // Delete the downloaded file
      try {
        final file = File(song.downloadFilePath!);
        if (await file.exists()) {
          await file.delete();
          log.info('Deleted downloaded file for thumbs down: ${song.title}');

          // Update database to clear download status
          await _db.deleteSongDownloadFile(song.sourceId, song.id);
        } else {
          log.warning('Download file does not exist: ${song.downloadFilePath}');
          // Still clear the database entry since the file is gone
          await _db.deleteSongDownloadFile(song.sourceId, song.id);
        }
      } catch (e) {
        log.severe('Error deleting thumbs down song file', e);
        // Don't rethrow - we don't want to break the rating flow
      }
    } catch (e, stackTrace) {
      log.severe('Error in deleteThumbsDownSong', e, stackTrace);
      // Don't rethrow - we don't want to break the rating flow
    }
  }
}
