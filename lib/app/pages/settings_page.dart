import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:subtracks/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../log.dart';
import '../../models/support.dart';
import '../../services/local_music_import_service.dart';
import '../../services/settings_service.dart';
import '../../state/init.dart';
import '../../state/settings.dart';
import '../../state/theme_presets.dart';
import '../app_router.dart';
import '../dialogs.dart';
import '../widgets/youtube_settings_section.dart';

const kHorizontalPadding = 16.0;

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    // final downloads = ref.watch(downloadServiceProvider.select(
    //   (value) => value.downloads,
    // ));

    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 96),
          _SectionHeader(l.settingsServersName),
          const _Sources(),
          _SectionHeader(l.settingsNetworkName),
          const _Network(),
          const _SectionHeader('Download Settings'),
          const _DownloadSettings(),
          const _SectionHeader('Local Music'),
          const _LocalMusicSection(),
          const _SectionHeader('Discovery'),
          const _Section(
            children: [
              YouTubeSettingsSection(),
            ],
          ),
          const _SectionHeader('Appearance'),
          const _Section(
            children: [
              _ThemePresetSelector(),
              _DynamicColorsToggle(),
            ],
          ),
          _SectionHeader(l.settingsAboutName),
          _About(),
          // const _SectionHeader('Downloads'),
          // _Section(
          //   children: downloads
          //       .map(
          //         (e) => ListTile(
          //           isThreeLine: true,
          //           title: Text(e.filename ?? e.url),
          //           subtitle: Column(
          //             mainAxisAlignment: MainAxisAlignment.start,
          //             children: [
          //               Row(children: [Text('Progress: ${e.progress}%')]),
          //               Row(children: [Text('Status: ${e.status})')]),
          //               Text('Status: ${e.savedDir}'),
          //             ],
          //           ),
          //           trailing:
          //               CircularProgressIndicator(value: e.progress / 100),
          //         ),
          //       )
          //       .toList(),
          // ),
        ],
      ),
    );
  }
}

class _ThemePresetSelector extends HookConsumerWidget {
  const _ThemePresetSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPreset = ref.watch(
      settingsServiceProvider.select((value) => value.app.themePreset),
    );
    final presetConfig = getThemePreset(currentPreset);

    return ListTile(
      leading: Icon(
        Icons.palette,
        color: presetConfig.seedColor,
      ),
      title: const Text('Theme'),
      subtitle: Text(presetConfig.name),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final value = await showDialog<String>(
          context: context,
          builder: (context) => _ThemePresetDialog(current: currentPreset),
        );

        if (value != null && value != currentPreset) {
          await ref
              .read(settingsServiceProvider.notifier)
              .setThemePreset(value);
        }
      },
    );
  }
}

class _ThemePresetDialog extends StatelessWidget {
  final String current;

  const _ThemePresetDialog({required this.current});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose Theme'),
      contentPadding: const EdgeInsets.only(top: 20),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: themePresets.entries.map((entry) {
            final key = entry.key;
            final config = entry.value;
            final isSelected = key == current;

            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: config.seedColor,
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(config.name),
              subtitle: Text(config.description),
              trailing: isSelected
                  ? Icon(Icons.check, color: config.seedColor)
                  : null,
              selected: isSelected,
              onTap: () => Navigator.of(context).pop(key),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _DynamicColorsToggle extends HookConsumerWidget {
  const _DynamicColorsToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(
      settingsServiceProvider.select(
        (value) => value.app.enableDynamicColors,
      ),
    );

    return SwitchListTile(
      secondary: const Icon(Icons.auto_awesome),
      title: const Text('Dynamic Colors'),
      subtitle: const Text('Generate colors from album artwork'),
      value: enabled,
      onChanged: (value) {
        ref
            .read(settingsServiceProvider.notifier)
            .setEnableDynamicColors(value);
      },
    );
  }
}

class _Section extends StatelessWidget {
  final List<Widget> children;

  const _Section({required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...children,
        const SizedBox(height: 32),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kHorizontalPadding),
            child: Text(
              title,
              style: theme.textTheme.displaySmall,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _Network extends StatelessWidget {
  const _Network();

  @override
  Widget build(BuildContext context) {
    return const _Section(
      children: [
        _OfflineMode(),
        _MaxBitrateWifi(),
        _MaxBitrateMobile(),
        _StreamFormat(),
      ],
    );
  }
}

class _About extends HookConsumerWidget {
  _About();

  final _homepage = Uri.parse('https://github.com/austinried/subtracks');
  final _donate = Uri.parse('https://ko-fi.com/austinried');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final pkg = ref.watch(packageInfoProvider).requireValue;

    return _Section(
      children: [
        ListTile(
          title: const Text('subtracks'),
          subtitle: Text(l.settingsAboutVersion(pkg.version)),
        ),
        ListTile(
          title: Text(l.settingsAboutActionsLicenses),
          // trailing: const Icon(Icons.open_in_new_rounded),
          onTap: () {},
        ),
        ListTile(
          title: Text(l.settingsAboutActionsProjectHomepage),
          subtitle: Text(_homepage.toString()),
          trailing: const Icon(Icons.open_in_new_rounded),
          onTap: () => launchUrl(
            _homepage,
            mode: LaunchMode.externalApplication,
          ),
        ),
        ListTile(
          title: Text(l.settingsAboutActionsSupport),
          subtitle: Text(_donate.toString()),
          trailing: const Icon(Icons.open_in_new_rounded),
          onTap: () => launchUrl(
            _donate,
            mode: LaunchMode.externalApplication,
          ),
        ),
        const SizedBox(height: 12),
        const _ShareLogsButton(),
      ],
    );
  }
}

class _ShareLogsButton extends StatelessWidget {
  const _ShareLogsButton();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.share),
          label: Text(l.settingsAboutShareLogs),
          onPressed: () async {
            final files = await logFiles();
            if (files.isEmpty) return;

            if (!context.mounted) return;
            final value = await showDialog<String>(
              context: context,
              builder: (context) => MultipleChoiceDialog<String>(
                title: l.settingsAboutChooseLog,
                current: files.first.path,
                options: files
                    .map((e) => MultiChoiceOption.string(
                          title: p.basename(e.path),
                          option: e.path,
                        ))
                    .toIList(),
              ),
            );

            if (value == null) return;
            Share.shareXFiles(
              [XFile(value, mimeType: 'text/plain')],
              subject: 'Logs from subtracks: ${String.fromCharCodes(
                List.generate(8, (_) => Random().nextInt(26) + 65),
              )}',
            );
          },
        ),
      ],
    );
  }
}

class _MaxBitrateWifi extends HookConsumerWidget {
  const _MaxBitrateWifi();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bitrate = ref.watch(settingsServiceProvider.select(
      (value) => value.app.maxBitrateWifi,
    ));
    final l = AppLocalizations.of(context);

    return _MaxBitrateOption(
      title: l.settingsNetworkOptionsMaxBitrateWifiTitle,
      bitrate: bitrate,
      onChange: (value) {
        ref.read(settingsServiceProvider.notifier).setMaxBitrateWifi(value);
      },
    );
  }
}

class _MaxBitrateMobile extends HookConsumerWidget {
  const _MaxBitrateMobile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bitrate = ref.watch(settingsServiceProvider.select(
      (value) => value.app.maxBitrateMobile,
    ));
    final l = AppLocalizations.of(context);

    return _MaxBitrateOption(
      title: l.settingsNetworkOptionsMaxBitrateMobileTitle,
      bitrate: bitrate,
      onChange: (value) {
        ref.read(settingsServiceProvider.notifier).setMaxBitrateMobile(value);
      },
    );
  }
}

class _MaxBitrateOption extends HookConsumerWidget {
  final String title;
  final int bitrate;
  final void Function(int value) onChange;

  const _MaxBitrateOption({
    required this.title,
    required this.bitrate,
    required this.onChange,
  });

  static const options = [0, 24, 32, 64, 96, 128, 192, 256, 320];

  String _bitrateText(AppLocalizations l, int bitrate) {
    return bitrate == 0
        ? l.settingsNetworkValuesUnlimitedKbps
        : l.settingsNetworkValuesKbps(bitrate.toString());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);

    return ListTile(
      title: Text(title),
      subtitle: Text(_bitrateText(l, bitrate)),
      onTap: () async {
        final value = await showDialog<int>(
          context: context,
          builder: (context) => MultipleChoiceDialog<int>(
            title: title,
            current: bitrate,
            options: options
                .map((opt) => MultiChoiceOption.int(
                      title: _bitrateText(l, opt),
                      option: opt,
                    ))
                .toIList(),
          ),
        );

        if (value != null) {
          onChange(value);
        }
      },
    );
  }
}

class _StreamFormat extends HookConsumerWidget {
  const _StreamFormat();

  static const options = ['', 'mp3', 'opus', 'ogg'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamFormat = ref.watch(
      settingsServiceProvider.select((value) => value.app.streamFormat),
    );
    final l = AppLocalizations.of(context);

    return ListTile(
      title: Text(l.settingsNetworkOptionsStreamFormat),
      subtitle: Text(
        streamFormat ?? l.settingsNetworkOptionsStreamFormatServerDefault,
      ),
      onTap: () async {
        final value = await showDialog<String>(
          context: context,
          builder: (context) => MultipleChoiceDialog<String>(
            title: l.settingsNetworkOptionsStreamFormat,
            current: streamFormat ?? '',
            options: options
                .map((opt) => MultiChoiceOption.string(
                      title: opt == ''
                          ? l.settingsNetworkOptionsStreamFormatServerDefault
                          : opt,
                      option: opt,
                    ))
                .toIList(),
          ),
        );

        if (value != null) {
          ref
              .read(settingsServiceProvider.notifier)
              .setStreamFormat(value == '' ? null : value);
        }
      },
    );
  }
}

class _OfflineMode extends HookConsumerWidget {
  const _OfflineMode();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.watch(offlineModeProvider);
    final l = AppLocalizations.of(context);

    return SwitchListTile(
      value: offline,
      title: Text(l.settingsNetworkOptionsOfflineMode),
      subtitle: offline
          ? Text(l.settingsNetworkOptionsOfflineModeOn)
          : Text(l.settingsNetworkOptionsOfflineModeOff),
      onChanged: (value) {
        ref.read(offlineModeProvider.notifier).setMode(value);
      },
    );
  }
}

class _DownloadSettings extends StatelessWidget {
  const _DownloadSettings();

  @override
  Widget build(BuildContext context) {
    return const _Section(
      children: [
        _DownloadPreference(),
        _ThumbsUpAutoDownload(),
        _ThumbsDownAutoDelete(),
      ],
    );
  }
}

class _DownloadPreference extends HookConsumerWidget {
  const _DownloadPreference();

  String _getDownloadPrefLabel(String pref) {
    switch (pref) {
      case 'wifi_only':
        return 'WiFi Only';
      case 'any_connection':
        return 'Any Connection';
      case 'manual_only':
        return 'Manual Only';
      default:
        return 'Any Connection';
    }
  }

  void _showDownloadPrefDialog(BuildContext context, WidgetRef ref) {
    final currentPref = ref.read(settingsServiceProvider).app.downloadPreference;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Preference'),
        contentPadding: const EdgeInsets.only(top: 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('WiFi Only'),
              subtitle: const Text('Download only when connected to WiFi'),
              value: 'wifi_only',
              groupValue: currentPref,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(settingsServiceProvider.notifier)
                      .setDownloadPreference(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Any Connection'),
              subtitle: const Text('Download on WiFi or mobile data'),
              value: 'any_connection',
              groupValue: currentPref,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(settingsServiceProvider.notifier)
                      .setDownloadPreference(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Manual Only'),
              subtitle: const Text('Never download automatically'),
              value: 'manual_only',
              groupValue: currentPref,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(settingsServiceProvider.notifier)
                      .setDownloadPreference(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadPref = ref.watch(
      settingsServiceProvider.select((value) => value.app.downloadPreference),
    );

    return ListTile(
      leading: const Icon(Icons.download),
      title: const Text('Download Preference'),
      subtitle: Text(_getDownloadPrefLabel(downloadPref)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showDownloadPrefDialog(context, ref),
    );
  }
}

class _ThumbsUpAutoDownload extends HookConsumerWidget {
  const _ThumbsUpAutoDownload();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(
      settingsServiceProvider.select(
        (value) => value.app.thumbsUpAutoDownload,
      ),
    );

    return SwitchListTile(
      secondary: const Icon(Icons.thumb_up),
      title: const Text('Auto-Download Thumbs Up'),
      subtitle: const Text('Automatically download songs you like'),
      value: enabled,
      onChanged: (value) {
        ref
            .read(settingsServiceProvider.notifier)
            .setThumbsUpAutoDownload(value);
      },
    );
  }
}

class _ThumbsDownAutoDelete extends HookConsumerWidget {
  const _ThumbsDownAutoDelete();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(
      settingsServiceProvider.select(
        (value) => value.app.thumbsDownAutoDelete,
      ),
    );

    return SwitchListTile(
      secondary: const Icon(Icons.thumb_down),
      title: const Text('Auto-Delete Thumbs Down'),
      subtitle: const Text('Automatically remove songs you dislike'),
      value: enabled,
      onChanged: (value) {
        ref
            .read(settingsServiceProvider.notifier)
            .setThumbsDownAutoDelete(value);
      },
    );
  }
}

class _LocalMusicSection extends HookConsumerWidget {
  const _LocalMusicSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _Section(
      children: [
        const _LocalMusicImportFilesButton(),
        const _LocalMusicImportFolderButton(),
        const _LocalMusicStats(),
        const _ClearLocalLibraryButton(),
      ],
    );
  }
}

class _LocalMusicImportFilesButton extends HookConsumerWidget {
  const _LocalMusicImportFilesButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.audio_file),
      title: const Text('Import Files'),
      subtitle: const Text('Select multiple songs from any location'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        // Show snackbar instead of blocking dialog
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Importing files... This may take a moment.'),
            duration: Duration(seconds: 2),
          ),
        );

        try {
          final service = ref.read(localMusicImportServiceProvider.notifier);

          // Run import - this may take time but won't block UI
          final result = await service.importFromDevice();

          if (!context.mounted) return;

          // Show result dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Import Complete'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result.message),
                  if (result.hasErrors) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Errors:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...result.errors.map(
                      (error) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• $error',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } catch (e) {
          if (!context.mounted) return;

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Import Failed'),
              content: Text('An error occurred: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class _LocalMusicImportFolderButton extends HookConsumerWidget {
  const _LocalMusicImportFolderButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.folder),
      title: const Text('Import Folder'),
      subtitle: const Text('Batch import from Artist/Album folders (may not work on all devices)'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        // Show snackbar instead of blocking dialog
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Importing folder... This may take a while.'),
            duration: Duration(seconds: 2),
          ),
        );

        try {
          final service = ref.read(localMusicImportServiceProvider.notifier);

          // Run import - this may take time but won't block UI
          final result = await service.importFromFolder();

          if (!context.mounted) return;

          // Show result dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Import Complete'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result.message),
                  if (result.hasErrors) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Errors:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...result.errors.map(
                      (error) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• $error',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } catch (e) {
          if (!context.mounted) return;

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Import Failed'),
              content: Text('An error occurred: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class _LocalMusicStats extends HookConsumerWidget {
  const _LocalMusicStats();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localMusicService = ref.watch(localMusicImportServiceProvider);

    return localMusicService.when(
      data: (_) {
        return FutureBuilder<int>(
          future: ref
              .read(localMusicImportServiceProvider.notifier)
              .getLocalSongsCount(),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            return ListTile(
              leading: const Icon(Icons.music_note),
              title: const Text('Local Songs'),
              subtitle: Text('$count ${count == 1 ? 'song' : 'songs'} imported'),
            );
          },
        );
      },
      loading: () => const ListTile(
        leading: Icon(Icons.music_note),
        title: Text('Local Songs'),
        subtitle: Text('Loading...'),
      ),
      error: (error, stack) => ListTile(
        leading: const Icon(Icons.error),
        title: const Text('Local Songs'),
        subtitle: Text('Error: $error'),
      ),
    );
  }
}

class _ClearLocalLibraryButton extends HookConsumerWidget {
  const _ClearLocalLibraryButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.delete_outline, color: Colors.red),
      title: const Text('Clear Local Library'),
      subtitle: const Text('Remove all local music (files stay on device)'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        // Show confirmation dialog
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Clear Local Library?'),
            content: const Text(
              'This will remove all local music from Subtracks.\n\n'
              'Your original music files will NOT be deleted from your device - '
              'they will remain in their original location.\n\n'
              'You can re-import them anytime.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Clear Library'),
              ),
            ],
          ),
        );

        if (confirmed != true) return;
        if (!context.mounted) return;

        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        try {
          final service = ref.read(localMusicImportServiceProvider.notifier);
          final success = await service.clearLocalLibrary();

          if (!context.mounted) return;
          Navigator.of(context).pop(); // Dismiss loading

          // Show result
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(success ? 'Library Cleared' : 'Error'),
              content: Text(
                success
                    ? 'All local music has been removed from Subtracks.\n\nYour files remain in their original location on your device.'
                    : 'Failed to clear local library. Please try again.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } catch (e) {
          if (!context.mounted) return;
          Navigator.of(context).pop(); // Dismiss loading

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text('An error occurred: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class _Sources extends HookConsumerWidget {
  const _Sources();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sources = ref.watch(settingsServiceProvider.select(
      (value) => value.sources,
    ));
    final activeSource = ref.watch(settingsServiceProvider.select(
      (value) => value.activeSource,
    ));

    final l = AppLocalizations.of(context);

    return _Section(
      children: [
        for (var source in sources)
          RadioListTile<int>(
            value: source.id,
            groupValue: activeSource?.id,
            onChanged: (value) {
              ref
                  .read(settingsServiceProvider.notifier)
                  .setActiveSource(source.id);
            },
            title: Text(source.name),
            subtitle: Text(
              source.address.toString(),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
            secondary: IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () {
                context.pushRoute(SourceRoute(id: source.id));
              },
            ),
          ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.add_rounded),
              label: Text(l.settingsServersActionsAdd),
              onPressed: () {
                context.pushRoute(SourceRoute());
              },
            ),
          ],
        ),
        // TODO: remove
        if (kDebugMode)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add TEST'),
                onPressed: () {
                  ref
                      .read(settingsServiceProvider.notifier)
                      .addTestSource('TEST');
                },
              ),
            ],
          ),
      ],
    );
  }
}
