import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracks/app/buttons.dart';
import 'package:subtracks/l10n/app_localizations.dart';

void main() {
  testWidgets('ShuffleFab has correct tooltip', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ShuffleFab(onPressed: () {}),
        ),
      ),
    );

    // Initial state: tooltip is "Cancel" (which is wrong), we want "Shuffle"
    // So if we assert "Shuffle", it should fail before fix.
    final finder = find.byTooltip('Shuffle');
    expect(finder, findsOneWidget);
  });

  testWidgets('RadioPlayFab has correct tooltip', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: RadioPlayFab(onPressed: () {}),
        ),
      ),
    );

    // Initial state: no tooltip. We want "Play radio".
    final finder = find.byTooltip('Play radio');
    expect(finder, findsOneWidget);
  });
}
