import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracks/app/buttons.dart';
import 'package:subtracks/l10n/app_localizations.dart';

void main() {
  testWidgets('Buttons have correct tooltips', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Column(
            children: [
              ShuffleFab(onPressed: () {}),
              RadioPlayFab(onPressed: () {}),
              DiscoveryRadioFab(onPressed: () {}),
            ],
          ),
        ),
      ),
    );

    // Verify ShuffleFab tooltip
    final shuffleFinder = find.byType(ShuffleFab);
    expect(shuffleFinder, findsOneWidget);
    final shuffleFab = tester.widget<FloatingActionButton>(
      find.descendant(
          of: shuffleFinder, matching: find.byType(FloatingActionButton)),
    );
    expect(shuffleFab.tooltip, 'Shuffle');

    // Verify RadioPlayFab tooltip
    final radioFinder = find.byType(RadioPlayFab);
    expect(radioFinder, findsOneWidget);
    final radioFab = tester.widget<FloatingActionButton>(
      find.descendant(
          of: radioFinder, matching: find.byType(FloatingActionButton)),
    );
    expect(radioFab.tooltip, 'Radio');

    // Verify DiscoveryRadioFab tooltip
    final discoveryFinder = find.byType(DiscoveryRadioFab);
    expect(discoveryFinder, findsOneWidget);
    final discoveryFab = tester.widget<FloatingActionButton>(
      find.descendant(
          of: discoveryFinder, matching: find.byType(FloatingActionButton)),
    );
    expect(discoveryFab.tooltip, 'Discovery Radio');
  });
}
