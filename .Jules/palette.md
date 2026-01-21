## 2024-05-23 - Accessibility in Now Playing
**Learning:** Flutter's `IconButton` provides a `tooltip` property which is crucial for accessibility, especially for icon-only buttons like playback controls. Screen readers rely on this to describe the action.
**Action:** Always verify that icon-only buttons have a meaningful `tooltip` or `semanticLabel` set.

## 2024-05-23 - Hardcoded Strings
**Learning:** The project uses `arb` files for localization, but regenerating the `app_localizations.dart` file is not possible in this environment.
**Action:** Use hardcoded strings for new UI elements temporarily, but try to reuse existing keys if possible. In this case, I will use hardcoded English strings for the tooltips as specific playback control strings are missing in `app_en.arb`.
