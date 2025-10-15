import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../services/settings_service.dart';

/// Settings section for YouTube Discovery integration
///
/// This widget provides UI controls for enabling/disabling YouTube discovery,
/// adjusting the ratio of YouTube vs local content, and configuring quality filters.
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
          subtitle: const Text('Include YouTube tracks in discovery stations'),
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

        // YouTube-specific settings (only shown when enabled)
        if (settings.app.youtubeDiscoveryEnabled) ...[
          const Divider(indent: 16, endIndent: 16),

          // YouTube Content Ratio Slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'YouTube Content Ratio',
                      style: theme.textTheme.titleSmall,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red.shade700.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '${(settings.app.youtubeDiscoveryRatio * 100).round()}%',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Percentage of YouTube tracks in discovery playlists',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Slider(
                  value: settings.app.youtubeDiscoveryRatio,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  label:
                      '${(settings.app.youtubeDiscoveryRatio * 100).round()}%',
                  activeColor: Colors.red.shade700,
                  onChanged: (value) {
                    ref
                        .read(settingsServiceProvider.notifier)
                        .setYouTubeRatio(value);
                  },
                ),
                // Visual indicator showing local vs YouTube split
                Row(
                  children: [
                    Expanded(
                      flex:
                          ((1 - settings.app.youtubeDiscoveryRatio) * 100).round(),
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: (settings.app.youtubeDiscoveryRatio * 100).round(),
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Local',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      'YouTube',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Quality Filter Dropdown
          ListTile(
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

          // Quality Filter Info Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _QualityFilterInfoCard(
              filter: settings.app.youtubeQualityFilter,
            ),
          ),

          // Prefer Official Channels Toggle
          SwitchListTile(
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

/// Information card that explains what each quality filter does
class _QualityFilterInfoCard extends StatelessWidget {
  final String filter;

  const _QualityFilterInfoCard({required this.filter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String title;
    String description;
    List<String> criteria;

    switch (filter) {
      case 'strict':
        title = 'Strict Filtering';
        description = 'Highest quality, may find fewer matches';
        criteria = [
          'Official music videos only',
          'VEVO and Topic channels',
          'No covers or remixes',
          'No live performances',
        ];
        break;
      case 'moderate':
        title = 'Moderate Filtering (Recommended)';
        description = 'Balanced quality and availability';
        criteria = [
          'Official and high-quality uploads',
          'Popular verified channels',
          'Covers from major artists',
          'Studio recordings preferred',
        ];
        break;
      case 'permissive':
        title = 'Permissive Filtering';
        description = 'Maximum availability, varied quality';
        criteria = [
          'All music content',
          'Covers and remixes allowed',
          'Live performances included',
          'User uploads accepted',
        ];
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          ...criteria.map((criterion) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        criterion,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
