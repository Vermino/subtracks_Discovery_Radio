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
        home: const Scaffold(
          body: ShuffleFab(),
        ),
      ),
    );

    final fabFinder = find.byType(FloatingActionButton);
    expect(fabFinder, findsOneWidget);

    final tooltip = tester.widget<FloatingActionButton>(fabFinder).tooltip;
    expect(tooltip, 'Shuffle');
  });

  testWidgets('RadioPlayFab has correct tooltip', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: RadioPlayFab(),
        ),
      ),
    );

    final fabFinder = find.byType(FloatingActionButton);
    expect(fabFinder, findsOneWidget);

    final tooltip = tester.widget<FloatingActionButton>(fabFinder).tooltip;
    expect(tooltip, 'Start Radio');
  });

  testWidgets('DiscoveryRadioFab has correct tooltip', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: DiscoveryRadioFab(),
        ),
      ),
    );

    final fabFinder = find.byType(FloatingActionButton);
    expect(fabFinder, findsOneWidget);

    final tooltip = tester.widget<FloatingActionButton>(fabFinder).tooltip;
    expect(tooltip, 'Discovery Radio');
  });
}
