# Phase 3 UI: Visual Mockups

## User Experience Flow

### Scenario 1: Thumbs Up with Immediate Download

```
┌────────────────────────────────────────────────┐
│  🎵 Now Playing                                │
│                                                │
│  Song Title                                    │
│  Artist Name                              [▶]  │
│                                                │
│  [👍] [👎]  ← User clicks thumbs up           │
│                                                │
│  ╔════════════════════════════════════╗        │
│  ║  ✓  Downloading...                 ║        │
│  ╚════════════════════════════════════╝        │
│       ↑ Floating SnackBar (2 seconds)          │
└────────────────────────────────────────────────┘

Timeline:
0s   - User taps 👍 button
0.1s - Button turns blue (primary color)
0.2s - SnackBar appears at bottom
2.2s - SnackBar fades out
```

### Scenario 2: Thumbs Up with WiFi Queue

```
┌────────────────────────────────────────────────┐
│  🎵 Now Playing                                │
│                                                │
│  Song Title                                    │
│  Artist Name                        [📶 4G]    │
│                                                │
│  [👍] [👎]  ← User clicks thumbs up           │
│                                                │
│  ╔════════════════════════════════════╗        │
│  ║  📥  Download queued for WiFi      ║        │
│  ╚════════════════════════════════════╝        │
│       ↑ Floating SnackBar (2 seconds)          │
└────────────────────────────────────────────────┘

Context:
- User is on mobile network (4G/5G)
- Download preference set to "WiFi only"
- Song will download when WiFi is available
```

### Scenario 3: Thumbs Down with Auto-Delete

```
┌────────────────────────────────────────────────┐
│  🎵 Now Playing                                │
│                                                │
│  Song Title                                    │
│  Artist Name                        [📁 ✓]     │
│              ↑ Downloaded indicator            │
│                                                │
│  [👍] [👎]  ← User clicks thumbs down         │
│                                                │
│  ╔════════════════════════════════════╗        │
│  ║  🗑️  File deleted                  ║        │
│  ╚════════════════════════════════════╝        │
│       ↑ Floating SnackBar (2 seconds)          │
└────────────────────────────────────────────────┘

Result:
- Downloaded file is immediately removed
- [📁 ✓] indicator disappears
- Song can still be streamed
```

### Scenario 4: No Feedback (Already Downloaded)

```
┌────────────────────────────────────────────────┐
│  🎵 Now Playing                                │
│                                                │
│  Song Title                                    │
│  Artist Name                        [📁 ✓]     │
│              ↑ Already downloaded              │
│                                                │
│  [👍] [👎]  ← User clicks thumbs up           │
│                                                │
│  (No SnackBar appears)                         │
│       ↑ Auto-download not needed               │
└────────────────────────────────────────────────┘

Smart Logic:
- Song is already downloaded
- No need to download again
- No notification shown (avoid noise)
```

### Scenario 5: No Feedback (Feature Disabled)

```
┌────────────────────────────────────────────────┐
│  🎵 Now Playing                                │
│                                                │
│  Song Title                                    │
│  Artist Name                              [▶]  │
│                                                │
│  [👍] [👎]  ← User clicks thumbs up           │
│                                                │
│  (No SnackBar appears)                         │
│       ↑ Auto-download feature disabled         │
└────────────────────────────────────────────────┘

Settings Context:
⚙️ Settings > Downloads
☐ Auto-download thumbs up songs (disabled)
```

## SnackBar Visual Design

### Default SnackBar Style
```
╔════════════════════════════════════╗
║  [Icon]  Message text              ║
╚════════════════════════════════════╝

Properties:
- Floating (not full-width)
- Rounded corners
- Material Design 3 elevation
- 2-second duration
- Bottom-center position
- Dark/light theme adaptive
```

### Three SnackBar Variants

#### 1. Downloading (Immediate)
```
╔════════════════════════════════════╗
║  ⬇️  Downloading...                 ║
╚════════════════════════════════════╝

Color: Neutral/Info (blue accent)
Icon: Download arrow
Duration: 2 seconds
```

#### 2. Download Queued (WiFi Wait)
```
╔════════════════════════════════════╗
║  📥  Download queued for WiFi      ║
╚════════════════════════════════════╝

Color: Neutral/Info (blue accent)
Icon: Inbox/Queue icon
Duration: 2 seconds
```

#### 3. File Deleted (Thumbs Down)
```
╔════════════════════════════════════╗
║  🗑️  File deleted                  ║
╚════════════════════════════════════╝

Color: Neutral/Info (not error red)
Icon: Trash icon
Duration: 2 seconds
```

## User Flow Diagrams

### Thumbs Up Flow with Auto-Download

```
   User Action          UI Response         Backend Action
       │                    │                     │
       │ Tap 👍             │                     │
       ├───────────────────>│                     │
       │                    │ Turn button blue    │
       │                    │ (0.1s)              │
       │                    ├────────────────────>│
       │                    │                     │ Check settings
       │                    │                     │ Check if downloaded
       │                    │                     │ Check network
       │                    │<────────────────────┤
       │                    │ Show SnackBar       │ Start download
       │                    │ (0.2s)              │ (if conditions met)
       │                    │                     │
       │ [2 seconds pass]   │                     │
       │                    │ Hide SnackBar       │
       │                    │ (2.2s)              │
       │                    │                     │ Download continues
       │                    │                     │ in background
```

### Thumbs Down Flow with Auto-Delete

```
   User Action          UI Response         Backend Action
       │                    │                     │
       │ Tap 👎             │                     │
       ├───────────────────>│                     │
       │                    │ Turn button red     │
       │                    │ (0.1s)              │
       │                    ├────────────────────>│
       │                    │                     │ Check settings
       │                    │                     │ Check if downloaded
       │                    │<────────────────────┤
       │                    │ Show SnackBar       │ Delete file
       │                    │ (0.2s)              │ (instant)
       │                    │                     │
       │                    │ Remove download     │ Update database
       │                    │ indicator           │
       │                    │                     │
       │ [2 seconds pass]   │                     │
       │                    │ Hide SnackBar       │
       │                    │ (2.2s)              │
```

## Accessibility Considerations

### Screen Reader Announcements
```
Thumbs Up (with auto-download):
"Liked. Downloading song."

Thumbs Up (queued):
"Liked. Download queued for WiFi."

Thumbs Down (with delete):
"Disliked. Downloaded file deleted."

Thumbs Up (already downloaded):
"Liked." (no download announcement)
```

### Semantic Labels
- SnackBars use `Semantics` widget for screen reader support
- Messages are concise and descriptive
- Icons complement text (not replace it)

## Responsive Design

### Mobile (Portrait)
```
┌──────────────────┐
│                  │
│   [👍] [👎]      │
│                  │
│  ╔═══════════╗   │
│  ║ Message   ║   │
│  ╚═══════════╝   │
│        ↑         │
│    Bottom 16px   │
└──────────────────┘
```

### Tablet/Desktop
```
┌────────────────────────────────┐
│                                │
│         [👍] [👎]              │
│                                │
│        ╔═══════════╗           │
│        ║ Message   ║           │
│        ╚═══════════╝           │
│              ↑                 │
│        Bottom-center           │
└────────────────────────────────┘
```

### Dark Mode
```
Light Mode:
╔════════════════════════════════════╗
║  ⬇️  Downloading...                 ║  ← White/light gray bg
╚════════════════════════════════════╝     Black text

Dark Mode:
╔════════════════════════════════════╗
║  ⬇️  Downloading...                 ║  ← Dark gray bg
╚════════════════════════════════════╝     White text
```

## Animation Timing

```
Timeline of SnackBar Appearance:

0ms    ────────────────────────────────  (Hidden)
                ↓ Fade & slide in
200ms  ╔════════════════════════╗        (Fully visible)
       ║  Message               ║
       ╚════════════════════════╝
                ↓ Hold
2000ms ╔════════════════════════╗        (Still visible)
       ║  Message               ║
       ╚════════════════════════╝
                ↓ Fade & slide out
2200ms ────────────────────────────────  (Hidden)

Total Duration: 2.2 seconds
- Fade in: 200ms (Material Design standard)
- Hold: 2000ms (user-defined duration)
- Fade out: 200ms (automatic)
```

## Edge Cases Handled

### 1. Multiple Rapid Taps
```
User rapidly taps 👍 👎 👍 👎

Result:
- Only latest SnackBar shows
- Previous SnackBars are dismissed
- No queue of 4 SnackBars
```

### 2. Rating While SnackBar Visible
```
SnackBar "Downloading..." is showing
User taps 👎 to undo thumbs up

Result:
- Previous SnackBar dismissed
- New SnackBar shows if applicable
- Clean transition
```

### 3. Context Loss During Async
```
User rates song
Navigates away before SnackBar shows

Result:
- context.mounted check prevents crash
- No SnackBar shown (user left screen)
- Backend action still completes
```

## Comparison with Existing Patterns

### Lidarr Download Notifications
```
Current Lidarr SnackBar:
╔═══════════════════════════════════════════╗
║  Added Artist Name to Lidarr for download ║
╚═══════════════════════════════════════════╝
Duration: 3 seconds

New Auto-Download SnackBar:
╔════════════════════════════════════╗
║  ⬇️  Downloading...                 ║
╚════════════════════════════════════╝
Duration: 2 seconds

Difference:
- Shorter (2s vs 3s) - less critical info
- Simpler message - user initiated action
- Consistent floating style
```

## Conclusion

The UI feedback is:
✅ **Visible** - Users clearly see confirmation
✅ **Brief** - 2 seconds prevents annoyance
✅ **Smart** - Only shows when relevant
✅ **Consistent** - Matches app patterns
✅ **Accessible** - Screen reader friendly
✅ **Responsive** - Works on all screen sizes
