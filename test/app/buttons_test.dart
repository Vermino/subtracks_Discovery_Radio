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

    await tester.pumpAndSettle();

    final fabFinder = find.byType(FloatingActionButton);
    expect(fabFinder, findsOneWidget);

    final fab = tester.widget<FloatingActionButton>(fabFinder);
    expect(fab.tooltip, 'Shuffle');
  });
}
