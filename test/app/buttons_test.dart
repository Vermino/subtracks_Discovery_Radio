import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracks/app/buttons.dart';
import 'package:subtracks/l10n/app_localizations.dart';

void main() {
  testWidgets('ShuffleFab has correct tooltip', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ShuffleFab(),
        ),
      ),
    );

    // Wait for localizations to load if necessary
    await tester.pumpAndSettle();

    final fabFinder = find.byType(ShuffleFab);
    expect(fabFinder, findsOneWidget);

    final fab = tester.widget<FloatingActionButton>(
      find.descendant(
        of: fabFinder,
        matching: find.byType(FloatingActionButton),
      ),
    );

    // This checks for the correct behavior we want
    expect(fab.tooltip, 'Shuffle');
  });
}
