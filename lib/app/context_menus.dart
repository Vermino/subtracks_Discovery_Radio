// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:subtracks/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../database/database.dart';
import '../models/music.dart';
import '../services/audio_service.dart';
import '../services/cache_service.dart';
import '../services/discovery_service.dart';
import '../services/download_service.dart';
import '../services/settings_service.dart';
import '../state/music.dart';
import '../state/theme.dart';
import 'app_router.dart';
import 'dialogs.dart';
import 'hooks/use_download_actions.dart';
import 'images.dart';

enum MenuSize {
  small,
  medium,
}

Future<T?> showContextMenu<T>({
  required BuildContext context,
  required WidgetRef ref,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    backgroundColor: ref.read(baseThemeProvider).theme.colorScheme.surface,
    useRootNavigator: true,
    isScrollControlled: true,
    context: context,
    builder: builder,
  );
}

class BottomSheetMenu extends HookConsumerWidget {
  final Widget child;
  final MenuSize size;

  const BottomSheetMenu({
    super.key,
    required this.child,
    this.size = MenuSize.medium,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(baseThemeProvider);
    final height = size == MenuSize.medium ? 0.4 : 0.25;

    return Theme(
      data: theme.theme,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: height,
        maxChildSize: height,
        minChildSize: height - 0.05,
        snap: true,
        snapSizes: [height - 0.05, height],
        builder: (context, scrollController) {
          return PrimaryScrollController(
            controller: scrollController,
            child: SizedBox(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}

class AlbumContextMenu extends HookConsumerWidget {
  final Album album;

  const AlbumContextMenu({
    super.key,
    required this.album,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadActions = useAlbumDownloadActions(
      context: context,
      ref: ref,
      album: album,
    );

    return ListView(
      children: [
        _AlbumHeader(album: album),
        const SizedBox(height: 8),
        _PlayAlbumRadio(album: album),
        const _Star(),
        if (album.artistId != null) _ViewArtist(id: album.artistId!),
        for (var action in downloadActions)
          _DownloadAction(key: ValueKey(action.type), downloadAction: action),
      ],
    );
  }
}

class SongContextMenu extends HookConsumerWidget {
  final Song song;

  const SongContextMenu({
    super.key,
    required this.song,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        _SongHeader(song: song),
        const SizedBox(height: 8),
        _PlayDiscoveryRadio(song: song),
        const _Star(),
        if (song.artistId != null) _ViewArtist(id: song.artistId!),
        if (song.albumId != null) _ViewAlbum(id: song.albumId!),
        _DeleteLocalSong(song: song),
      ],
    );
  }
}

class ArtistContextMenu extends HookConsumerWidget {
  final Artist artist;

  const ArtistContextMenu({
    super.key,
    required this.artist,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        _ArtistHeader(artist: artist),
        const SizedBox(height: 8),
        _PlayArtistRadio(artist: artist),
        const _Star(),
        _DeleteLocalArtist(artist: artist),
      ],
    );
  }
}

class PlaylistContextMenu extends HookConsumerWidget {
  final Playlist playlist;

  const PlaylistContextMenu({
    super.key,
    required this.playlist,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadActions = usePlaylistDownloadActions(
      context: context,
      ref: ref,
      playlist: playlist,
    );

    return ListView(
      children: [
        _PlaylistHeader(playlist: playlist),
        const SizedBox(height: 8),
        for (var action in downloadActions)
          _DownloadAction(key: ValueKey(action.type), downloadAction: action),
      ],
    );
  }
}

class _AlbumHeader extends HookConsumerWidget {
  final Album album;

  const _AlbumHeader({
    required this.album,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cache = ref.watch(cacheServiceProvider);

    return _Header(
      title: album.name,
      subtitle: album.albumArtist,
      image: CardClip(
        child: UriCacheInfoImage(
          cache: cache.albumArt(album, thumbnail: true),
        ),
      ),
    );
  }
}

class _SongHeader extends HookConsumerWidget {
  final Song song;

  const _SongHeader({
    required this.song,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _Header(
      title: song.title,
      subtitle: song.artist,
      image: SongAlbumArt(song: song, square: false),
    );
  }
}

class _ArtistHeader extends HookConsumerWidget {
  final Artist artist;

  const _ArtistHeader({
    required this.artist,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return _Header(
      title: artist.name,
      subtitle: l.resourcesAlbumCount(artist.albumCount),
      image: CircleClip(child: ArtistArtImage(artistId: artist.id)),
    );
  }
}

class _PlaylistHeader extends HookConsumerWidget {
  final Playlist playlist;

  const _PlaylistHeader({
    required this.playlist,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cache = ref.watch(cacheServiceProvider);
    final l = AppLocalizations.of(context);
    return _Header(
      title: playlist.name,
      subtitle: l.resourcesSongCount(playlist.songCount),
      image: CardClip(
        child: UriCacheInfoImage(
          cache: cache.playlistArt(playlist, thumbnail: true),
        ),
      ),
    );
  }
}

class _Header extends HookConsumerWidget {
  final String title;
  final String? subtitle;
  final Widget image;

  const _Header({
    required this.title,
    this.subtitle,
    required this.image,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 80, width: 80, child: image),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleLarge),
                if (subtitle != null)
                  Text(subtitle!, style: theme.textTheme.titleSmall),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _Star extends HookConsumerWidget {
  const _Star();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return _MenuItem(
      title: l.actionsStar,
      icon: const Icon(Icons.star_outline_rounded),
      onTap: () {},
    );
  }
}

class _DownloadAction extends HookConsumerWidget {
  final DownloadAction downloadAction;

  const _DownloadAction({
    super.key,
    required this.downloadAction,
  });

  String _actionText(AppLocalizations l) {
    switch (downloadAction.type) {
      case DownloadActionType.download:
        return l.actionsDownload;
      case DownloadActionType.cancel:
        return l.actionsDownloadCancel;
      case DownloadActionType.delete:
        return l.actionsDownloadDelete;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _MenuItem(
      title: _actionText(AppLocalizations.of(context)),
      icon: downloadAction.iconBuilder(context),
      onTap: downloadAction.action,
    );
  }
}

class _ViewArtist extends HookConsumerWidget {
  final String id;

  const _ViewArtist({
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return _MenuItem(
      title: l.resourcesArtistActionsView,
      icon: const Icon(Icons.person_rounded),
      onTap: () async {
        final router = context.router;

        await router.pop();
        if (router.currentPath == '/now-playing') {
          await router.pop();
          await router.navigate(const LibraryRouter());
        }
        await router.navigate(ArtistRoute(id: id));
      },
    );
  }
}

class _ViewAlbum extends HookConsumerWidget {
  final String id;

  const _ViewAlbum({
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return _MenuItem(
      title: l.resourcesAlbumActionsView,
      icon: const Icon(Icons.album_rounded),
      onTap: () async {
        final router = context.router;

        await router.pop();
        if (router.currentPath == '/now-playing') {
          await router.pop();
          await router.navigate(const LibraryRouter());
        }
        await router.navigate(AlbumSongsRoute(id: id));
      },
    );
  }
}

class _PlayDiscoveryRadio extends HookConsumerWidget {
  final Song song;

  const _PlayDiscoveryRadio({
    required this.song,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _MenuItem(
      title: 'Start Radio Station',
      icon: const Icon(Icons.explore),
      onTap: () async {
        final audioControl = ref.read(audioControlProvider);
        final settings = ref.read(settingsServiceProvider);
        Navigator.of(context).pop(); // Close context menu

        // Use hybrid discovery with YouTube integration if enabled
        await audioControl.playHybridDiscoveryRadio(
          seedSong: song,
          mode: DiscoveryMode.online,
          config: DiscoveryConfig(
            youtubeEnabled: settings.app.youtubeDiscoveryEnabled,
            youtubeRatio: settings.app.youtubeDiscoveryRatio,
            youtubeQualityFilter: YouTubeQualityFilter.values.byName(
              settings.app.youtubeQualityFilter,
            ),
            youtubePreferOfficial: settings.app.youtubePreferOfficial,
          ),
        );
      },
    );
  }
}

class _PlayArtistRadio extends HookConsumerWidget {
  final Artist artist;

  const _PlayArtistRadio({
    required this.artist,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _MenuItem(
      title: 'Start Artist Radio',
      icon: const Icon(Icons.explore),
      onTap: () async {
        final audioControl = ref.read(audioControlProvider);
        Navigator.of(context).pop(); // Close context menu

        await audioControl.playDiscoveryRadioByArtist(
          artistId: artist.id,
          mode: DiscoveryMode.online,
        );
      },
    );
  }
}

class _PlayAlbumRadio extends HookConsumerWidget {
  final Album album;

  const _PlayAlbumRadio({
    required this.album,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return _MenuItem(
      title: 'Start Album Radio',
      icon: const Icon(Icons.explore),
      onTap: () async {
        final audioControl = ref.read(audioControlProvider);
        final settings = ref.read(settingsServiceProvider);
        Navigator.of(context).pop(); // Close context menu

        // Get first song from album as seed
        final songs = await db.filterSongs(
          (tbl) => tbl.albumId.equals(album.id),
          (tbl) => OrderBy([OrderingTerm(expression: tbl.track)]),
          (tbl) => Limit(1, null),
        ).get();

        if (songs.isNotEmpty) {
          // Use hybrid discovery with YouTube integration if enabled
          await audioControl.playHybridDiscoveryRadio(
            seedSong: songs.first,
            mode: DiscoveryMode.online,
            config: DiscoveryConfig(
              youtubeEnabled: settings.app.youtubeDiscoveryEnabled,
              youtubeRatio: settings.app.youtubeDiscoveryRatio,
              youtubeQualityFilter: YouTubeQualityFilter.values.byName(
                settings.app.youtubeQualityFilter,
              ),
              youtubePreferOfficial: settings.app.youtubePreferOfficial,
            ),
          );
        }
      },
    );
  }
}

class _DeleteLocalSong extends HookConsumerWidget {
  final Song song;

  const _DeleteLocalSong({
    required this.song,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only show if song is downloaded
    if (song.downloadFilePath == null) {
      return const SizedBox.shrink();
    }

    final l = AppLocalizations.of(context);
    return _MenuItem(
      title: l.actionsDownloadDelete,
      icon: const Icon(Icons.delete_forever_rounded),
      onTap: () async {
        final ok = await showDialog<bool>(
          context: context,
          builder: (context) => const DeleteDialog(),
        );
        if (ok == true) {
          final downloadService = ref.read(downloadServiceProvider.notifier);
          await downloadService.deleteSong(song);
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
    );
  }
}

class _DeleteLocalAlbum extends HookConsumerWidget {
  final Album album;

  const _DeleteLocalAlbum({
    required this.album,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(albumDownloadStatusProvider(album.id)).valueOrNull;

    // Only show if album has downloaded songs
    if (status == null || status.downloaded == 0) {
      return const SizedBox.shrink();
    }

    final l = AppLocalizations.of(context);
    return _MenuItem(
      title: l.actionsDownloadDelete,
      icon: const Icon(Icons.delete_forever_rounded),
      onTap: () async {
        final ok = await showDialog<bool>(
          context: context,
          builder: (context) => const DeleteDialog(),
        );
        if (ok == true) {
          final downloadService = ref.read(downloadServiceProvider.notifier);
          await downloadService.deleteAlbum(album);
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
    );
  }
}

class _DeleteLocalArtist extends HookConsumerWidget {
  final Artist artist;

  const _DeleteLocalArtist({
    required this.artist,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final hasDownloadedSongs = ref.watch(
      db.filterSongsDownloaded(
        (tbl) => tbl.artistId.equals(artist.id) & tbl.sourceId.equals(artist.sourceId),
        (tbl) => OrderBy([]),
        (tbl) => Limit(1, null),
      ).watchSingle().select((data) => data != null),
    );

    // Only show if artist has downloaded songs
    if (!hasDownloadedSongs.valueOrNull ?? true) {
      return const SizedBox.shrink();
    }

    final l = AppLocalizations.of(context);
    return _MenuItem(
      title: l.actionsDownloadDelete,
      icon: const Icon(Icons.delete_forever_rounded),
      onTap: () async {
        final ok = await showDialog<bool>(
          context: context,
          builder: (context) => const DeleteDialog(),
        );
        if (ok == true) {
          final downloadService = ref.read(downloadServiceProvider.notifier);
          await downloadService.deleteArtist(artist);
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String title;
  final Widget icon;
  final FutureOr<void> Function()? onTap;

  const _MenuItem({
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: Padding(
        padding: const EdgeInsetsDirectional.only(start: 8),
        child: icon,
      ),
      onTap: onTap,
    );
  }
}
