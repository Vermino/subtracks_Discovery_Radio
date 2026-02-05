## 2024-10-24 - Localization Fallback Strategy
**Learning:** When `gen-l10n` is unavailable, adding new localized strings requires adding concrete getters with English defaults to the abstract `AppLocalizations` class. This prevents build errors in non-English subclasses that extend it.
**Action:** Always provide default implementations in `AppLocalizations` when manually modifying localization files in this environment.

## 2024-10-24 - Verify Tooltip Mappings
**Learning:** `ShuffleFab` was using "Cancel" as a tooltip due to incorrect variable usage (`l.actionsCancel`).
**Action:** Always manually verify tooltip text in the UI or code, especially when copying existing patterns.
