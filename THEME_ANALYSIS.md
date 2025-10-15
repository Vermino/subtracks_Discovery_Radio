# Subtracks Theme System - Complete Analysis & Design Document

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [Current Theme Architecture](#current-theme-architecture)
3. [Color Scheme Implementation](#color-scheme-implementation)
4. [Dynamic Color Generation](#dynamic-color-generation)
5. [Theme Application Throughout App](#theme-application-throughout-app)
6. [Proposed Theme Presets](#proposed-theme-presets)
7. [Implementation Plan](#implementation-plan)
8. [File Reference](#file-reference)

---

## Executive Summary

Subtracks uses a **dynamic color theming system** powered by Material 3 that extracts colors from album artwork in real-time. The app currently uses **deep purple (`#6A1B9A`)** as the base seed color and operates in **dark mode only**.

### Key Characteristics
- ✅ Dynamic theme generation from album art palettes
- ✅ Material 3 design system with modern color schemes
- ✅ Sophisticated gradient backgrounds
- ✅ Custom surface colors at multiple darkness levels
- ❌ No user-selectable theme presets
- ❌ No light mode support
- ❌ No theme settings in UI

### Proposed Enhancement
Add a **Theme Preset Selector** in Settings allowing users to choose between:
- **Subtracks Default** (current purple)
- **Spotify Inspired** (vibrant green)
- **Pandora Inspired** (deep blue)
- **YouTube Music** (rich red)
- **Classic Dark** (neutral gray)
- **Ocean Wave** (teal/cyan)
- **Sunset** (warm orange)
- **Forest** (natural green)

Each preset maintains the beautiful dynamic album art theming while providing different base color palettes.

---

## Current Theme Architecture

### Core Files

| File | Lines | Purpose |
|------|-------|---------|
| `lib/state/theme.dart` | 261 | Core theme providers, palette generation, color ranking |
| `lib/state/theme.g.dart` | Auto | Generated Riverpod code |
| `lib/models/support.dart` | 189 | ColorTheme & Palette data models |
| `lib/app/app.dart` | 86 | Root app theme application |
| `lib/app/gradient.dart` | 77 | Reusable gradient background widgets |

### Theme Constants

Located in `lib/state/theme.dart:18-20`:

```dart
const kDarkBackgroundValue = 0.28;        // HSV value for dark surfaces
const kDarkerBackgroundLightness = 0.13;  // HSL lightness for darkest surfaces
const kOnDarkerBackgroundLightness = 0.6; // Text color on darkest surfaces
```

These constants control surface darkness variations throughout the app.

### ColorTheme Model

Defined in `lib/models/support.dart:54-64`:

```dart
@freezed
class ColorTheme with _$ColorTheme {
  const factory ColorTheme({
    required ThemeData theme,           // Standard Flutter theme
    required Color gradientHigh,        // Top of background gradients
    required Color gradientLow,         // Bottom of background gradients
    required Color darkBackground,      // Dark surface color
    required Color darkerBackground,    // Darkest surface color
    required Color onDarkerBackground,  // Text on darkest surfaces
  }) = _ColorTheme;
}
```

**Custom Properties Explained:**
- `gradientHigh` - Used at top of screen backgrounds (lighter)
- `gradientLow` - Used at bottom of screen backgrounds (darker, lightness: 0.06)
- `darkBackground` - Used for cards, mini player, elevated surfaces
- `darkerBackground` - Used for progress bars, very dark elements
- `onDarkerBackground` - Text/icons that appear on darkest surfaces

---

## Color Scheme Implementation

### Base Theme Provider

Location: `lib/state/theme.dart:120-147`

```dart
@riverpod
ColorTheme baseTheme(BaseThemeRef ref) {
  final theme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.purple[800],  // 🎨 BASE SEED COLOR
    brightness: Brightness.dark,          // Always dark mode
    cardTheme: CardThemeData(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),  // Subtle rounding
      ),
    ),
  );

  final hsv = HSVColor.fromColor(theme.colorScheme.surface);
  final hsl = HSLColor.fromColor(theme.colorScheme.surface);

  return ColorTheme(
    theme: theme,
    gradientHigh: theme.colorScheme.surface,
    gradientLow: HSLColor.fromColor(theme.colorScheme.surface)
        .withLightness(0.06)
        .toColor(),
    darkBackground: hsv.withValue(kDarkBackgroundValue).toColor(),
    darkerBackground: hsl.withLightness(kDarkerBackgroundLightness).toColor(),
    onDarkerBackground: hsl.withLightness(kOnDarkerBackgroundLightness).toColor(),
  );
}
```

**Key Settings:**
- **Seed Color:** `Colors.purple[800]` = `#6A1B9A`
- **Material 3:** Enabled (modern color system)
- **Brightness:** Always dark
- **Card Radius:** 2px (very subtle)

### How Material 3 Color Generation Works

Material 3's `ColorScheme.fromSeed()` generates a complete color palette from a single seed color:

```
Seed Color → Tonal Palette → ColorScheme Roles
   #6A1B9A  →  (40+ tones)  →  primary, secondary, tertiary,
                                surface, error, etc.
```

**Generated Roles:**
- `primary` - Main brand color
- `primaryContainer` - Highlighted containers
- `secondary` - Supporting accents
- `secondaryContainer` - Alternate highlights
- `tertiary` - Additional accent
- `surface` - Background surfaces
- `surfaceTint` - Elevation tinting
- `error` - Error states
- Plus "on" variants for text/icons on each color

---

## Dynamic Color Generation

### Palette Extraction from Album Art

Location: `lib/state/theme.dart:150-197`

**Process Flow:**

```
1. Album Art URL
   ↓
2. Cache thumbnail (32x32 pixels for performance)
   ↓
3. Load image into memory
   ↓
4. Background worker extracts palette
   ↓
5. Generate 7 color types:
   - Vibrant
   - Dark Vibrant
   - Light Vibrant
   - Muted
   - Dark Muted
   - Light Muted
   - Dominant
   ↓
6. Rank colors by luminance/value
   ↓
7. Generate ColorScheme with selected colors
```

### Color Ranking Algorithm

Location: `lib/state/theme.dart:22-54`

**Two Ranking Functions:**

1. **`_rankedByLuminance(colors, minLuminance, maxLuminance)`**
   - Filters colors by luminance range (0.0 to 1.0)
   - Returns first color within range
   - Used for primary, vibrant, secondary colors

2. **`_rankedWithValue(value, colors)`**
   - Filters colors by HSV value threshold
   - Returns first color above threshold
   - Used for background color selection

### Dynamic Theme Generation

Location: `lib/state/theme.dart:56-117`

```dart
@riverpod
ColorTheme _colorTheme(_ColorThemeRef ref, Palette palette) {
  final base = ref.watch(baseThemeProvider);

  // Select colors from palette with fallback priorities
  final primary = _rankedByLuminance([
    palette.dominantColor,    // Most common color
    palette.vibrantColor,     // Brightest saturated
    palette.mutedColor,       // Desaturated
    palette.darkVibrantColor, // Dark & saturated
  ], 0.2);  // Min luminance 0.2 (not too dark)

  final vibrant = _rankedByLuminance([
    palette.vibrantColor,
    palette.darkVibrantColor,
    palette.dominantColor,
  ], 0.05);  // Very permissive (can be quite dark)

  final secondary = _rankedByLuminance([
    palette.lightMutedColor,  // Light desaturated
    palette.mutedColor,
    palette.darkMutedColor,
  ]);

  final background = _rankedWithValue(0.5, [
    palette.vibrantColor,
    palette.darkVibrantColor,
    palette.darkMutedColor,
    palette.dominantColor,
    palette.mutedColor,
    palette.lightVibrantColor,
    palette.lightMutedColor,
  ]);

  final colorScheme = ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: background?.color ?? Colors.purple[800]!,  // Fallback
    primaryContainer: primary?.color,
    onPrimaryContainer: primary?.bodyTextColor,
    secondaryContainer: secondary?.color,
    onSecondaryContainer: secondary?.bodyTextColor,
    surface: background?.color,
    surfaceTint: vibrant?.color,
    // Ensure good contrast in dark mode
    onSurface: Colors.white.withOpacity(0.87),
    onBackground: Colors.white.withOpacity(0.87),
  );

  final hsv = HSVColor.fromColor(colorScheme.surface);
  final hsl = HSLColor.fromColor(colorScheme.surface);

  return base.copyWith(
    theme: ThemeData(
      colorScheme: colorScheme,
      useMaterial3: base.theme.useMaterial3,
      brightness: base.theme.brightness,
      cardTheme: base.theme.cardTheme,
    ),
    gradientHigh: colorScheme.surface,
    darkBackground: hsv.withValue(kDarkBackgroundValue).toColor(),
    darkerBackground: hsl.withLightness(kDarkerBackgroundLightness).toColor(),
    onDarkerBackground: hsl.withLightness(kOnDarkerBackgroundLightness).toColor(),
  );
}
```

**Color Selection Priority:**
- Primary: Dominant → Vibrant → Muted → Dark Vibrant
- Vibrant: Vibrant → Dark Vibrant → Dominant
- Secondary: Light Muted → Muted → Dark Muted
- Background: Vibrant → Dark Vibrant → Dark Muted → Dominant → others

### Theme Providers

**Static Base Theme:**
```dart
@riverpod
ColorTheme baseTheme(BaseThemeRef ref)
```
- Used globally in MaterialApp
- Purple base color
- Falls back when no album art available

**Dynamic Themes (context-specific):**

```dart
@riverpod
FutureOr<ColorTheme> mediaItemTheme(MediaItemThemeRef ref)
```
- Currently playing track theme
- Updates when track changes
- Used in Now Playing page & mini player

```dart
@riverpod
FutureOr<ColorTheme> albumArtTheme(AlbumArtThemeRef ref, String id)
```
- Album-specific theme
- Used in album detail pages

```dart
@riverpod
FutureOr<ColorTheme> playlistArtTheme(PlaylistArtThemeRef ref, String id)
```
- Playlist-specific theme
- Used in playlist detail pages

---

## Theme Application Throughout App

### Root Application

**File:** `lib/app/app.dart:68-84`

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final appRouter = ref.watch(routerProvider);
  final base = ref.watch(baseThemeProvider);

  return MaterialApp.router(
    theme: base.theme,  // 🎨 Base theme applied globally
    debugShowCheckedModeBanner: false,
    routerConfig: appRouter,
  );
}
```

### Now Playing Page (Dynamic Theme)

**File:** `lib/app/pages/now_playing_page.dart:32-105`

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final colors = ref.watch(mediaItemThemeProvider).valueOrNull;

  final scaffold = AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light.copyWith(
      systemNavigationBarColor: colors?.gradientLow,  // Dynamic nav bar
      statusBarColor: Colors.transparent,
    ),
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MediaItemGradient(),  // Dynamic gradient background
          // ... content
        ],
      ),
    ),
  );

  // Wrap with dynamic theme if available
  if (colors != null) {
    return Theme(data: colors.theme, child: scaffold);
  }
  return scaffold;
}
```

**Theme Usage:**
- System navigation bar color: `colors.gradientLow`
- Background: `MediaItemGradient()` widget
- Slider track: `colors.theme.colorScheme.surface`
- Control buttons: `base.theme.colorScheme.surface`

### Now Playing Bar (Mini Player)

**File:** `lib/app/now_playing_bar.dart:20-72`

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final colors = ref.watch(mediaItemThemeProvider).valueOrNull;

  final widget = GestureDetector(
    onTap: () => context.pushNamed('nowPlaying'),
    child: Material(
      elevation: 3,
      color: colors?.darkBackground,  // Dynamic dark surface
      child: Column(
        children: [
          // Progress bar
          Container(
            height: 4,
            color: colors?.darkerBackground,  // Track color
            child: Row(
              children: [
                Flexible(
                  flex: position,
                  child: Container(
                    color: colors?.onDarkerBackground,  // Progress color
                  ),
                ),
                // ...
              ],
            ),
          ),
          // ... track info & controls
        ],
      ),
    ),
  );

  if (colors != null) {
    return Theme(data: colors.theme, child: widget);
  }
  return widget;
}
```

### Background Gradient Widgets

**File:** `lib/app/gradient.dart:47-76`

```dart
class BackgroundGradient extends HookConsumerWidget {
  final ColorTheme? colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final base = ref.watch(baseThemeProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors?.gradientHigh ?? base.gradientHigh,
            colors?.gradientLow ?? base.gradientLow,
          ],
        ),
      ),
    );
  }
}
```

**Specialized Gradient Widgets:**
- `MediaItemGradient()` - For now playing page
- `AlbumArtGradient(id)` - For album pages
- `PlaylistArtGradient(id)` - For playlist pages

All use album art colors when available, fallback to base theme.

### Hardcoded Colors in Codebase

**YouTube Badge:**
- File: `lib/app/widgets/youtube_badge.dart:68`
- Color: `Colors.red.shade700` (dark) / `Colors.red.shade600` (light)
- Purpose: YouTube branding consistency

**Status Indicators:**
- File: `lib/app/widgets/youtube_badge.dart:221-237`
- Colors: Green (streaming), Blue (loading), Orange (buffering), Red (error)

**Error States:**
- File: `lib/app/app.dart:25`
- Color: `Colors.red[900]`
- Purpose: Critical error screen

**Artist Names:**
- File: `lib/app/pages/artist_page.dart:115-136`
- Color: `Colors.white` with `Colors.black26` shadow
- Purpose: Ensure readability over varied backgrounds

**Common Opacity Values:**
- `0.87` - Primary text on dark backgrounds (Material standard)
- `0.7` - Secondary text
- `0.6` - De-emphasized text
- `0.3` - Disabled/placeholder state
- `0.15` - Badge backgrounds
- `0.12` - Very subtle backgrounds

---

## Proposed Theme Presets

### Design Philosophy

Each preset maintains:
- ✅ Dynamic album art color extraction
- ✅ Material 3 color system
- ✅ Dark mode aesthetic
- ✅ Gradient backgrounds
- ✅ Consistent UI patterns

Customization per preset:
- 🎨 Base seed color
- 🎨 Optional: Enable/disable dynamic colors
- 🎨 Optional: Preset-specific overrides

### Preset Definitions

#### 1. Subtracks Default (Current)

**Seed Color:** `#6A1B9A` (Purple 800)

**Characteristics:**
- Rich, regal purple tones
- Original app identity
- Good contrast in dark mode
- Neutral enough to blend with most album art

**Material Palette:**
- Primary: Deep purple
- Secondary: Light purple/mauve
- Surface: Dark purple-gray

**Use Case:** Default experience, familiar to existing users

---

#### 2. Spotify Inspired

**Seed Color:** `#1DB954` (Spotify Green)

**Characteristics:**
- Vibrant, energetic green
- High saturation for modern feel
- Excellent contrast on dark backgrounds
- Distinctive brand recognition

**Material Palette:**
- Primary: Bright green
- Secondary: Yellow-green
- Surface: Dark green-gray

**Use Case:** Users who want a bold, fresh aesthetic

**Implementation Note:**
```dart
ThemePreset.spotify: ThemePresetConfig(
  name: 'Spotify Inspired',
  seedColor: Color(0xFF1DB954),
  description: 'Vibrant green theme inspired by Spotify',
  enableDynamicColors: true,
),
```

---

#### 3. Pandora Inspired

**Seed Color:** `#005483` (Pandora Blue)

**Characteristics:**
- Deep, trustworthy blue
- Professional and calm
- Excellent readability
- Radio-focused aesthetic

**Material Palette:**
- Primary: Deep blue
- Secondary: Cyan/light blue
- Surface: Dark blue-gray

**Use Case:** Users preferring cooler, more subdued tones

**Implementation Note:**
```dart
ThemePreset.pandora: ThemePresetConfig(
  name: 'Pandora Inspired',
  seedColor: Color(0xFF005483),
  description: 'Classic blue theme inspired by Pandora',
  enableDynamicColors: true,
),
```

---

#### 4. YouTube Music

**Seed Color:** `#D32F2F` (Red 700)

**Characteristics:**
- Bold, attention-grabbing red
- Matches YouTube Music branding
- High energy aesthetic
- Works well with music content

**Material Palette:**
- Primary: Rich red
- Secondary: Pink/orange
- Surface: Dark red-gray

**Use Case:** Users who want a vibrant, media-focused theme

**Implementation Note:**
```dart
ThemePreset.youtube: ThemePresetConfig(
  name: 'YouTube Music',
  seedColor: Color(0xFFD32F2F),
  description: 'Bold red theme inspired by YouTube Music',
  enableDynamicColors: true,
),
```

---

#### 5. Classic Dark

**Seed Color:** `#424242` (Gray 800)

**Characteristics:**
- Pure neutral gray
- No color bias
- Maximum focus on content
- Album art colors stand out more

**Material Palette:**
- Primary: Medium gray
- Secondary: Light gray
- Surface: Dark gray

**Use Case:** Minimalists who want content-first design

**Implementation Note:**
```dart
ThemePreset.classic: ThemePresetConfig(
  name: 'Classic Dark',
  seedColor: Color(0xFF424242),
  description: 'Neutral gray theme for content focus',
  enableDynamicColors: true,
),
```

---

#### 6. Ocean Wave

**Seed Color:** `#00796B` (Teal 700)

**Characteristics:**
- Calming teal/cyan
- Natural, organic feel
- Good contrast
- Modern aesthetic

**Material Palette:**
- Primary: Deep teal
- Secondary: Cyan/turquoise
- Surface: Dark teal-gray

**Use Case:** Users wanting a calm, nature-inspired theme

**Implementation Note:**
```dart
ThemePreset.ocean: ThemePresetConfig(
  name: 'Ocean Wave',
  seedColor: Color(0xFF00796B),
  description: 'Calming teal theme inspired by the ocean',
  enableDynamicColors: true,
),
```

---

#### 7. Sunset

**Seed Color:** `#EF6C00` (Orange 800)

**Characteristics:**
- Warm, inviting orange
- High energy but not aggressive
- Unique aesthetic
- Great evening/night theme

**Material Palette:**
- Primary: Deep orange
- Secondary: Amber/yellow
- Surface: Dark orange-gray

**Use Case:** Users who want warmth without red's intensity

**Implementation Note:**
```dart
ThemePreset.sunset: ThemePresetConfig(
  name: 'Sunset',
  seedColor: Color(0xFFEF6C00),
  description: 'Warm orange theme inspired by sunset',
  enableDynamicColors: true,
),
```

---

#### 8. Forest

**Seed Color:** `#558B2F` (Light Green 800)

**Characteristics:**
- Natural green (not neon)
- Earthy, organic feel
- Easy on eyes
- Distinct from Spotify green

**Material Palette:**
- Primary: Forest green
- Secondary: Lime/olive
- Surface: Dark green-gray

**Use Case:** Users wanting natural tones without blue/purple

**Implementation Note:**
```dart
ThemePreset.forest: ThemePresetConfig(
  name: 'Forest',
  seedColor: Color(0xFF558B2F),
  description: 'Natural green theme inspired by forests',
  enableDynamicColors: true,
),
```

---

### Visual Comparison Table

| Preset | Seed Color | Hex Code | Vibe | Energy Level |
|--------|-----------|----------|------|--------------|
| Subtracks Default | Purple 800 | `#6A1B9A` | Regal, Original | Medium |
| Spotify Inspired | Spotify Green | `#1DB954` | Fresh, Modern | High |
| Pandora Inspired | Pandora Blue | `#005483` | Professional, Calm | Low |
| YouTube Music | Red 700 | `#D32F2F` | Bold, Energetic | High |
| Classic Dark | Gray 800 | `#424242` | Neutral, Minimal | Neutral |
| Ocean Wave | Teal 700 | `#00796B` | Calm, Natural | Low-Medium |
| Sunset | Orange 800 | `#EF6C00` | Warm, Inviting | Medium-High |
| Forest | Light Green 800 | `#558B2F` | Earthy, Organic | Medium |

---

## Implementation Plan

### Phase 1: Data Models & Persistence

#### 1.1 Database Schema Update

**File:** `lib/database/database.dart`

Add columns to `AppSettings` table:

```dart
class AppSettings extends Table {
  // ... existing columns

  TextColumn get themePreset =>
      text().withDefault(const Constant('subtracks'))();

  BoolColumn get enableDynamicColors =>
      boolean().withDefault(const Constant(true))();

  IntColumn get customSeedColor =>
      integer().nullable()();  // For future custom theme support
}
```

**Migration:**
```dart
@override
MigrationStrategy get migration {
  return MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(appSettings, appSettings.themePreset);
        await m.addColumn(appSettings, appSettings.enableDynamicColors);
        await m.addColumn(appSettings, appSettings.customSeedColor);
      }
    },
  );
}
```

#### 1.2 Settings Model Update

**File:** `lib/models/settings.dart`

Add fields to `AppSettings` model:

```dart
@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    // ... existing fields
    @Default('subtracks') String themePreset,
    @Default(true) bool enableDynamicColors,
    int? customSeedColor,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}
```

Run code generation:
```bash
dart run build_runner build --delete-conflicting-outputs
```

#### 1.3 Settings Service Update

**File:** `lib/services/settings_service.dart`

Add methods for theme management:

```dart
Future<void> setThemePreset(String preset) async {
  await _db.updateSettings(
    state.app.copyWith(themePreset: preset).toCompanion(),
  );
  await init();  // Reload settings
}

Future<void> setEnableDynamicColors(bool enabled) async {
  await _db.updateSettings(
    state.app.copyWith(enableDynamicColors: enabled).toCompanion(),
  );
  await init();
}

Future<void> setCustomSeedColor(int? color) async {
  await _db.updateSettings(
    state.app.copyWith(
      themePreset: 'custom',
      customSeedColor: color,
    ).toCompanion(),
  );
  await init();
}
```

---

### Phase 2: Theme System Enhancement

#### 2.1 Create Theme Preset Configuration

**File:** `lib/state/theme_presets.dart` (NEW)

```dart
import 'package:flutter/material.dart';

enum ThemePreset {
  subtracks,
  spotify,
  pandora,
  youtube,
  classic,
  ocean,
  sunset,
  forest,
  custom,
}

class ThemePresetConfig {
  final String name;
  final String description;
  final Color seedColor;
  final bool enableDynamicColors;
  final Map<String, dynamic>? customOverrides;

  const ThemePresetConfig({
    required this.name,
    required this.description,
    required this.seedColor,
    this.enableDynamicColors = true,
    this.customOverrides,
  });
}

const Map<String, ThemePresetConfig> themePresets = {
  'subtracks': ThemePresetConfig(
    name: 'Subtracks Default',
    description: 'Original purple theme',
    seedColor: Color(0xFF6A1B9A), // Colors.purple[800]
    enableDynamicColors: true,
  ),
  'spotify': ThemePresetConfig(
    name: 'Spotify Inspired',
    description: 'Vibrant green theme',
    seedColor: Color(0xFF1DB954),
    enableDynamicColors: true,
  ),
  'pandora': ThemePresetConfig(
    name: 'Pandora Inspired',
    description: 'Classic blue theme',
    seedColor: Color(0xFF005483),
    enableDynamicColors: true,
  ),
  'youtube': ThemePresetConfig(
    name: 'YouTube Music',
    description: 'Bold red theme',
    seedColor: Color(0xFFD32F2F), // Colors.red[700]
    enableDynamicColors: true,
  ),
  'classic': ThemePresetConfig(
    name: 'Classic Dark',
    description: 'Neutral gray theme',
    seedColor: Color(0xFF424242), // Colors.grey[800]
    enableDynamicColors: true,
  ),
  'ocean': ThemePresetConfig(
    name: 'Ocean Wave',
    description: 'Calming teal theme',
    seedColor: Color(0xFF00796B), // Colors.teal[700]
    enableDynamicColors: true,
  ),
  'sunset': ThemePresetConfig(
    name: 'Sunset',
    description: 'Warm orange theme',
    seedColor: Color(0xFFEF6C00), // Colors.orange[800]
    enableDynamicColors: true,
  ),
  'forest': ThemePresetConfig(
    name: 'Forest',
    description: 'Natural green theme',
    seedColor: Color(0xFF558B2F), // Colors.lightGreen[800]
    enableDynamicColors: true,
  ),
};

ThemePresetConfig getThemePreset(String presetKey) {
  return themePresets[presetKey] ?? themePresets['subtracks']!;
}

Color getPresetSeedColor(String presetKey, [int? customColor]) {
  if (presetKey == 'custom' && customColor != null) {
    return Color(customColor);
  }
  return getThemePreset(presetKey).seedColor;
}
```

#### 2.2 Update Base Theme Provider

**File:** `lib/state/theme.dart`

Modify `baseTheme` provider to use selected preset:

```dart
import 'theme_presets.dart';
import '../services/settings_service.dart';

@riverpod
ColorTheme baseTheme(BaseThemeRef ref) {
  final settings = ref.watch(settingsServiceProvider);
  final presetKey = settings.app.themePreset;
  final customColor = settings.app.customSeedColor;

  final seedColor = getPresetSeedColor(presetKey, customColor);

  final theme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seedColor,  // 🎨 Dynamic seed color
    brightness: Brightness.dark,
    cardTheme: CardThemeData(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );

  final hsv = HSVColor.fromColor(theme.colorScheme.surface);
  final hsl = HSLColor.fromColor(theme.colorScheme.surface);

  return ColorTheme(
    theme: theme,
    gradientHigh: theme.colorScheme.surface,
    gradientLow: HSLColor.fromColor(theme.colorScheme.surface)
        .withLightness(0.06)
        .toColor(),
    darkBackground: hsv.withValue(kDarkBackgroundValue).toColor(),
    darkerBackground: hsl.withLightness(kDarkerBackgroundLightness).toColor(),
    onDarkerBackground:
        hsl.withLightness(kOnDarkerBackgroundLightness).toColor(),
  );
}
```

#### 2.3 Respect Dynamic Colors Setting

**File:** `lib/state/theme.dart`

Modify `_colorTheme` to check if dynamic colors are enabled:

```dart
@riverpod
ColorTheme _colorTheme(_ColorThemeRef ref, Palette palette) {
  final base = ref.watch(baseThemeProvider);
  final settings = ref.watch(settingsServiceProvider);

  // If dynamic colors disabled, return static base theme
  if (!settings.app.enableDynamicColors) {
    return base;
  }

  // ... existing dynamic theme generation logic
}
```

---

### Phase 3: Settings UI

#### 3.1 Add Appearance Section to Settings

**File:** `lib/app/pages/settings_page.dart`

Add new section after Network or Discovery:

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Settings'),
    ),
    body: ListView(
      children: const [
        // ... existing sections (Servers, Network, Discovery)

        _SectionHeader('Appearance'),
        _Section(
          children: [
            _ThemePresetSelector(),
            _DynamicColorsToggle(),
          ],
        ),

        // ... About section
      ],
    ),
  );
}
```

#### 3.2 Theme Preset Selector Widget

**File:** `lib/app/pages/settings_page.dart` (add to same file)

```dart
class _ThemePresetSelector extends HookConsumerWidget {
  const _ThemePresetSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPreset = ref.watch(
      settingsServiceProvider.select((value) => value.app.themePreset),
    );
    final presetConfig = getThemePreset(currentPreset);

    return ListTile(
      leading: Icon(
        Icons.palette,
        color: presetConfig.seedColor,
      ),
      title: const Text('Theme'),
      subtitle: Text(presetConfig.name),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final value = await showDialog<String>(
          context: context,
          builder: (context) => _ThemePresetDialog(current: currentPreset),
        );

        if (value != null && value != currentPreset) {
          await ref
              .read(settingsServiceProvider.notifier)
              .setThemePreset(value);
        }
      },
    );
  }
}
```

#### 3.3 Theme Preset Dialog

```dart
class _ThemePresetDialog extends StatelessWidget {
  final String current;

  const _ThemePresetDialog({required this.current});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose Theme'),
      contentPadding: const EdgeInsets.only(top: 20),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: themePresets.entries.map((entry) {
            final key = entry.key;
            final config = entry.value;
            final isSelected = key == current;

            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: config.seedColor,
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(config.name),
              subtitle: Text(config.description),
              trailing: isSelected
                  ? Icon(Icons.check, color: config.seedColor)
                  : null,
              selected: isSelected,
              onTap: () => Navigator.of(context).pop(key),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
```

#### 3.4 Dynamic Colors Toggle

```dart
class _DynamicColorsToggle extends HookConsumerWidget {
  const _DynamicColorsToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(
      settingsServiceProvider.select(
        (value) => value.app.enableDynamicColors,
      ),
    );

    return SwitchListTile(
      secondary: const Icon(Icons.auto_awesome),
      title: const Text('Dynamic Colors'),
      subtitle: const Text('Generate colors from album artwork'),
      value: enabled,
      onChanged: (value) {
        ref
            .read(settingsServiceProvider.notifier)
            .setEnableDynamicColors(value);
      },
    );
  }
}
```

---

### Phase 4: Testing & Polish

#### 4.1 Test Checklist

- [ ] All 8 presets render correctly
- [ ] Theme changes apply immediately (no restart needed)
- [ ] Dynamic colors toggle works
- [ ] Album art extraction still works with each preset
- [ ] Now Playing page gradients look good
- [ ] Mini player colors are readable
- [ ] Settings persist across app restarts
- [ ] Database migration doesn't break existing installations
- [ ] All text has sufficient contrast (WCAG AA standard)
- [ ] Theme switching doesn't cause performance issues

#### 4.2 Edge Cases to Handle

**Missing Album Art:**
- Verify fallback to base theme works
- Ensure no flickering when loading

**Very Light/Dark Album Art:**
- Test with pure white/black album covers
- Verify text remains readable

**Performance:**
- Theme switching should be instant
- Palette generation already optimized (32x32, background workers)

**Persistence:**
- Settings should survive app updates
- Migration should handle null values gracefully

#### 4.3 Accessibility

**Contrast Ratios:**
- Verify all text meets WCAG AA (4.5:1 for normal text)
- Test with each preset's seed color
- Check progress bar visibility

**Color Blindness:**
- Test with color blindness simulators
- Ensure UI doesn't rely solely on color

#### 4.4 Polish Items

**Preview:**
- Add live preview when selecting theme (future enhancement)
- Show gradient sample in dialog

**Animations:**
- Smooth theme transitions (AnimatedTheme)
- Fade between color schemes

**Documentation:**
- Update user guide with theme selection
- Add screenshots of each preset

---

## File Reference

### Files to Modify

| Priority | File | Changes Required |
|----------|------|------------------|
| 🔴 Critical | `lib/database/database.dart` | Add theme columns, migration |
| 🔴 Critical | `lib/models/settings.dart` | Add theme fields to AppSettings |
| 🔴 Critical | `lib/services/settings_service.dart` | Add theme setter methods |
| 🔴 Critical | `lib/state/theme.dart` | Update baseTheme to use preset |
| 🟡 High | `lib/app/pages/settings_page.dart` | Add Appearance section |
| 🟢 Medium | Create `lib/state/theme_presets.dart` | Define preset configurations |

### Files to Test

| File | Test Focus |
|------|-----------|
| `lib/app/pages/now_playing_page.dart` | Dynamic theme rendering |
| `lib/app/now_playing_bar.dart` | Mini player colors |
| `lib/app/gradient.dart` | Gradient rendering |
| `lib/app/items.dart` | Card/list item theming |
| `lib/app/pages/artist_page.dart` | Text readability |
| `lib/app/widgets/youtube_badge.dart` | Badge contrast |

### Dependencies

**Current:**
```yaml
dependencies:
  palette_generator: ^0.3.3+2  # Color extraction
  riverpod_annotation: ^2.x.x  # State management
  drift: ^2.x.x                # Database
```

**No additional dependencies needed** for theme presets!

---

## Summary

### Current State
- ✅ Sophisticated dynamic theming from album art
- ✅ Material 3 design system
- ✅ Beautiful gradients and surface colors
- ❌ Fixed purple base color
- ❌ No user control over theme

### Proposed Enhancement
Add **8 theme presets** with user-selectable base colors:
1. Subtracks Default (Purple)
2. Spotify Inspired (Green)
3. Pandora Inspired (Blue)
4. YouTube Music (Red)
5. Classic Dark (Gray)
6. Ocean Wave (Teal)
7. Sunset (Orange)
8. Forest (Green)

### Benefits
- 🎨 User personalization
- 🎨 Brand variety (Spotify/Pandora fans)
- 🎨 Mood-based selection
- 🎨 Maintains dynamic album art theming
- 🎨 No performance impact
- 🎨 Simple implementation

### Implementation Complexity
**Effort:** Medium (2-3 days)
- Database schema: 1-2 hours
- Theme system: 3-4 hours
- Settings UI: 2-3 hours
- Testing: 4-6 hours
- Polish: 2-3 hours

**Risk:** Low
- Well-isolated changes
- Backward compatible
- Uses existing theme infrastructure
- No new dependencies

---

**Next Steps:**
1. Review this document and select desired presets
2. Implement Phase 1 (database & models)
3. Implement Phase 2 (theme system)
4. Implement Phase 3 (UI)
5. Test thoroughly with each preset
6. Ship it! 🚀
