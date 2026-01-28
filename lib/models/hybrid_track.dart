import 'package:freezed_annotation/freezed_annotation.dart';

import 'music.dart';
import 'youtube_models.dart';

part 'hybrid_track.freezed.dart';

/// Represents a track that can be either from local library or YouTube
///
/// This is used in hybrid discovery playlists to seamlessly blend
/// local tracks with YouTube content.
///
/// Usage:
/// ```dart
/// final localTrack = HybridTrack.local(song);
/// final youtubeTrack = HybridTrack.youtube(
///   videoId: 'abc123',
///   title: 'Song Title',
///   artist: 'Artist Name',
/// );
/// ```
@freezed
class HybridTrack with _$HybridTrack {
  /// Local library track
  const factory HybridTrack.local({
    required Song song,
  }) = LocalTrack;

  /// YouTube track
  const factory HybridTrack.youtube({
    required String videoId,
    required String title,
    required String artist,
    required int durationSeconds,
    String? thumbnailUrl,
    @Default(UserRating.unrated) UserRating userRating,
  }) = YouTubeTrack;
}

/// Extension methods for HybridTrack
extension HybridTrackX on HybridTrack {
  /// Get the track's unique identifier
  String get id => map(
        local: (track) => track.song.id,
        youtube: (track) => track.videoId,
      );

  /// Get the track's title
  String get title => map(
        local: (track) => track.song.title,
        youtube: (track) => track.title,
      );

  /// Get the track's artist
  String get artist => map(
        local: (track) => track.song.artist ?? 'Unknown Artist',
        youtube: (track) => track.artist,
      );

  /// Get the track's duration
  Duration? get duration => map(
        local: (track) => track.song.duration,
        youtube: (track) => Duration(seconds: track.durationSeconds),
      );

  /// Get user rating for this track
  UserRating get rating => map(
        local: (track) => track.song.userRating,
        youtube: (track) => track.userRating,
      );

  /// Check if this is a local track
  bool get isLocal => map(
        local: (_) => true,
        youtube: (_) => false,
      );

  /// Check if this is a YouTube track
  bool get isYouTube => map(
        local: (_) => false,
        youtube: (_) => true,
      );

  /// Get the local song if this is a local track
  Song? get localSong => map(
        local: (track) => track.song,
        youtube: (_) => null,
      );

  /// Get the YouTube video ID if this is a YouTube track
  String? get youTubeVideoId => map(
        local: (_) => null,
        youtube: (track) => track.videoId,
      );

  /// Get thumbnail URL if available
  String? get thumbnailUrl => map(
        local: (track) =>
            null, // Could extract from Song if coverArt is available
        youtube: (track) => track.thumbnailUrl,
      );

  /// Get the source type as a string for analytics
  String get sourceType => map(
        local: (_) => 'local',
        youtube: (_) => 'youtube',
      );
}

/// Factory methods for creating HybridTracks from various sources
extension HybridTrackFactory on HybridTrack {
  /// Create a HybridTrack from a Song
  static HybridTrack fromSong(Song song) {
    return HybridTrack.local(song: song);
  }

  /// Create a HybridTrack from YouTube search result
  static HybridTrack fromYouTubeSearchResult(YouTubeSearchResult result) {
    return HybridTrack.youtube(
      videoId: result.videoId,
      title: result.title,
      artist: result.author,
      durationSeconds: result.lengthSeconds,
      thumbnailUrl: result.thumbnail,
    );
  }

  /// Create a list of HybridTracks from a list of Songs
  static List<HybridTrack> fromSongs(List<Song> songs) {
    return songs.map((song) => HybridTrack.local(song: song)).toList();
  }

  /// Create a list of HybridTracks from YouTube search results
  static List<HybridTrack> fromYouTubeSearchResults(
    List<YouTubeSearchResult> results,
  ) {
    return results
        .map((result) => HybridTrack.youtube(
              videoId: result.videoId,
              title: result.title,
              artist: result.author,
              durationSeconds: result.lengthSeconds,
              thumbnailUrl: result.thumbnail,
            ))
        .toList();
  }
}

/// Weighted hybrid track with scoring information for recommendations
class WeightedHybridTrack {
  final HybridTrack track;
  final double score;
  final Map<String, double> scoreBreakdown;

  const WeightedHybridTrack({
    required this.track,
    required this.score,
    required this.scoreBreakdown,
  });

  @override
  String toString() => 'WeightedHybridTrack(${track.title} by ${track.artist}, '
      'source: ${track.sourceType}, score: ${score.toStringAsFixed(3)})';
}
