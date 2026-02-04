## 2024-05-23 - Missing Tooltips on Icon Buttons
**Learning:** Many `IconButton` and FAB widgets (like `ShuffleFab`, `RepeatButton`) lacked `tooltip` properties or used incorrect localized strings (e.g., "Cancel" for "Shuffle").
**Action:** Systematically audit `IconButton` usage in `lib/app/buttons.dart` and page files (`lib/app/pages/`) to ensure every icon-only button has a descriptive, localized `tooltip`.
