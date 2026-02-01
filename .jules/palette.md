## 2024-10-24 - Dynamic State Accessibility
**Learning:** Interactive elements with multiple states (like Play/Pause) often lack dynamic semantic labels, leaving screen reader users guessing the current action. A static label like "Play/Pause" is insufficient.
**Action:** For multi-state buttons, ensure the tooltip or aria-label updates dynamically to reflect the *action that will be performed* (e.g., "Pause" when playing, "Play" when paused), not just the current state.
