import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:subtracks/l10n/app_localizations.dart';

import '../../services/settings_service.dart';
import '../app_router.dart';

class SetupPage extends HookConsumerWidget {
  const SetupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(settingsServiceProvider.select((v) => v.activeSource),
        (previous, next) {
      if (next != null) {
        context.router.replaceAll([const RootRouter()]);
      }
    });

    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.music_note_rounded,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 32),
                Text(
                  'Welcome to Subtracks',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'To get started, please connect to your Subsonic-compatible server.',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                FilledButton.icon(
                  onPressed: () {
                    context.router.push(const SetupSourceRoute());
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l.settingsServersActionsAdd),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
