## 2024-05-22 - Icon-Only Buttons Missing Tooltips
**Learning:** Many icon-only buttons (FloatingActionButtons, IconButtons) in the app lack `tooltip` properties or semantic labels. This makes them inaccessible to screen readers and confusing for users who rely on hover text.
**Action:** Always check `tooltip` property when using `IconButton` or `FloatingActionButton`. If missing, add a localized string.
