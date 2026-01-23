## 2024-05-22 - [Anti-Pattern] Eager ref.watch in List Items
**Learning:** Using `ref.watch` inside a list item's `build` method solely to pre-fetch data for a subsequent view is a major performance bottleneck. It forces the list item to rebuild when the async operation completes, causing jank during scrolling.
**Action:** Defer data loading to the destination view (lazy loading) or trigger pre-fetching in event handlers (e.g., `onTap` or `onLongPress`) rather than in the `build` cycle.
