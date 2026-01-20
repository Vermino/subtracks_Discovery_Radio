import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:text_scroll/text_scroll.dart';

import '../../cache/image_cache.dart';
import '../../database/database.dart';
import '../../models/music.dart';
import '../../models/support.dart';
import '../../services/audio_service.dart';
import '../../state/audio.dart';
import '../../state/music.dart';
import '../../state/settings.dart';
import '../../state/theme.dart';
import '../app_router.dart';
import '../images.dart';
import '../widgets/rating_buttons.dart';
import '../widgets/youtube_badge.dart';
import '../context_menus.dart';
import '../gradient.dart';
import '../now_playing_bar.dart';

class NowPlayingPage extends HookConsumerWidget {
  const NowPlayingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(mediaItemThemeProvider).valueOrNull;
    final base = ref.watch(baseThemeProvider);
    final itemData = ref.watch(mediaItemDataProvider);
    final audioControl = ref.watch(audioControlProvider);

    final theme = Theme.of(context);

    final scaffold = AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        systemNavigationBarColor: colors?.gradientLow ?? base.gradientLow,
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: itemData?.contextType == QueueContextType.discovery
              ? _DiscoveryStationTitle(audioControl: audioControl)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getContextDisplayName(itemData?.contextType),
                      style: theme.textTheme.labelMedium,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                    ),
                  ],
                ),
          actions: [
            if (itemData?.contextType == QueueContextType.discovery) ...[
              const _SaveStationButton(),
              const _DiscoveryInfoButton(),
            ],
          ],
        ),
        body: const Stack(
          children: [
            MediaItemGradient(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: _Art(),
                    ),
                  ),
                  SizedBox(height: 24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: _TrackInfo(),
                  ),
                  SizedBox(height: 8),
                  _Progress(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: _Controls(),
                  ),
                  SizedBox(height: 64),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Only wrap with dynamic theme if colors are available
    // The mediaItemThemeProvider already checks enableDynamicColors setting
    if (colors != null && colors != base) {
      return Theme(data: colors.theme, child: scaffold);
    } else {
      return scaffold;
    }
  }

  String _getContextDisplayName(QueueContextType? contextType) {
    if (contextType == null) return '';

    switch (contextType) {
      case QueueContextType.discovery:
        return 'Discovery Radio';
      case QueueContextType.song:
        return 'Song';
      case QueueContextType.album:
        return 'Album';
      case QueueContextType.playlist:
        return 'Playlist';
      case QueueContextType.library:
        return 'Library';
      case QueueContextType.genre:
        return 'Genre';
      case QueueContextType.artist:
        return 'Artist';
      default:
        return contextType.value;
    }
  }
}

class _Art extends HookConsumerWidget {
  const _Art();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemData = ref.watch(mediaItemDataProvider);
    final imageCache = ref.watch(imageCacheProvider);

    UriCacheInfo? cacheInfo;
    if (itemData?.artCache != null) {
      cacheInfo = UriCacheInfo(
        uri: itemData!.artCache!.fullArtUri,
        cacheKey: itemData.artCache!.fullArtCacheKey,
        cacheManager: imageCache,
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: CardClip(
        key: ValueKey(cacheInfo?.cacheKey ?? 'default'),
        child: cacheInfo != null
            ? CardClip(
                square: false,
                child: UriCacheInfoImage(
                  // height: 300,
                  fit: BoxFit.contain,
                  placeholderStyle: PlaceholderStyle.spinner,
                  cache: cacheInfo,
                ),
              )
            : const PlaceholderImage(thumbnail: false),
      ),
    );
  }
}

class _TrackInfo extends HookConsumerWidget {
  const _TrackInfo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(mediaItemProvider).valueOrNull;
    final itemData = ref.watch(mediaItemDataProvider);
    final audioControl = ref.watch(audioControlProvider);
    final theme = Theme.of(context);

    // Check if this is a YouTube track
    final isYouTube = item?.extras?['isYouTube'] == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScrollableText(
                    item?.title ?? '',
                    style: theme.textTheme.headlineSmall,
                    speed: 50,
                  ),
                  // Artist name with YouTube badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item?.artist ?? '',
                          style: theme.textTheme.titleMedium!,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      if (isYouTube) ...[
                        const SizedBox(width: 8),
                        const YouTubeBadge(
                          isYouTube: true,
                          size: YouTubeBadgeSize.normal,
                        ),
                      ],
                    ],
                  ),
                  // Source label for YouTube tracks
                  if (isYouTube)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Streaming from YouTube',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.red.shade700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Rating buttons for the currently playing song
            if (item?.id != null)
              _RatingButtonsForCurrentTrack(
                mediaItem: item!,
                itemData: itemData,
                audioControl: audioControl,
              )
            else
              const SizedBox(width: 80, height: 32),
          ],
        ),
        // Global rating counter badges
        if (item?.id != null)
          ref.watch(songProvider(item!.id)).when(
            data: (song) => _RatingCounterBadges(song: song),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }
}

class ScrollableText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double speed;

  const ScrollableText(
    this.text, {
    super.key,
    this.style,
    this.speed = 35,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context);

    return AutoSizeText(
      text,
      presetFontSizes: style != null && style?.fontSize != null
          ? [style!.fontSize!]
          : [defaultStyle.style.fontSize ?? 12],
      style: style,
      maxLines: 1,
      // softWrap: false,
      overflowReplacement: TextScroll(
        '$text     ',
        style: style,
        delayBefore: const Duration(seconds: 3),
        pauseBetween: const Duration(seconds: 4),
        mode: TextScrollMode.endless,
        velocity: Velocity(pixelsPerSecond: Offset(speed, 0)),
      ),
    );
  }
}

class _Progress extends HookConsumerWidget {
  const _Progress();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(mediaItemThemeProvider).valueOrNull;
    final base = ref.watch(baseThemeProvider);
    final position = ref.watch(positionProvider);
    final duration = ref.watch(durationProvider);
    final audio = ref.watch(audioControlProvider);

    final changeValue = useState(position.toDouble());
    final changing = useState(false);

    // Use onSurface for better visibility on dark backgrounds
    final sliderColor = colors?.theme.colorScheme.onSurface ?? base.theme.colorScheme.onSurface;

    return Column(
      children: [
        Slider(
          value: changing.value ? changeValue.value : position.toDouble(),
          min: 0,
          max: max(duration.toDouble(), position.toDouble()),
          thumbColor: sliderColor,
          activeColor: sliderColor,
          inactiveColor: sliderColor,
          onChanged: (value) {
            changeValue.value = value;
          },
          onChangeStart: (value) {
            changing.value = true;
          },
          onChangeEnd: (value) {
            changing.value = false;
            audio.seek(Duration(seconds: value.toInt()));
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.titleMedium!,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(Duration(
                        seconds: changing.value
                            ? changeValue.value.toInt()
                            : position)
                    .toString()
                    .substring(2, 7)),
                Text(Duration(seconds: duration).toString().substring(2, 7)),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class RepeatButton extends HookConsumerWidget {
  final double size;

  const RepeatButton({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.watch(audioControlProvider);
    final repeat = ref.watch(repeatModeProvider);

    IconData icon;
    void Function() action;

    switch (repeat) {
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
        icon = Icons.repeat_on_rounded;
        action = () => audio.setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case AudioServiceRepeatMode.one:
        icon = Icons.repeat_one_on_rounded;
        action = () => audio.setRepeatMode(AudioServiceRepeatMode.none);
        break;
      default:
        icon = Icons.repeat_rounded;
        action = () => audio.setRepeatMode(AudioServiceRepeatMode.all);
        break;
    }

    return IconButton(
      icon: Icon(icon),
      padding: EdgeInsets.zero,
      iconSize: 30,
      onPressed: action,
    );
  }
}

class ShuffleButton extends HookConsumerWidget {
  final double size;

  const ShuffleButton({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.watch(audioControlProvider);
    final shuffle = ref.watch(shuffleModeProvider);
    final queueMode = ref.watch(queueModeProvider).valueOrNull;

    IconData icon;
    void Function() action;

    switch (shuffle) {
      case AudioServiceShuffleMode.all:
      case AudioServiceShuffleMode.group:
        icon = Icons.shuffle_on_rounded;
        action = () => audio.setShuffleMode(AudioServiceShuffleMode.none);
        break;
      default:
        icon = Icons.shuffle_rounded;
        action = () => audio.setShuffleMode(AudioServiceShuffleMode.all);
        break;
    }

    return IconButton(
      icon: Icon(queueMode == QueueMode.radio ? Icons.radio_rounded : icon),
      padding: EdgeInsets.zero,
      iconSize: 30,
      onPressed: queueMode == QueueMode.radio ? null : action,
    );
  }
}

class _Controls extends HookConsumerWidget {
  const _Controls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(mediaItemThemeProvider).valueOrNull;
    final base = ref.watch(baseThemeProvider);
    final audio = ref.watch(audioControlProvider);

    // Use a bright color that contrasts well with dark backgrounds
    final iconColor = colors?.theme.colorScheme.onSurface ??
                     base.theme.colorScheme.onSurface;

    return IconTheme(
      data: IconThemeData(color: iconColor),
      child: Column(
        children: [
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const RepeatButton(size: 30),
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded),
                  padding: EdgeInsets.zero,
                  iconSize: 60,
                  onPressed: () => audio.skipToPrevious(),
                ),
                const PlayPauseButton(size: 90),
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded),
                  padding: EdgeInsets.zero,
                  iconSize: 60,
                  onPressed: () => audio.skipToNext(),
                ),
                const ShuffleButton(size: 30),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: Row(
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.queue_music_rounded),
                  padding: EdgeInsets.zero,
                  iconSize: 30,
                  onPressed: () => context.navigateTo(const QueueRoute()),
                ),
                const _MoreButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreButton extends HookConsumerWidget {
  const _MoreButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final song = ref.watch(mediaItemSongProvider).valueOrNull;

    return IconButton(
      icon: const Icon(Icons.more_horiz),
      padding: EdgeInsets.zero,
      iconSize: 30,
      onPressed: song != null
          ? () {
              showContextMenu(
                context: context,
                ref: ref,
                builder: (context) => BottomSheetMenu(
                  child: SongContextMenu(song: song),
                ),
              );
            }
          : null,
    );
  }
}

class _SaveStationButton extends HookConsumerWidget {
  const _SaveStationButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.bookmark_outline),
      onPressed: () => _showSaveStationDialog(context, ref),
    );
  }

  void _showSaveStationDialog(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Discovery Station'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Give this station a name to save it for later playback:'),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Station Name',
                hintText: 'e.g., Rock Mix, Chill Vibes',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final stationName = textController.text.trim();
              if (stationName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a station name')),
                );
                return;
              }

              Navigator.of(context).pop();
              await _saveStation(context, ref, stationName);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveStation(BuildContext context, WidgetRef ref, String stationName) async {
    try {
      final audioControl = ref.read(audioControlProvider);
      await audioControl.saveCurrentDiscoveryStation(stationName);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Station "$stationName" saved successfully!'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              context.navigateTo(const BrowseRouter(children: [BrowseRoute()]));
            },
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving station: $e')),
      );
    }
  }
}

class _DiscoveryInfoButton extends HookConsumerWidget {
  const _DiscoveryInfoButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.info_outline),
      onPressed: () {
        final itemData = ref.read(mediaItemDataProvider);
        final seedId = itemData?.contextId;

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.explore),
                SizedBox(width: 8),
                Text('Discovery Radio'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Intelligent recommendations based on your seed selection',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                if (seedId != null) ...[
                  const Text(
                    'Seed Song:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ref.watch(songProvider(seedId)).when(
                    data: (song) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(song.title),
                        Text(
                          song.artist ?? 'Unknown Artist',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    loading: () => const Text('Loading...'),
                    error: (_, __) => const Text('Could not load seed song'),
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'How it works:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('• Artist similarity'),
                      Text('• Genre matching'),
                      Text('• User preference learning'),
                      Text('• Metadata correlation'),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DiscoveryStationTitle extends HookConsumerWidget {
  final AudioControl audioControl;

  const _DiscoveryStationTitle({required this.audioControl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return FutureBuilder<DiscoverySession?>(
      future: audioControl.getCurrentDiscoveryStation(),
      builder: (context, snapshot) {
        final station = snapshot.data;
        final stationName = station?.stationName ??
            (station?.seedArtist != null && station!.seedArtist!.isNotEmpty
                ? '${station.seedArtist} Radio'
                : station?.seedGenre != null && station!.seedGenre!.isNotEmpty
                    ? '${station.seedGenre} Radio'
                    : 'Discovery Radio');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.explore, size: 20),
                ),
                Flexible(
                  child: Text(
                    'Discovery Radio',
                    style: theme.textTheme.labelMedium,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
            if (station != null)
              Text(
                stationName,
                style: theme.textTheme.titleSmall,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        );
      },
    );
  }
}

/// Widget that handles rating buttons for both local and YouTube tracks
class _RatingButtonsForCurrentTrack extends HookConsumerWidget {
  final MediaItem mediaItem;
  final MediaItemData? itemData;
  final AudioControl audioControl;

  const _RatingButtonsForCurrentTrack({
    required this.mediaItem,
    required this.itemData,
    required this.audioControl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isYouTube = mediaItem.extras?['isYouTube'] == true;

    if (isYouTube) {
      // YouTube track - create a synthetic Song object from MediaItem
      final youtubeSong = Song(
        sourceId: ref.watch(sourceIdProvider),
        id: mediaItem.id,
        title: mediaItem.title,
        artist: mediaItem.artist,
        album: mediaItem.album,
        duration: mediaItem.duration,
        userRating: UserRating.unrated, // YouTube tracks don't have persisted ratings
      );

      // Use station-specific ratings if playing discovery station
      final stationId = itemData?.contextType == QueueContextType.discovery
          ? audioControl.currentDiscoverySessionId
          : null;

      return SongRatingButtons(
        song: youtubeSong,
        size: 32,
        showBoth: true, // Show both thumbs up and thumbs down
        stationId: stationId, // Pass station ID for station-specific ratings
      );
    } else {
      // Local track - use the song provider
      return ref.watch(songProvider(mediaItem.id)).when(
        data: (song) {
          // Use station-specific ratings if playing discovery station
          final stationId = itemData?.contextType == QueueContextType.discovery
              ? audioControl.currentDiscoverySessionId
              : null;

          return SongRatingButtons(
            song: song,
            size: 32,
            showBoth: true, // Show both thumbs up and thumbs down
            stationId: stationId, // Pass station ID for station-specific ratings
          );
        },
        loading: () => const SizedBox(width: 80, height: 32),
        error: (_, __) => const SizedBox(width: 80, height: 32),
      );
    }
  }
}

class _RatingCounterBadges extends StatelessWidget {
  final Song song;

  const _RatingCounterBadges({required this.song});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasThumbsUp = song.thumbsUpCount > 0;
    final hasThumbsDown = song.thumbsDownCount > 0;

    // Don't show badges if both counts are 0
    if (!hasThumbsUp && !hasThumbsDown) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 88), // Offset to align under track info
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasThumbsUp)
            _CounterBadge(
              icon: Icons.thumb_up,
              count: song.thumbsUpCount,
              color: theme.colorScheme.primary,
            ),
          if (hasThumbsUp && hasThumbsDown)
            const SizedBox(width: 12),
          if (hasThumbsDown)
            _CounterBadge(
              icon: Icons.thumb_down,
              count: song.thumbsDownCount,
              color: theme.colorScheme.error,
            ),
        ],
      ),
    );
  }
}

class _CounterBadge extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;

  const _CounterBadge({
    required this.icon,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
