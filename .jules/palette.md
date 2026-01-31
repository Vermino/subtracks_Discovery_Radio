## 2026-01-31 - Misleading Tooltips and Missing Accessibility Labels
**Learning:** Found a Shuffle button labeled "Cancel" via tooltip. This pattern of copy-paste errors in accessibility labels is critical to catch. Also noted missing tooltips on player controls.
**Action:** Audit all `IconButton` and `FloatingActionButton` usages for correct `tooltip` mapping, ensuring the localized string matches the icon's function, not just a generic action.
