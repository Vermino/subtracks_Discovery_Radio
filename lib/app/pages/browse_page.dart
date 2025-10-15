import 'package:auto_route/auto_route.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:subtracks/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../database/database.dart';
import '../../log.dart';
import '../../models/music.dart';
import '../../models/query.dart';
import '../../models/support.dart';
import '../../services/audio_service.dart';
import '../../services/cache_service.dart';
import '../../services/discovery_service.dart';
import '../../state/music.dart';
import '../../state/settings.dart';
import '../app_router.dart';
import '../buttons.dart';
import '../images.dart';
import '../items.dart';
import 'songs_page.dart';

part 'browse_page.g.dart';

@riverpod
Stream<List<Album>> albumsCategoryList(
  AlbumsCategoryListRef ref,
  ListQuery opt,
) {
  final db = ref.watch(databaseProvider);
  final sourceId = ref.watch(sourceIdProvider);

  return db.albumsList(sourceId, opt).watch();
}

@riverpod
class SavedStations extends _$SavedStations {
  @override
  Future<List<DiscoverySession>> build() async {
    final db = ref.watch(databaseProvider);
    final sourceId = ref.watch(sourceIdProvider);

    return db.getStationsSortedByRecent(sourceId, limit: 20);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(databaseProvider);
      final sourceId = ref.read(sourceIdProvider);
      return db.getStationsSortedByRecent(sourceId, limit: 20);
    });
  }

  Future<void> deleteStation(int sessionId) async {
    try {
      log.info('SavedStationsProvider: Deleting station with sessionId: $sessionId');
      final db = ref.read(databaseProvider);

      await db.deleteDiscoveryStation(sessionId);
      log.info('SavedStationsProvider: Station deleted from database successfully');

      await refresh();
      log.info('SavedStationsProvider: Station list refreshed successfully');
    } catch (e, stackTrace) {
      log.severe('SavedStationsProvider: Failed to delete station $sessionId', e, stackTrace);
      rethrow; // Rethrow to allow UI to show error
    }
  }

  Future<void> toggleFavorite(int sessionId, bool isFavorite) async {
    final db = ref.read(databaseProvider);
    await db.toggleStationFavorite(sessionId, isFavorite);
    await refresh();
  }

  Future<void> renameStation(int sessionId, String newName) async {
    final db = ref.read(databaseProvider);
    await db.updateStationName(sessionId, newName);
    await refresh();
  }
}

@riverpod
Future<List<Album>> albumsForStation(
  AlbumsForStationRef ref,
  int stationId,
) async {
  final db = ref.watch(databaseProvider);
  final sourceId = ref.watch(sourceIdProvider);

  // Get the station
  final stations = await db.getStationsSortedByRecent(sourceId, limit: 100);
  final station = stations.cast<DiscoverySession?>().firstWhere(
    (s) => s?.id == stationId,
    orElse: () => null,
  );

  if (station == null) {
    return [];
  }

  // Get the seed song to find its album and artist
  final songs = await db.songsInIds(sourceId, [station.seedSongId]).get();
  if (songs.isEmpty) {
    return [];
  }

  final seedSong = songs.first;
  final albums = <Album>[];

  // Try to get albums from the seed song's artist
  if (seedSong.artistId != null && seedSong.artistId!.isNotEmpty) {
    final artistAlbums = await db
        .albumsByArtistId(sourceId, seedSong.artistId)
        .get();
    albums.addAll(artistAlbums.take(4));
  }

  // If we don't have enough albums, try getting albums from the seed genre
  if (albums.length < 4 && station.seedGenre != null && station.seedGenre!.isNotEmpty) {
    final genreAlbums = await db
        .albumsByGenre(sourceId, station.seedGenre, 4 - albums.length, 0)
        .get();
    albums.addAll(genreAlbums);
  }

  // If we still don't have enough, add the seed song's album
  if (albums.length < 4 && seedSong.albumId != null && seedSong.albumId!.isNotEmpty) {
    final seedAlbum = await db.albumById(sourceId, seedSong.albumId!).getSingleOrNull();
    if (seedAlbum != null && !albums.any((a) => a.id == seedAlbum.id)) {
      albums.add(seedAlbum);
    }
  }

  return albums.take(4).toList();
}

class BrowsePage extends HookConsumerWidget {
  const BrowsePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final stationsAsync = ref.watch(savedStationsProvider);
    final hasStations = stationsAsync.valueOrNull?.isNotEmpty ?? false;

    final frequent = ref
        .watch(albumsCategoryListProvider(const ListQuery(
          page: Pagination(limit: 20),
          sort: SortBy(column: 'frequent_rank'),
          filters: IListConst([
            FilterWith.isNull(column: 'frequent_rank', invert: true),
          ]),
        )))
        .valueOrNull;
    final recent = ref
        .watch(albumsCategoryListProvider(const ListQuery(
          page: Pagination(limit: 20),
          sort: SortBy(column: 'recent_rank'),
          filters: IListConst([
            FilterWith.isNull(column: 'recent_rank', invert: true),
          ]),
        )))
        .valueOrNull;
    final starred = ref
        .watch(albumsCategoryListProvider(const ListQuery(
          page: Pagination(limit: 20),
          sort: SortBy(column: 'starred'),
          filters: IListConst([
            FilterWith.isNull(column: 'starred', invert: true),
          ]),
        )))
        .valueOrNull;
    final random = ref
        .watch(albumsCategoryListProvider(const ListQuery(
          page: Pagination(limit: 20),
          sort: SortBy(column: 'RANDOM()'),
        )))
        .valueOrNull;

    final genres = ref
        .watch(albumGenresProvider(const Pagination(
          limit: 20,
        )))
        .valueOrNull;

    final songs = ref.watch(songsListProvider(const ListQuery())).valueOrNull;

    void onPlayRadioPressed() {
      ref.read(audioControlProvider).playRadio(
            context: QueueContextType.library,
            getSongs: (query) => ref
                .read(databaseProvider)
                .songsList(ref.read(sourceIdProvider), query)
                .get(),
          );
    }

    return Scaffold(
      floatingActionButton: RadioPlayFab(
        onPressed:
            songs != null && songs.isNotEmpty ? onPlayRadioPressed : null,
      ),
      body: CustomScrollView(
        slivers: [
          const SliverSafeArea(
            sliver: SliverPadding(padding: EdgeInsets.only(top: 8)),
          ),
          // Only show the "Create First Station" card if no stations exist
          if (!hasStations) const _DiscoveryRadioSection(),
          const _MyStationsSection(),
          _GenreCategory(
            title: 'Genres',
            items: genres?.toList() ?? [],
          ),
          _AlbumCategory(
            title: l.resourcesSortByFrequentlyPlayed,
            items: frequent ?? [],
          ),
          _AlbumCategory(
            title: l.resourcesSortByRecentlyPlayed,
            items: recent ?? [],
          ),
          _AlbumCategory(
            title: l.resourcesFilterStarred,
            items: starred ?? [],
          ),
          _AlbumCategory(
            title: l.resourcesSortByRandom,
            items: random ?? [],
          ),
        ],
      ),
    );
  }
}

class _GenreCategory extends HookConsumerWidget {
  final String title;
  final List<String> items;

  const _GenreCategory({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 16),
      sliver: _Category(
        title: title,
        height: 140,
        itemWidth: 140,
        items: items.map((genre) => _GenreItem(genre: genre)).toList(),
      ),
    );
  }
}

class _GenreItem extends HookConsumerWidget {
  final String genre;

  const _GenreItem({
    required this.genre,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albums = ref
        .watch(albumsByGenreProvider(
          genre,
          const Pagination(limit: 4),
        ))
        .valueOrNull;
    final cache = ref.watch(cacheServiceProvider);

    final theme = Theme.of(context);

    if (albums == null) {
      return Container();
    }

    return ImageCard(
      onTap: () {
        context.navigateTo(GenreSongsRoute(genre: genre));
      },
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          CardClip(
            child: MultiImage(
              cacheInfo: albums.map((album) => cache.albumArt(album)),
            ),
          ),
          Material(
            type: MaterialType.canvas,
            color: theme.colorScheme.secondaryContainer,
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  genre,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlbumCategory extends HookConsumerWidget {
  final String title;
  final List<Album> items;

  const _AlbumCategory({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _Category(
      title: title,
      height: 190,
      itemWidth: 140,
      items: items
          .map(
            (album) => AlbumCard(
              album: album,
              onTap: () => context.navigateTo(
                AlbumSongsRoute(
                  id: album.id,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _Category extends HookConsumerWidget {
  final String title;
  final List<Widget> items;
  final double height;
  final double itemWidth;

  const _Category({
    required this.title,
    required this.items,
    required this.height,
    required this.itemWidth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MultiSliver(
      children: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: height,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) => SizedBox(
                width: itemWidth,
                child: items[index],
              ),
              separatorBuilder: (context, index) => const SizedBox(width: 8),
            ),
          ),
        ),
      ],
    );
  }
}

class _DiscoveryRadioSection extends HookConsumerWidget {
  const _DiscoveryRadioSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 16),
      sliver: MultiSliver(
        children: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  const Icon(Icons.explore, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'Discovery Radio',
                    style: theme.textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 2,
                child: InkWell(
                  onTap: () => context.navigateTo(const StationBuilderRoute()),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.radio_rounded,
                            size: 48,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Create Your First Discovery Station',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Build a radio station from your favorite songs, artists, or genres',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => context.navigateTo(const StationBuilderRoute()),
                          icon: const Icon(Icons.add),
                          label: const Text('Create Station'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _MyStationsSection extends HookConsumerWidget {
  const _MyStationsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationsAsync = ref.watch(savedStationsProvider);

    return stationsAsync.when(
      data: (stations) {
        if (stations.isEmpty) {
          final theme = Theme.of(context);
          return SliverPadding(
            padding: const EdgeInsets.only(bottom: 16),
            sliver: MultiSliver(
              children: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Text(
                      'My Stations',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.history,
                              size: 48,
                              color: theme.colorScheme.onSurface.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No stations yet',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your discovery stations will appear here after you create them',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Show stations with a "Create New" card as the first item
        return SliverPadding(
          padding: const EdgeInsets.only(bottom: 16),
          sliver: _Category(
            title: 'My Stations',
            height: 220,
            itemWidth: 160,
            items: [
              const _CreateStationCard(),
              ...stations.map((station) => _StationCard(station: station)),
            ],
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error loading stations: $error'),
        ),
      ),
    );
  }
}

class _CreateStationCard extends HookConsumerWidget {
  const _CreateStationCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.all(0),
      child: InkWell(
        onTap: () => context.navigateTo(const StationBuilderRoute()),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  size: 32,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Create\nNew Station',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StationCard extends HookConsumerWidget {
  final DiscoverySession station;

  const _StationCard({required this.station});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final albums = ref.watch(albumsForStationProvider(station.id)).valueOrNull;
    final cache = ref.watch(cacheServiceProvider);

    // Format the last played date
    final lastPlayed = station.lastPlayedAt != null
        ? DateTime.fromMillisecondsSinceEpoch(station.lastPlayedAt! * 1000)
        : null;
    final lastPlayedStr = lastPlayed != null
        ? _formatRelativeTime(lastPlayed)
        : 'Not played yet';

    // Get station name or generate one from seeds
    final stationName = station.stationName ??
        _generateStationName(station.seedArtist, station.seedGenre);

    return ImageCard(
      onTap: () => _playStation(context, ref, station),
      onLongPress: () => _showStationOptions(context, ref, station),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album covers with station name overlay
          Expanded(
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                // Show album covers if available, otherwise show icon
                if (albums != null && albums.isNotEmpty)
                  CardClip(
                    child: MultiImage(
                      cacheInfo: albums.map((album) => cache.albumArt(album)),
                    ),
                  )
                else
                  CardClip(
                    child: Container(
                      color: theme.colorScheme.primaryContainer,
                      child: Center(
                        child: Icon(
                          station.mode == 'online'
                              ? Icons.radio_rounded
                              : Icons.download_rounded,
                          size: 48,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                // Station name overlay
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: Material(
                    type: MaterialType.canvas,
                    color: theme.colorScheme.secondaryContainer,
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              stationName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (station.isFavorite == 1)
                            Icon(
                              Icons.star,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom info section
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Seed info
                Text(
                  _getSeedInfo(station),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                // Stats
                Row(
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      size: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${station.playCount}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lastPlayedStr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _generateStationName(String? artist, String? genre) {
    if (artist != null && artist.isNotEmpty) {
      return '$artist Radio';
    } else if (genre != null && genre.isNotEmpty) {
      return '$genre Radio';
    }
    return 'Discovery Radio';
  }

  String _getSeedInfo(DiscoverySession station) {
    final parts = <String>[];
    if (station.seedArtist != null && station.seedArtist!.isNotEmpty) {
      parts.add(station.seedArtist!);
    }
    if (station.seedGenre != null && station.seedGenre!.isNotEmpty) {
      parts.add(station.seedGenre!);
    }
    if (parts.isEmpty) {
      return '${station.playlistSize} songs';
    }
    return parts.join(' • ');
  }

  String _formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _playStation(
    BuildContext context,
    WidgetRef ref,
    DiscoverySession station,
  ) async {
    final audioControl = ref.read(audioControlProvider);
    final db = ref.read(databaseProvider);
    final sourceId = ref.read(sourceIdProvider);

    try {
      // Get the seed song
      final songs = await db.songsInIds(sourceId, [station.seedSongId]).get();
      if (songs.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not find seed song')),
        );
        return;
      }

      final seedSong = songs.first;

      // Start discovery radio (playDiscoveryRadio will clear the queue automatically)
      await audioControl.playHybridDiscoveryRadio(
        seedSong: seedSong,
        mode: station.mode == 'online' ? DiscoveryMode.online : DiscoveryMode.offline,
        playlistSize: station.playlistSize,
        sessionId: station.id,
      );

      // Refresh the stations list
      ref.read(savedStationsProvider.notifier).refresh();

      if (!context.mounted) return;
      // Navigate to now playing page
      context.navigateTo(const NowPlayingRoute());
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing station: $e')),
      );
    }
  }

  void _showStationOptions(
    BuildContext context,
    WidgetRef ref,
    DiscoverySession station,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _StationOptionsSheet(station: station),
    );
  }
}

class _StationOptionsSheet extends HookConsumerWidget {
  final DiscoverySession station;

  const _StationOptionsSheet({required this.station});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stationName = station.stationName ??
        (station.seedArtist != null && station.seedArtist!.isNotEmpty
            ? '${station.seedArtist} Radio'
            : station.seedGenre != null && station.seedGenre!.isNotEmpty
                ? '${station.seedGenre} Radio'
                : 'Discovery Radio');

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    station.mode == 'online'
                        ? Icons.radio_rounded
                        : Icons.download_rounded,
                    size: 32,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stationName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${station.playlistSize} songs • ${station.mode}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Options
            ListTile(
              leading: const Icon(Icons.play_arrow_rounded),
              title: const Text('Play Station'),
              onTap: () {
                Navigator.pop(context);
                _playStation(context, ref, station);
              },
            ),
            ListTile(
              leading: Icon(
                station.isFavorite == 1 ? Icons.star : Icons.star_border,
              ),
              title: Text(station.isFavorite == 1 ? 'Remove from Favorites' : 'Add to Favorites'),
              onTap: () async {
                await ref.read(savedStationsProvider.notifier).toggleFavorite(
                      station.id,
                      station.isFavorite != 1,
                    );
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename Station'),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(context, ref, station);
              },
            ),
            ListTile(
              leading: const Icon(Icons.thumb_up),
              title: const Text('Manage Ratings'),
              onTap: () {
                Navigator.pop(context);
                _showRatingsManagement(context, ref, station);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete,
                color: theme.colorScheme.error,
              ),
              title: Text(
                'Delete Station',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, ref, station);
              },
            ),
          ],
        ),
      ),
    ),
    );
  }

  Future<void> _playStation(
    BuildContext context,
    WidgetRef ref,
    DiscoverySession station,
  ) async {
    final audioControl = ref.read(audioControlProvider);
    final db = ref.read(databaseProvider);
    final sourceId = ref.read(sourceIdProvider);

    try {
      // Get the seed song
      final songs = await db.songsInIds(sourceId, [station.seedSongId]).get();
      if (songs.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not find seed song')),
        );
        return;
      }

      final seedSong = songs.first;

      // Start discovery radio (playDiscoveryRadio will clear the queue automatically)
      await audioControl.playHybridDiscoveryRadio(
        seedSong: seedSong,
        mode: station.mode == 'online' ? DiscoveryMode.online : DiscoveryMode.offline,
        playlistSize: station.playlistSize,
        sessionId: station.id,
      );

      // Refresh the stations list
      ref.read(savedStationsProvider.notifier).refresh();

      if (!context.mounted) return;
      // Navigate to now playing page
      context.navigateTo(const NowPlayingRoute());
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing station: $e')),
      );
    }
  }

  void _showRenameDialog(
    BuildContext context,
    WidgetRef ref,
    DiscoverySession station,
  ) {
    final controller = TextEditingController(
      text: station.stationName ??
          (station.seedArtist != null && station.seedArtist!.isNotEmpty
              ? '${station.seedArtist} Radio'
              : station.seedGenre != null && station.seedGenre!.isNotEmpty
                  ? '${station.seedGenre} Radio'
                  : 'Discovery Radio'),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Station'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Station Name',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await ref.read(savedStationsProvider.notifier).renameStation(
                      station.id,
                      newName,
                    );
              }
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    DiscoverySession station,
  ) {
    final stationName = station.stationName ??
        (station.seedArtist != null && station.seedArtist!.isNotEmpty
            ? '${station.seedArtist} Radio'
            : station.seedGenre != null && station.seedGenre!.isNotEmpty
                ? '${station.seedGenre} Radio'
                : 'Discovery Radio');

    // Capture the provider notifier before showing the dialog
    // This prevents "Cannot use ref after widget disposed" errors
    final stationsNotifier = ref.read(savedStationsProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Station?'),
        content: Text(
          'Are you sure you want to delete "$stationName"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                log.info('User confirmed deletion of station: $stationName (ID: ${station.id})');
                await stationsNotifier.deleteStation(station.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deleted "$stationName"')),
                  );
                }
              } catch (e, stackTrace) {
                log.severe('Error in delete confirmation dialog', e, stackTrace);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting station: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showRatingsManagement(
    BuildContext context,
    WidgetRef ref,
    DiscoverySession station,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _StationRatingsPage(station: station),
      ),
    );
  }
}

class _StationRatingsPage extends HookConsumerWidget {
  final DiscoverySession station;

  const _StationRatingsPage({required this.station});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationName = station.stationName ??
        (station.seedArtist != null && station.seedArtist!.isNotEmpty
            ? '${station.seedArtist} Radio'
            : station.seedGenre != null && station.seedGenre!.isNotEmpty
                ? '${station.seedGenre} Radio'
                : 'Discovery Radio');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Manage Ratings - $stationName'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.thumb_up), text: 'Liked Songs'),
              Tab(icon: Icon(Icons.thumb_down), text: 'Disliked Songs'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _RatedSongsList(
              station: station,
              interactionType: 'thumbs_up',
              emptyMessage: 'No liked songs yet',
            ),
            _RatedSongsList(
              station: station,
              interactionType: 'thumbs_down',
              emptyMessage: 'No disliked songs yet',
            ),
          ],
        ),
      ),
    );
  }
}

class _RatedSongsList extends HookConsumerWidget {
  final DiscoverySession station;
  final String interactionType;
  final String emptyMessage;

  const _RatedSongsList({
    required this.station,
    required this.interactionType,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(databaseProvider);
    final sourceId = ref.watch(sourceIdProvider);

    return FutureBuilder<Set<String>>(
      future: interactionType == 'thumbs_up'
          ? db.getThumbsUpSongsForStation(station.id)
          : db.getThumbsDownSongsForStation(station.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final songIds = snapshot.data!;

        if (songIds.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  interactionType == 'thumbs_up' ? Icons.thumb_up : Icons.thumb_down,
                  size: 64,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  emptyMessage,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        return FutureBuilder<List<Song>>(
          future: db.songsInIds(sourceId, songIds.toList()).get(),
          builder: (context, songsSnapshot) {
            if (!songsSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final songs = songsSnapshot.data!;

            return ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return ListTile(
                  leading: Icon(
                    interactionType == 'thumbs_up'
                        ? Icons.thumb_up
                        : Icons.thumb_down,
                    color: interactionType == 'thumbs_up'
                        ? Colors.green
                        : Colors.red,
                  ),
                  title: Text(song.title),
                  subtitle: Text(song.artist ?? 'Unknown Artist'),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    tooltip: 'Remove rating',
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Remove Rating?'),
                          content: Text(
                            'Remove ${interactionType == 'thumbs_up' ? 'like' : 'dislike'} from "${song.title}"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        // Remove the station-specific rating
                        await db.removeDiscoveryRating(
                          station.id,
                          song.id,
                          interactionType,
                        );

                        // Also decrement the global counter
                        // (This handles misclicks or rating corrections)
                        if (interactionType == 'thumbs_up') {
                          await db.decrementThumbsUpCount(song.sourceId, song.id);
                        } else {
                          await db.decrementThumbsDownCount(song.sourceId, song.id);
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Rating removed from "${song.title}"',
                              ),
                            ),
                          );
                          // Force rebuild to refresh the list
                          (context as Element).markNeedsBuild();
                        }
                      }
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
