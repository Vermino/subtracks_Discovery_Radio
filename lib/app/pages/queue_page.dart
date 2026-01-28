import 'package:audio_service/audio_service.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../database/database.dart';
import '../../models/music.dart';
import '../../models/support.dart';
import '../../services/audio_service.dart';
import '../../state/audio.dart';
import '../../state/music.dart';
import '../../state/settings.dart';

part 'queue_page.g.dart';

@riverpod
Stream<List<MediaItem>> fullQueue(FullQueueRef ref) async* {
  final db = ref.watch(databaseProvider);
  final sourceId = ref.watch(sourceIdProvider);

  await for (final queueItems in db.allQueueItems().watch()) {
    // Get all song IDs from the queue
    final songIds = queueItems.map((item) => item.id).toList();

    if (songIds.isEmpty) {
      yield [];
      continue;
    }

    // Separate local and YouTube track IDs
    final localIds = <String>[];
    final youtubeIds = <String>[];

    for (final id in songIds) {
      if (id.startsWith('youtube:')) {
        youtubeIds.add(id.replaceFirst('youtube:', ''));
      } else {
        localIds.add(id);
      }
    }

    // Fetch local songs from database
    final localSongs = localIds.isNotEmpty
        ? await db.songsInIds(sourceId, localIds).get()
        : <Song>[];

    // Fetch YouTube tracks from cache
    final youtubeTracks = <String, YoutubeTrack>{};
    for (final videoId in youtubeIds) {
      final track = await db.getYouTubeTrack(videoId);
      if (track != null) {
        youtubeTracks['youtube:$videoId'] = track;
      } else {
        // YouTube track not found in database - log for debugging
        print('Queue: YouTube track not found in DB: $videoId');
      }
    }

    // Create MediaItems in queue order
    final mediaItems = queueItems
        .map((queueItem) {
          final id = queueItem.id;

          // Check if it's a YouTube track
          if (id.startsWith('youtube:')) {
            final youtubeTrack = youtubeTracks[id];
            if (youtubeTrack == null) return null;

            return MediaItem(
              id: id,
              title: youtubeTrack.title,
              artist: youtubeTrack.artist ?? youtubeTrack.channelName,
              album: 'YouTube',
              duration: Duration(seconds: youtubeTrack.durationSeconds),
              extras: {
                'isYouTube': true,
              },
            );
          } else {
            // Local song
            Song? song;
            try {
              song = localSongs.firstWhere((s) => s.id == id);
            } catch (e) {
              // Song not found in database
              return null;
            }

            return MediaItem(
              id: song.id,
              title: song.title,
              artist: song.artist,
              album: song.album,
              duration: song.duration,
              extras: {
                'isYouTube': false,
              },
            );
          }
        })
        .whereNotNull()
        .toList();

    yield mediaItems;
  }
}

class QueuePage extends HookConsumerWidget {
  const QueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(fullQueueProvider).valueOrNull ?? [];
    final currentItem = ref.watch(mediaItemProvider).valueOrNull;
    final itemData = ref.watch(mediaItemDataProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Queue'),
            if (itemData?.contextType == QueueContextType.discovery)
              Row(
                children: [
                  const Icon(Icons.explore, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Discovery Radio',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
          ],
        ),
      ),
      body: queue.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.queue_music_rounded,
                    size: 64,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No songs in queue',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: queue.length,
              itemBuilder: (context, index) {
                final item = queue[index];
                final isCurrentlyPlaying = item.id == currentItem?.id;

                return _QueueListTile(
                  item: item,
                  isCurrentlyPlaying: isCurrentlyPlaying,
                  position: index + 1,
                  isDiscoveryRadio:
                      itemData?.contextType == QueueContextType.discovery,
                );
              },
            ),
    );
  }
}

class _QueueListTile extends HookConsumerWidget {
  final MediaItem item;
  final bool isCurrentlyPlaying;
  final int position;
  final bool isDiscoveryRadio;

  const _QueueListTile({
    required this.item,
    required this.isCurrentlyPlaying,
    required this.position,
    required this.isDiscoveryRadio,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isYouTube = item.extras?['isYouTube'] == true;

    return Container(
      decoration: isCurrentlyPlaying
          ? BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              border: Border(
                left: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 4,
                ),
              ),
            )
          : null,
      child: ListTile(
        leading: SizedBox(
          width: 72,
          child: Row(
            children: [
              // Track position number
              SizedBox(
                width: 24,
                child: Text(
                  position.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isCurrentlyPlaying
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.5),
                    fontWeight: isCurrentlyPlaying
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 8),
              // Playing indicator or YouTube badge
              SizedBox(
                width: 32,
                height: 24,
                child: isCurrentlyPlaying
                    ? Icon(
                        Icons.play_arrow_rounded,
                        color: theme.colorScheme.primary,
                        size: 24,
                      )
                    : isYouTube
                        ? Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'YT',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.red.shade700,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : null,
              ),
            ],
          ),
        ),
        title: Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: isCurrentlyPlaying
              ? TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                )
              : null,
        ),
        subtitle: Row(
          children: [
            if (isDiscoveryRadio) ...[
              Icon(
                Icons.explore,
                size: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                item.artist ?? 'Unknown Artist',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: item.duration != null
            ? Text(
                _formatDuration(item.duration!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              )
            : null,
        onTap: () async {
          // Jump to this song in the queue
          final audio = ref.read(audioControlProvider);
          await audio.skipToQueueItem(position - 1);
          if (context.mounted) {
            Navigator.of(context).pop(); // Return to now playing
          }
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}
