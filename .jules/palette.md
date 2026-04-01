## 2024-05-22 - Missing Accessibility Labels on Core Interactive Elements
**Learning:** The "Now Playing" screen and list items consistently lacked accessibility labels. Specifically, `IconButton`s were missing `tooltip`s (which provide accessibility labels), and status `Icon`s (like "Now Playing" or "Downloaded") were missing `semanticLabel`s, making them invisible to screen readers.
**Action:** When creating new `IconButton`s, always provide a `tooltip`. For purely visual status icons that convey meaning, always provide a `semanticLabel`.
