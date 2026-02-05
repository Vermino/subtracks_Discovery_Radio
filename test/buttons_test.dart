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

    await tester.pumpAndSettle();

    // Verify ShuffleFab tooltip
    expect(find.byTooltip('Shuffle'), findsOneWidget);

    // Verify RadioPlayFab tooltip
    expect(find.byTooltip('Play radio'), findsOneWidget);

    // Verify DiscoveryRadioFab tooltip
    expect(find.byTooltip('Discovery Radio'), findsOneWidget);
  });
}
