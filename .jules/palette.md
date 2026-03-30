## 2026-01-26 - Manual Localization Updates
**Learning:** This environment lacks the `flutter_gen` tools, so adding localized strings requires a specific manual process: 1) Add to `.arb`, 2) Add concrete getter with default value to `AppLocalizations` abstract class (to avoid updating all 19 language files), 3) Override in `AppLocalizationsEn`.
**Action:** Use concrete getters in the abstract class for new strings to minimize file churn when generation is unavailable.

## 2026-01-26 - FloatingActionButton Accessibility
**Learning:** The app relies heavily on `tooltip` for FAB accessibility. Missing tooltips (like on the Radio FAB) create completely inaccessible controls for screen reader users.
**Action:** Always verify `tooltip` presence on FABs, especially those with complex icon stacks.
