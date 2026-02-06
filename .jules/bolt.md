# Bolt's Journal ⚡

## 2024-05-23 - Eager Palette Calculation
**Learning:** `ref.watch` in a `build` method triggers a rebuild when the provider updates, even if the result is ignored. Using this for "pre-fetching" data (like image palettes) in list items (`AlbumCard`, `AlbumArt`) causes massive unnecessary work and rebuilds during scrolling.
**Action:** Avoid side-effect `ref.watch` for pre-fetching in UI components. Use proper lazy loading or `useEffect` if absolutely necessary, but prefer letting the destination view request the data.
