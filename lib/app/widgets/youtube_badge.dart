import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../database/database.dart';

/// A badge widget that indicates a track is from YouTube
///
/// This widget displays a small "YT" badge with YouTube's signature red color
/// to visually distinguish YouTube tracks from local library tracks.
///
/// Usage:
/// ```dart
/// YouTubeBadge(isYouTube: true) // Shows badge
/// YouTubeBadge(isYouTube: false) // Shows nothing
/// ```
class YouTubeBadge extends StatelessWidget {
  /// Whether this track is from YouTube
  final bool isYouTube;

  /// Size variant of the badge
  final YouTubeBadgeSize size;

  const YouTubeBadge({
    super.key,
    required this.isYouTube,
    this.size = YouTubeBadgeSize.normal,
  });

  @override
  Widget build(BuildContext context) {
    if (!isYouTube) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dimensions based on size
    final double horizontalPadding;
    final double verticalPadding;
    final double iconSize;
    final double fontSize;
    final double borderRadius;

    switch (size) {
      case YouTubeBadgeSize.small:
        horizontalPadding = 4;
        verticalPadding = 2;
        iconSize = 10;
        fontSize = 8;
        borderRadius = 3;
        break;
      case YouTubeBadgeSize.normal:
        horizontalPadding = 6;
        verticalPadding = 3;
        iconSize = 12;
        fontSize = 10;
        borderRadius = 4;
        break;
      case YouTubeBadgeSize.large:
        horizontalPadding = 8;
        verticalPadding = 4;
        iconSize = 14;
        fontSize = 11;
        borderRadius = 5;
        break;
    }

    // YouTube's signature red color
    final badgeColor = isDark ? Colors.red.shade700 : Colors.red.shade600;

    return Tooltip(
      message: 'From YouTube',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: iconSize,
              color: Colors.white,
            ),
            SizedBox(width: 2),
            Text(
              'YT',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Size variants for the YouTube badge
enum YouTubeBadgeSize {
  /// Small size for compact list items (8pt font)
  small,

  /// Normal size for standard list items (10pt font)
  normal,

  /// Large size for now playing screen (11pt font)
  large,
}

/// A more detailed track source indicator that shows streaming status
///
/// This widget shows not only the source (YouTube vs Local) but also
/// additional information like streaming quality or buffering status.
class TrackSourceIndicator extends StatelessWidget {
  /// Whether this track is from YouTube
  final bool isYouTube;

  /// Optional streaming quality text (e.g., "Opus 128kbps")
  final String? streamingQuality;

  /// Whether the track is currently buffering
  final bool isBuffering;

  const TrackSourceIndicator({
    super.key,
    required this.isYouTube,
    this.streamingQuality,
    this.isBuffering = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Source badge
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            YouTubeBadge(isYouTube: isYouTube),
            if (isBuffering) ...[
              const SizedBox(width: 8),
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ],
        ),

        // Streaming quality info
        if (isYouTube && streamingQuality != null) ...[
          const SizedBox(height: 4),
          Text(
            streamingQuality!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}

/// A widget that shows download status for YouTube tracks
///
/// This widget displays an indicator when a YouTube track has been
/// requested for download via Lidarr.
class LidarrDownloadIndicator extends ConsumerWidget {
  /// The YouTube video ID (without "youtube:" prefix)
  final String videoId;

  /// Size of the indicator icon
  final double size;

  const LidarrDownloadIndicator({
    super.key,
    required this.videoId,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final theme = Theme.of(context);

    return FutureBuilder<LidarrRequest?>(
      future: db.getLidarrRequestForVideo(videoId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final request = snapshot.data!;
        final IconData icon;
        final Color color;
        final String tooltip;

        switch (request.status) {
          case 'added':
            icon = Icons.download_for_offline;
            color = Colors.green;
            tooltip = 'Added to Lidarr: ${request.artistName}';
            break;
          case 'already_exists':
            icon = Icons.check_circle;
            color = Colors.blue;
            tooltip = '${request.artistName} already in library';
            break;
          case 'not_found':
            icon = Icons.search_off;
            color = Colors.orange;
            tooltip = 'Artist not found in MusicBrainz';
            break;
          case 'failed':
            icon = Icons.error_outline;
            color = Colors.red;
            tooltip = 'Download failed: ${request.errorMessage ?? "Unknown error"}';
            break;
          default:
            return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Tooltip(
            message: tooltip,
            child: Icon(
              icon,
              size: size,
              color: color,
            ),
          ),
        );
      },
    );
  }
}

/// A combined widget showing both YouTube badge and download status
class YouTubeTrackIndicator extends StatelessWidget {
  /// The song ID (with "youtube:" prefix)
  final String songId;

  /// Size variant
  final YouTubeBadgeSize size;

  const YouTubeTrackIndicator({
    super.key,
    required this.songId,
    this.size = YouTubeBadgeSize.normal,
  });

  @override
  Widget build(BuildContext context) {
    // Extract video ID if this is a YouTube track
    final isYouTube = songId.startsWith('youtube:');
    if (!isYouTube) {
      return const SizedBox.shrink();
    }

    final videoId = songId.replaceFirst('youtube:', '');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        YouTubeBadge(isYouTube: true, size: size),
        LidarrDownloadIndicator(videoId: videoId),
      ],
    );
  }
}
