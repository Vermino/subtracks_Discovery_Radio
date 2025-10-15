import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../services/settings_service.dart';

/// Settings section for YouTube Discovery integration
///
/// This widget provides a simple toggle for enabling/disabling YouTube discovery globally.
/// Per-station ratio settings are configured when creating or editing individual stations.
class YouTubeSettingsSection extends HookConsumerWidget {
  const YouTubeSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsServiceProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Enable/Disable YouTube Discovery
        SwitchListTile(
          value: settings.app.youtubeDiscoveryEnabled,
          title: const Text('YouTube Discovery'),
          subtitle: const Text(
            'Include YouTube tracks in discovery stations.\nConfigure ratio per-station when creating or editing.',
          ),
          secondary: Icon(
            Icons.play_circle_outline,
            color: settings.app.youtubeDiscoveryEnabled
                ? Colors.red.shade700
                : theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          onChanged: (value) {
            ref
                .read(settingsServiceProvider.notifier)
                .setYouTubeDiscoveryEnabled(value);
          },
        ),

        // Advanced settings (only shown when enabled)
        if (settings.app.youtubeDiscoveryEnabled) ...[
          const Divider(indent: 16, endIndent: 16),

          // Quality Filter Dropdown
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Quality Filter'),
            subtitle: Text(_getQualityFilterDescription(
              settings.app.youtubeQualityFilter,
            )),
            trailing: DropdownButton<String>(
              value: settings.app.youtubeQualityFilter,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                  value: 'strict',
                  child: Text('Strict'),
                ),
                DropdownMenuItem(
                  value: 'moderate',
                  child: Text('Moderate'),
                ),
                DropdownMenuItem(
                  value: 'permissive',
                  child: Text('Permissive'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(settingsServiceProvider.notifier)
                      .setYouTubeQualityFilter(value);
                }
              },
            ),
          ),

          // Prefer Official Channels Toggle
          SwitchListTile(
            secondary: const Icon(Icons.verified),
            value: settings.app.youtubePreferOfficial,
            title: const Text('Prefer Official Channels'),
            subtitle: const Text('Prioritize VEVO and official artist channels'),
            onChanged: (value) {
              ref
                  .read(settingsServiceProvider.notifier)
                  .setYouTubePreferOfficial(value);
            },
          ),
        ],
      ],
    );
  }

  String _getQualityFilterDescription(String filter) {
    switch (filter) {
      case 'strict':
        return 'Official music videos and audio only';
      case 'moderate':
        return 'Recommended - balanced filtering';
      case 'permissive':
        return 'All music content allowed';
      default:
        return 'Unknown filter level';
    }
  }
}

