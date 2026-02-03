## 2024-05-22 - Eager Provider Watching in Lists
**Learning:** `AlbumCard`, `PlaylistListTile` and `AlbumArt` were eagerly watching palette providers in their `build` methods using `ref.watch` without using the return value. This caused unnecessary palette generation (expensive computation) and widget rebuilds during scrolling for every item, leading to performance degradation.
**Action:** Remove unused `ref.watch` calls in list item widgets. Ensure heavy computations (like palette generation) are triggered on-demand (e.g., on navigation) or lazily, rather than eagerly in `build`.
