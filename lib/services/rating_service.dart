import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/database.dart';
import '../log.dart';
import '../models/music.dart';
import '../state/audio.dart';
import 'audio_service.dart';

part 'rating_service.g.dart';

@Riverpod(keepAlive: true)
class RatingService extends _$RatingService {
  SubtracksDatabase get _db => ref.read(databaseProvider);

  @override
  void build() {
    // Service is stateless - no initial state needed
  }

  /// Rate a song with thumbs up
  Future<void> rateSongThumbsUp(Song song) async {
    await _updateSongRating(song, UserRating.thumbsUp);
  }

  /// Rate a song with thumbs down
  Future<void> rateSongThumbsDown(Song song) async {
    await _updateSongRating(song, UserRating.thumbsDown);

    // Check if this is the currently playing song and skip to next if so
    final currentMediaItem = ref.read(mediaItemProvider).valueOrNull;
    if (currentMediaItem?.id == song.id) {
      // This is the currently playing song, skip to next track
      final audioControl = ref.read(audioControlProvider);
      await audioControl.skipToNext();
    }
  }

  /// Remove rating from a song (set to unrated)
  Future<void> clearSongRating(Song song) async {
    await _updateSongRating(song, UserRating.unrated);
  }

  /// Toggle rating: unrated -> thumbsUp -> thumbsDown -> unrated
  Future<void> toggleSongRating(Song song) async {
    final currentRating = song.userRating;
    UserRating newRating;

    switch (currentRating) {
      case UserRating.unrated:
        newRating = UserRating.thumbsUp;
        break;
      case UserRating.thumbsUp:
        newRating = UserRating.thumbsDown;
        break;
      case UserRating.thumbsDown:
        newRating = UserRating.unrated;
        break;
    }

    await _updateSongRating(song, newRating);

    // If we just rated thumbs down and it's currently playing, skip to next
    if (newRating == UserRating.thumbsDown) {
      final currentMediaItem = ref.read(mediaItemProvider).valueOrNull;
      if (currentMediaItem?.id == song.id) {
        final audioControl = ref.read(audioControlProvider);
        await audioControl.skipToNext();
      }
    }
  }

  /// Update song rating in database with counter updates
  Future<void> _updateSongRating(Song song, UserRating newRating) async {
    final oldRating = song.userRating;

    // Skip if rating hasn't changed
    if (oldRating == newRating) {
      log.fine('Rating unchanged for song ${song.id}: ${oldRating.name}');
      return;
    }

    log.info('Updating rating for song ${song.id} (${song.title}): ${oldRating.name} -> ${newRating.name}');

    await _db.transaction(() async {
      // Update the rating field
      await _db.updateSongRating(song.sourceId, song.id, newRating);

      // Update counters based on old and new ratings
      // Decrement old counter if it was rated
      if (oldRating == UserRating.thumbsUp) {
        await _db.decrementThumbsUpCount(song.sourceId, song.id);
        log.fine('Decremented thumbs_up_count for song ${song.id}');
      } else if (oldRating == UserRating.thumbsDown) {
        await _db.decrementThumbsDownCount(song.sourceId, song.id);
        log.fine('Decremented thumbs_down_count for song ${song.id}');
      }

      // Increment new counter if it's being rated
      if (newRating == UserRating.thumbsUp) {
        await _db.incrementThumbsUpCount(song.sourceId, song.id);
        log.fine('Incremented thumbs_up_count for song ${song.id}');
      } else if (newRating == UserRating.thumbsDown) {
        await _db.incrementThumbsDownCount(song.sourceId, song.id);
        log.fine('Incremented thumbs_down_count for song ${song.id}');
      }
    });

    log.info('Rating update complete for song ${song.id}');
  }

  /// Get all liked songs (thumbs up) for a given source
  Future<List<Song>> getLikedSongs(int sourceId) async {
    return await _db.getLikedSongs(sourceId);
  }

  /// Get all disliked songs (thumbs down) for a given source
  Future<List<Song>> getDislikedSongs(int sourceId) async {
    return await _db.getDislikedSongs(sourceId);
  }

  /// Get songs filtered by rating for a source
  Future<List<Song>> getSongsByRating(int sourceId, UserRating rating) async {
    return await _db.getSongsWithRating(sourceId, rating);
  }

  /// Get rating statistics for a source
  Future<Map<UserRating, int>> getRatingStats(int sourceId) async {
    final stats = await _db.getRatingStatistics(sourceId);
    return {
      UserRating.unrated: stats['unrated'] ?? 0,
      UserRating.thumbsUp: stats['thumbsUp'] ?? 0,
      UserRating.thumbsDown: stats['thumbsDown'] ?? 0,
    };
  }

  /// Check if a song is liked (thumbs up)
  bool isSongLiked(Song song) {
    return song.userRating == UserRating.thumbsUp;
  }

  /// Check if a song is disliked (thumbs down)
  bool isSongDisliked(Song song) {
    return song.userRating == UserRating.thumbsDown;
  }

  /// Check if a song is unrated
  bool isSongUnrated(Song song) {
    return song.userRating == UserRating.unrated;
  }

  /// Get most loved songs (sorted by thumbs_up_count)
  Future<List<Song>> getMostLovedSongs(int sourceId, {int limit = 50, int offset = 0}) async {
    return await _db.getMostLovedSongs(sourceId, limit: limit, offset: offset);
  }

  /// Get most disliked songs (sorted by thumbs_down_count)
  Future<List<Song>> getMostDislikedSongs(int sourceId, {int limit = 50, int offset = 0}) async {
    return await _db.getMostDislikedSongs(sourceId, limit: limit, offset: offset);
  }
}