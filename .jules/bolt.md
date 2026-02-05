## 2024-05-24 - Unnecessary Rebuilds from Pre-fetching
**Learning:** Using `ref.watch` for side-effects (like pre-fetching data) inside `build` causes unnecessary rebuilds when the async operation completes, even if the data isn't used in the widget.
**Action:** Use `ref.listen(provider, (_, __) {})` to keep the provider alive and trigger the fetch without causing the widget to rebuild.
