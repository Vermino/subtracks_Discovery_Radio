import 'package:auto_route/auto_route.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../database/database.dart';
import '../../models/music.dart';
import '../../models/query.dart';
import '../../models/support.dart';
import '../../services/audio_service.dart';
import '../../services/discovery_service.dart';
import '../../state/music.dart';
import '../../state/settings.dart';
import '../app_router.dart';
import 'browse_page.dart';

enum SeedType { song, artist, album, genre }

class SeedItem {
  final SeedType type;
  final String id;
  final String name;
  final String? subtitle;

  const SeedItem({
    required this.type,
    required this.id,
    required this.name,
    this.subtitle,
  });

  IconData get icon {
    switch (type) {
      case SeedType.song:
        return Icons.music_note_rounded;
      case SeedType.artist:
        return Icons.person_rounded;
      case SeedType.album:
        return Icons.album_rounded;
      case SeedType.genre:
        return Icons.category_rounded;
    }
  }

  String get typeLabel {
    switch (type) {
      case SeedType.song:
        return 'Song';
      case SeedType.artist:
        return 'Artist';
      case SeedType.album:
        return 'Album';
      case SeedType.genre:
        return 'Genre';
    }
  }
}

class StationBuilderPage extends HookConsumerWidget {
  const StationBuilderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final seeds = useState<List<SeedItem>>([]);
    final playlistSize = useState<int>(50);
    final isOnlineMode = useState<bool>(true);
    final searchController = useTextEditingController();
    final searchQuery = useState<String>('');
    final isSearching = useState<bool>(false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Discovery Station'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelp(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search songs, artists, albums, or genres...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          searchQuery.value = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                searchQuery.value = value;
                isSearching.value = value.isNotEmpty;
              },
            ),
          ),

          // Search Results or Seed List
          Expanded(
            child: isSearching.value && searchQuery.value.isNotEmpty
                ? _SearchResults(
                    query: searchQuery.value,
                    onSeedSelected: (seed) {
                      if (!seeds.value.any((s) => s.id == seed.id && s.type == seed.type)) {
                        seeds.value = [...seeds.value, seed];
                      }
                      searchController.clear();
                      searchQuery.value = '';
                      isSearching.value = false;
                    },
                  )
                : _SeedListView(
                    seeds: seeds.value,
                    onRemove: (seed) {
                      seeds.value = seeds.value.where((s) => s != seed).toList();
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: seeds.value.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showCreateStationDialog(
                context,
                ref,
                seeds.value,
                playlistSize,
                isOnlineMode,
              ),
              icon: const Icon(Icons.radio_rounded),
              label: Text('Create (${seeds.value.length})'),
            ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Create a Station'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1. Search for songs, artists, albums, or genres'),
              SizedBox(height: 8),
              Text('2. Add multiple seeds to create a diverse station'),
              SizedBox(height: 8),
              Text('3. Tap the Create button to configure your station'),
              SizedBox(height: 8),
              Text('4. Select Online (all music) or Offline (downloaded only)'),
              SizedBox(height: 8),
              Text('5. Choose your playlist size and enjoy!'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showCreateStationDialog(
    BuildContext context,
    WidgetRef ref,
    List<SeedItem> seeds,
    ValueNotifier<int> playlistSize,
    ValueNotifier<bool> isOnlineMode,
  ) {
    showDialog(
      context: context,
      builder: (context) => _CreateStationDialog(
        seeds: seeds,
        playlistSize: playlistSize,
        isOnlineMode: isOnlineMode,
        onConfirm: (size, isOnline) {
          Navigator.of(context).pop();
          _createStation(context, ref, seeds, size, isOnline);
        },
      ),
    );
  }

  Future<void> _createStation(
    BuildContext context,
    WidgetRef ref,
    List<SeedItem> seeds,
    int playlistSize,
    bool isOnline,
  ) async {
    final audioControl = ref.read(audioControlProvider);
    final db = ref.read(databaseProvider);
    final sourceId = ref.read(sourceIdProvider);

    try {
      // Get the first seed song to start discovery
      Song? seedSong;
      String? seedArtist;
      String? seedGenre;

      for (final seed in seeds) {
        if (seed.type == SeedType.song) {
          // Direct song seed
          final songs = await db.songsInIds(sourceId, [seed.id]).get();
          if (songs.isNotEmpty) {
            seedSong = songs.first;
            seedArtist = seedSong.artist;
            seedGenre = seedSong.genre;
            break;
          }
        } else if (seed.type == SeedType.artist) {
          // Get a song from this artist
          final songs = await db.songsList(
            sourceId,
            ListQuery(
              filters: IListConst([
                FilterWith.equals(column: 'artist_id', value: seed.id),
              ]),
              page: const Pagination(limit: 1),
            ),
          ).get();
          if (songs.isNotEmpty) {
            seedSong = songs.first;
            seedArtist = seed.name; // Use the artist name from the seed
            seedGenre = seedSong.genre;
            break;
          }
        } else if (seed.type == SeedType.album) {
          // Get a song from this album
          final songs = await db.albumSongsList(
            SourceId(sourceId: sourceId, id: seed.id),
            const ListQuery(page: Pagination(limit: 1)),
          ).get();
          if (songs.isNotEmpty) {
            seedSong = songs.first;
            seedArtist = seedSong.artist;
            seedGenre = seedSong.genre;
            break;
          }
        } else if (seed.type == SeedType.genre) {
          // Get a song from this genre
          final songs = await db.songsList(
            sourceId,
            ListQuery(
              filters: IListConst([
                FilterWith.equals(column: 'genre', value: seed.name),
              ]),
              page: const Pagination(limit: 1),
            ),
          ).get();
          if (songs.isNotEmpty) {
            seedSong = songs.first;
            seedArtist = seedSong.artist;
            seedGenre = seed.name; // Use the genre name from the seed
            break;
          }
        }
      }

      if (seedSong == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not find songs for the selected seeds')),
        );
        return;
      }

      // Create a discovery session in the database for tracking
      final sessionId = await db.createDiscoverySession(
        sourceId: sourceId,
        seedSongId: seedSong.id,
        seedArtist: seedArtist,
        seedGenre: seedGenre,
        mode: isOnline ? 'online' : 'offline',
        playlistSize: playlistSize,
      );

      // Update last_played_at immediately so the station shows up in the list
      await db.updateStationLastPlayed(sessionId, DateTime.now());

      // Refresh the stations list immediately so the new station appears
      ref.read(savedStationsProvider.notifier).refresh();

      // Start hybrid discovery radio with the seed song
      // The discovery service will generate recommendations in the background
      await audioControl.playHybridDiscoveryRadio(
        seedSong: seedSong,
        mode: isOnline ? DiscoveryMode.online : DiscoveryMode.offline,
        playlistSize: playlistSize,
        sessionId: sessionId,
      );

      if (!context.mounted) return;
      // Navigate to now playing page
      context.navigateTo(const NowPlayingRoute());
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating station: $e')),
      );
    }
  }
}

class _SearchResults extends HookConsumerWidget {
  final String query;
  final Function(SeedItem) onSeedSelected;

  const _SearchResults({
    required this.query,
    required this.onSeedSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final sourceId = ref.watch(sourceIdProvider);
    final theme = Theme.of(context);

    return FutureBuilder<Map<String, List<dynamic>>>(
      future: _performSearch(db, sourceId, query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.values.every((list) => list.isEmpty)) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No results found',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data!;
        final songs = data['songs'] as List<Song>? ?? [];
        final artists = data['artists'] as List<Artist>? ?? [];
        final albums = data['albums'] as List<Album>? ?? [];
        final genres = data['genres'] as List<String>? ?? [];

        return ListView(
          children: [
            if (songs.isNotEmpty) ...[
              _SectionHeader(title: 'Songs (${songs.length})'),
              ...songs.map((song) => _SearchResultTile(
                    icon: Icons.music_note_rounded,
                    title: song.title,
                    subtitle: song.artist ?? 'Unknown Artist',
                    onTap: () => onSeedSelected(SeedItem(
                      type: SeedType.song,
                      id: song.id,
                      name: song.title,
                      subtitle: song.artist,
                    )),
                  )),
            ],
            if (artists.isNotEmpty) ...[
              _SectionHeader(title: 'Artists (${artists.length})'),
              ...artists.map((artist) => _SearchResultTile(
                    icon: Icons.person_rounded,
                    title: artist.name,
                    subtitle: '${artist.albumCount} album${artist.albumCount == 1 ? '' : 's'}',
                    onTap: () => onSeedSelected(SeedItem(
                      type: SeedType.artist,
                      id: artist.id,
                      name: artist.name,
                    )),
                  )),
            ],
            if (albums.isNotEmpty) ...[
              _SectionHeader(title: 'Albums (${albums.length})'),
              ...albums.map((album) => _SearchResultTile(
                    icon: Icons.album_rounded,
                    title: album.name,
                    subtitle: album.albumArtist ?? 'Unknown Artist',
                    onTap: () => onSeedSelected(SeedItem(
                      type: SeedType.album,
                      id: album.id,
                      name: album.name,
                      subtitle: album.albumArtist,
                    )),
                  )),
            ],
            if (genres.isNotEmpty) ...[
              _SectionHeader(title: 'Genres (${genres.length})'),
              ...genres.map((genre) => _SearchResultTile(
                    icon: Icons.category_rounded,
                    title: genre,
                    subtitle: 'Genre',
                    onTap: () => onSeedSelected(SeedItem(
                      type: SeedType.genre,
                      id: genre,
                      name: genre,
                    )),
                  )),
            ],
          ],
        );
      },
    );
  }

  Future<Map<String, List<dynamic>>> _performSearch(
    SubtracksDatabase db,
    int sourceId,
    String query,
  ) async {
    final ftsQuery = '(source_id : $sourceId) AND (- source_id : "$query"*)';

    // Search songs
    final songRowIds = await db.searchSongs(ftsQuery, 10, 0).get();
    final songs = await db.songsInRowIds(songRowIds).get();

    // Search artists
    final artistRowIds = await db.searchArtists(ftsQuery, 10, 0).get();
    final artists = await db.artistsInRowIds(artistRowIds).get();

    // Search albums
    final albumRowIds = await db.searchAlbums(ftsQuery, 10, 0).get();
    final albums = await db.albumsInRowIds(albumRowIds).get();

    // Search genres (simple contains match)
    final allGenres = await db.albumGenres(sourceId, 100, 0).get();
    final genres = allGenres
        .whereType<String>()
        .where((g) => g.toLowerCase().contains(query.toLowerCase()))
        .take(10)
        .toList();

    return {
      'songs': songs,
      'artists': artists,
      'albums': albums,
      'genres': genres,
    };
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Icon(icon, size: 20),
      ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.add_circle_outline),
      onTap: onTap,
    );
  }
}

class _SeedListView extends StatelessWidget {
  final List<SeedItem> seeds;
  final Function(SeedItem) onRemove;

  const _SeedListView({
    required this.seeds,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (seeds.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.radio_rounded,
                size: 56,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 12),
              Text(
                'No seeds added yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Search and add songs, artists, albums, or genres',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Seeds (${seeds.length})',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'These will be used to generate your discovery playlist',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: seeds.map((seed) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 32, // Account for padding
              ),
              child: Chip(
                avatar: Icon(seed.icon, size: 18),
                label: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      seed.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (seed.subtitle != null)
                      Text(
                        seed.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => onRemove(seed),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CreateStationDialog extends HookWidget {
  final List<SeedItem> seeds;
  final ValueNotifier<int> playlistSize;
  final ValueNotifier<bool> isOnlineMode;
  final Function(int size, bool isOnline) onConfirm;

  const _CreateStationDialog({
    required this.seeds,
    required this.playlistSize,
    required this.isOnlineMode,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = useState(playlistSize.value);
    final isOnline = useState(isOnlineMode.value);

    return AlertDialog(
      title: const Text('Create Discovery Station'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seeds summary
            Text(
              'Seeds (${seeds.length})',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            ...seeds.take(3).map((seed) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(seed.icon, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      seed.name,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )),
            if (seeds.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'and ${seeds.length - 3} more...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Playlist Size
            Text(
              'Playlist Size',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 25, label: Text('25')),
                ButtonSegment(value: 50, label: Text('50')),
                ButtonSegment(value: 100, label: Text('100')),
              ],
              selected: {size.value},
              onSelectionChanged: (Set<int> newSelection) {
                size.value = newSelection.first;
              },
            ),
            const SizedBox(height: 24),

            // Mode Toggle
            Row(
              children: [
                Icon(
                  isOnline.value ? Icons.cloud : Icons.download,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Mode',
                  style: theme.textTheme.titleSmall,
                ),
                const Spacer(),
                Switch(
                  value: isOnline.value,
                  onChanged: (value) {
                    isOnline.value = value;
                  },
                ),
                Text(
                  isOnline.value ? 'Online' : 'Offline',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: () => onConfirm(size.value, isOnline.value),
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Create Station'),
        ),
      ],
    );
  }
}
