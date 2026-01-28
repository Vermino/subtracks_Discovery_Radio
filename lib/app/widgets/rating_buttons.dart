import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../database/database.dart';
import '../../log.dart';
import '../../models/lidarr_models.dart';
import '../../models/music.dart';
import '../../models/settings.dart';
import '../../services/audio_service.dart';
import '../../services/lidarr_service.dart';
import '../../services/rating_service.dart';
import '../../services/settings_service.dart';
import '../../state/audio.dart';
import '../../state/settings.dart';

/// Rating buttons widget for thumbs up/down functionality
/// Supports both global ratings and station-specific ratings for discovery stations
class SongRatingButtons extends HookConsumerWidget {
  final Song song;
  final double size;
  final bool showBoth;

  /// Optional: Station ID for station-specific ratings (discovery stations)
  /// If provided, ratings will be saved to discovery_interactions table
  /// If null, ratings will be saved globally to songs.user_rating
  final int? stationId;

  const SongRatingButtons({
    super.key,
    required this.song,
    this.size = 24,
    this.showBoth = true,
    this.stationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingService = ref.read(ratingServiceProvider.notifier);
    final db = ref.watch(databaseProvider);

    // Use a stateful value that rebuilds the widget when ratings change
    final refreshKey = useState(0);

    // If station ID is provided, load station-specific rating
    if (stationId != null) {
      return FutureBuilder<List<DiscoveryInteraction>>(
        // Use refreshKey to force rebuild when ratings change
        key: ValueKey('${stationId}_${song.id}_${refreshKey.value}'),
        future: db.getStationInteractionsBySongId(stationId!, song.id),
        builder: (context, snapshot) {
          // Determine current rating from interactions
          final interactions = snapshot.data ?? [];
          final hasThumbsUp =
              interactions.any((i) => i.interactionType == 'thumbs_up');
          final hasThumbsDown =
              interactions.any((i) => i.interactionType == 'thumbs_down');

          if (showBoth) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ThumbsUpButton(
                  song: song,
                  size: size,
                  isActive: hasThumbsUp,
                  onTap: () async {
                    await _handleStationThumbsUp(ref, song, hasThumbsUp);
                    refreshKey.value++; // Trigger rebuild
                  },
                ),
                const SizedBox(width: 8),
                _ThumbsDownButton(
                  song: song,
                  size: size,
                  isActive: hasThumbsDown,
                  onTap: () async {
                    await _handleStationThumbsDown(ref, song, hasThumbsDown);
                    refreshKey.value++; // Trigger rebuild
                  },
                ),
              ],
            );
          } else {
            // For single button mode in station context
            final rating = hasThumbsUp
                ? UserRating.thumbsUp
                : hasThumbsDown
                    ? UserRating.thumbsDown
                    : UserRating.unrated;

            return _ToggleButton(
              song: song,
              size: size,
              rating: rating,
              onTap: () async {
                await _handleStationToggle(ref, song, rating);
                refreshKey.value++; // Trigger rebuild
              },
            );
          }
        },
      );
    }

    // Global rating mode (original behavior)
    final currentRating = song.userRating;

    if (showBoth) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ThumbsUpButton(
            song: song,
            size: size,
            isActive: currentRating == UserRating.thumbsUp,
            onTap: () => _handleThumbsUp(ratingService, song, context, ref),
          ),
          const SizedBox(width: 8),
          _ThumbsDownButton(
            song: song,
            size: size,
            isActive: currentRating == UserRating.thumbsDown,
            onTap: () => _handleThumbsDown(ratingService, song, context, ref),
          ),
        ],
      );
    } else {
      // Single toggle button - cycles through states
      return _ToggleButton(
        song: song,
        size: size,
        rating: currentRating,
        onTap: () => _handleToggle(ratingService, song),
      );
    }
  }

  Future<void> _handleThumbsUp(RatingService ratingService, Song song,
      BuildContext context, WidgetRef ref) async {
    if (song.userRating == UserRating.thumbsUp) {
      await ratingService.clearSongRating(song);
    } else {
      await ratingService.rateSongThumbsUp(song);

      // Show feedback if auto-download triggered
      if (context.mounted) {
        await _showAutoDownloadFeedback(context, ref, song);
      }
    }
  }

  Future<void> _handleThumbsDown(RatingService ratingService, Song song,
      BuildContext context, WidgetRef ref) async {
    if (song.userRating == UserRating.thumbsDown) {
      await ratingService.clearSongRating(song);
    } else {
      await ratingService.rateSongThumbsDown(song);

      // Show feedback if auto-delete triggered
      if (context.mounted) {
        await _showAutoDeleteFeedback(context, ref, song);
      }
    }
  }

  Future<void> _handleToggle(RatingService ratingService, Song song) async {
    await ratingService.toggleSongRating(song);
  }

  // Station-specific rating handlers
  Future<void> _handleStationThumbsUp(
      WidgetRef ref, Song song, bool hasThumbsUp) async {
    final db = ref.read(databaseProvider);

    if (hasThumbsUp) {
      // Remove the thumbs up from this station
      await db.removeDiscoveryRating(stationId!, song.id, 'thumbs_up');
      // Note: We don't decrement global counter when removing station-specific rating
      // because the global counter represents total lifetime thumbs ups across all contexts
    } else {
      // Add thumbs up to this station (and remove any existing thumbs down)
      await db.removeDiscoveryRating(stationId!, song.id, 'thumbs_down');
      await db.recordDiscoveryInteraction(
        sessionId: stationId!,
        songId: song.id,
        interactionType: 'thumbs_up',
        positionInPlaylist: 0, // Position not relevant for manual ratings
      );

      // Increment global thumbs up counter
      await db.incrementThumbsUpCount(song.sourceId, song.id);

      // Trigger Lidarr download for YouTube tracks
      await _triggerLidarrDownload(ref, song);
    }
  }

  Future<void> _handleStationThumbsDown(
      WidgetRef ref, Song song, bool hasThumbsDown) async {
    final db = ref.read(databaseProvider);

    if (hasThumbsDown) {
      // Remove the thumbs down from this station
      await db.removeDiscoveryRating(stationId!, song.id, 'thumbs_down');
      // Note: We don't decrement global counter when removing station-specific rating
      // because the global counter represents total lifetime thumbs downs across all contexts
    } else {
      // Add thumbs down to this station (and remove any existing thumbs up)
      await db.removeDiscoveryRating(stationId!, song.id, 'thumbs_up');
      await db.recordDiscoveryInteraction(
        sessionId: stationId!,
        songId: song.id,
        interactionType: 'thumbs_down',
        positionInPlaylist: 0, // Position not relevant for manual ratings
      );

      // Increment global thumbs down counter
      await db.incrementThumbsDownCount(song.sourceId, song.id);

      // If this is the currently playing song, skip to next
      final audioControl = ref.read(audioControlProvider);
      final currentMediaItem = ref.read(mediaItemProvider).valueOrNull;
      if (currentMediaItem?.id == song.id) {
        await audioControl.skipToNext();
      }
    }
  }

  Future<void> _handleStationToggle(
      WidgetRef ref, Song song, UserRating currentRating) async {
    final db = ref.read(databaseProvider);

    // Cycle: unrated -> thumbsUp -> thumbsDown -> unrated
    switch (currentRating) {
      case UserRating.unrated:
        // Add thumbs up
        await db.recordDiscoveryInteraction(
          sessionId: stationId!,
          songId: song.id,
          interactionType: 'thumbs_up',
          positionInPlaylist: 0,
        );
        // Increment global thumbs up counter
        await db.incrementThumbsUpCount(song.sourceId, song.id);
        break;

      case UserRating.thumbsUp:
        // Remove thumbs up and add thumbs down
        await db.removeDiscoveryRating(stationId!, song.id, 'thumbs_up');
        await db.recordDiscoveryInteraction(
          sessionId: stationId!,
          songId: song.id,
          interactionType: 'thumbs_down',
          positionInPlaylist: 0,
        );
        // Increment global thumbs down counter
        await db.incrementThumbsDownCount(song.sourceId, song.id);

        // Skip if currently playing
        final audioControl = ref.read(audioControlProvider);
        final currentMediaItem = ref.read(mediaItemProvider).valueOrNull;
        if (currentMediaItem?.id == song.id) {
          await audioControl.skipToNext();
        }
        break;

      case UserRating.thumbsDown:
        // Remove thumbs down (back to unrated)
        await db.removeDiscoveryRating(stationId!, song.id, 'thumbs_down');
        // Note: We don't decrement global counter when removing station-specific rating
        break;
    }
  }

  /// Trigger Lidarr download for YouTube tracks
  Future<void> _triggerLidarrDownload(WidgetRef ref, Song song) async {
    // Only trigger for YouTube tracks (ID starts with "youtube:")
    if (!song.id.startsWith('youtube:')) {
      return;
    }

    // Extract video ID
    final videoId = song.id.replaceFirst('youtube:', '');

    // Check if we already requested this track
    final db = ref.read(databaseProvider);
    final existingRequest = await db.getLidarrRequestForVideo(videoId);
    if (existingRequest != null) {
      log.info(
          'Lidarr: Already requested download for video $videoId (status: ${existingRequest.status})');
      return;
    }

    // Get the Lidarr service and request download
    final lidarrService = ref.read(lidarrServiceProvider.notifier);

    // Fire and forget - don't block the UI
    lidarrService
        .requestDownload(
      youtubeTitle: song.title,
      youtubeArtist: song.artist ?? 'Unknown Artist',
      videoId: videoId,
    )
        .then((result) {
      // Show feedback to user based on result
      result.when(
        success: (artistName, foreignArtistId, message) {
          _showSnackbar(ref, 'Added $artistName to Lidarr for download');
        },
        alreadyExists: (artistName, message) {
          _showSnackbar(ref, '$artistName is already in your library');
        },
        notFound: (message) {
          log.warning('Lidarr: $message');
          // Don't show error snackbar for not found - it's not critical
        },
        error: (message, error) {
          log.severe('Lidarr: Error requesting download - $message');
          // Don't show error snackbar - we don't want to interrupt the user experience
        },
      );
    }).catchError((e, stackTrace) {
      log.severe('Lidarr: Unexpected error triggering download', e, stackTrace);
    });
  }

  /// Show a snackbar message to the user
  void _showSnackbar(WidgetRef ref, String message) {
    // Try to find a ScaffoldMessenger in the context
    try {
      final context = ref.context;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // If we can't show a snackbar, just log it
      log.info('Lidarr: $message');
    }
  }

  /// Show feedback when auto-download is triggered by thumbs up
  Future<void> _showAutoDownloadFeedback(
      BuildContext context, WidgetRef ref, Song song) async {
    try {
      final settings = ref.read(settingsServiceProvider);

      // Only show feedback if auto-download is enabled
      if (!settings.app.thumbsUpAutoDownload) {
        return;
      }

      // Only show feedback if song isn't already downloaded
      if (song.downloadFilePath != null || song.downloadTaskId != null) {
        return;
      }

      // Check network mode to determine message
      final networkMode = await ref.read(networkModeProvider.future);
      final downloadPref = settings.app.downloadPreference;

      String message;
      if (downloadPref == 'manual_only') {
        // Auto-download is enabled but download preference is manual - shouldn't happen but handle it
        return;
      } else if (downloadPref == 'wifi_only' &&
          networkMode == NetworkMode.mobile) {
        message = 'Download queued for WiFi';
      } else {
        message = 'Downloading...';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      log.warning('Error showing auto-download feedback', e);
    }
  }

  /// Show feedback when auto-delete is triggered by thumbs down
  Future<void> _showAutoDeleteFeedback(
      BuildContext context, WidgetRef ref, Song song) async {
    try {
      final settings = ref.read(settingsServiceProvider);

      // Only show feedback if auto-delete is enabled
      if (!settings.app.thumbsDownAutoDelete) {
        return;
      }

      // Only show feedback if song was actually downloaded
      if (song.downloadFilePath == null) {
        return;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('File deleted'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      log.warning('Error showing auto-delete feedback', e);
    }
  }
}

class _ThumbsUpButton extends StatelessWidget {
  final Song song;
  final double size;
  final bool isActive;
  final VoidCallback onTap;

  const _ThumbsUpButton({
    required this.song,
    required this.size,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      iconSize: size,
      onPressed: onTap,
      icon: Icon(
        Icons.thumb_up,
        color: isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withOpacity(0.6),
      ),
      tooltip: isActive ? 'Remove like' : 'Like this song',
    );
  }
}

class _ThumbsDownButton extends StatelessWidget {
  final Song song;
  final double size;
  final bool isActive;
  final VoidCallback onTap;

  const _ThumbsDownButton({
    required this.song,
    required this.size,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      iconSize: size,
      onPressed: onTap,
      icon: Icon(
        Icons.thumb_down,
        color: isActive
            ? theme.colorScheme.error
            : theme.colorScheme.onSurface.withOpacity(0.6),
      ),
      tooltip: isActive ? 'Remove dislike' : 'Dislike this song',
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final Song song;
  final double size;
  final UserRating rating;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.song,
    required this.size,
    required this.rating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    IconData icon;
    Color? color;
    String tooltip;

    switch (rating) {
      case UserRating.unrated:
        icon = Icons.thumb_up_outlined;
        color = theme.colorScheme.onSurface.withOpacity(0.4);
        tooltip = 'Rate this song';
        break;
      case UserRating.thumbsUp:
        icon = Icons.thumb_up;
        color = theme.colorScheme.primary;
        tooltip = 'Liked - tap to dislike';
        break;
      case UserRating.thumbsDown:
        icon = Icons.thumb_down;
        color = theme.colorScheme.error;
        tooltip = 'Disliked - tap to clear rating';
        break;
    }

    return IconButton(
      iconSize: size,
      onPressed: onTap,
      icon: Icon(icon, color: color),
      tooltip: tooltip,
    );
  }
}

/// Compact rating indicator (read-only)
class SongRatingIndicator extends StatelessWidget {
  final Song song;
  final double size;

  const SongRatingIndicator({
    super.key,
    required this.song,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (song.userRating == UserRating.unrated) {
      return const SizedBox.shrink();
    }

    IconData icon;
    Color color;

    switch (song.userRating) {
      case UserRating.thumbsUp:
        icon = Icons.thumb_up;
        color = theme.colorScheme.primary;
        break;
      case UserRating.thumbsDown:
        icon = Icons.thumb_down;
        color = theme.colorScheme.error;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Icon(
      icon,
      size: size,
      color: color,
    );
  }
}
