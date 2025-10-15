# Flutter 3.35.6 Upgrade - Complete Guide

**Successfully upgraded from Flutter 3.24.5 to 3.35.6**

Both Windows and Android builds are working! ✅

---

## Quick Start - After Clearing Cache or Updating Packages

```bash
# Run these 3 commands in order:
flutter pub get
bash fix_namespaces.sh
flutter build apk --debug
```

**That's it!** The script now handles everything including Gradle cache cleaning.

---

## What Was Fixed

### 1. Android Gradle Configuration
- Gradle: 7.5 → 8.9
- Android Gradle Plugin: 7.2.0 → 8.7.3
- Kotlin: 2.0.21 → 2.1.0
- Java: 1.8 → 17
- Gradle Heap: 1536M → 4096M (prevents OOM errors)
- Jetifier: Disabled (all packages use AndroidX)

### 2. Localization System
- Removed deprecated `synthetic-package` feature
- Updated imports from `package:flutter_gen/*` to `package:subtracks/l10n/*`
- Files now in `lib/l10n/` instead of `.dart_tool/flutter_gen/`

### 3. Theme & Material Design 3
- Updated `CardTheme` → `CardThemeData`
- Added explicit `onSurface` and `onBackground` colors for better contrast
- Fixed dark media controls visibility

### 4. Namespace Declarations (The Critical Fix)
**Problem:** Android Gradle Plugin 8.x requires all libraries to declare a `namespace` in their `build.gradle`. Many Flutter packages don't include this.

**Solution:** The `fix_namespaces.sh` script automatically:
1. Scans all packages in pub cache
2. Extracts package names from AndroidManifest.xml
3. Adds `namespace 'package.name'` to build.gradle
4. Cleans Gradle cache to prevent stale builds

---

## The Complete Workflow

### After `flutter pub cache clean` or updating packages:

```bash
# Step 1: Download packages
flutter pub get

# Step 2: Fix namespaces and clean Gradle cache
bash fix_namespaces.sh

# Step 3: Build
flutter build apk --debug
```

### For Windows (no namespace fixes needed):
```bash
flutter pub get
flutter build windows --debug
```

---

## Why the Script is Necessary

The namespace fixes live in the **pub cache** (downloaded packages), not your source code. When you:
- Clear pub cache (`flutter pub cache clean`)
- Update packages (`flutter pub upgrade`)
- Add new packages

The packages are re-downloaded **without** namespace declarations, so you must re-run the script.

---

## Testing the Process

Verify everything works after clearing cache:

```bash
# Clear cache
flutter pub cache clean

# Get packages
flutter pub get

# Fix and clean
bash fix_namespaces.sh

# Build (should succeed)
flutter build apk --debug
```

---

## Build Commands

### Android Debug
```bash
flutter build apk --debug
```

### Android Release
```bash
flutter build apk --release --split-per-abi
```

### Windows Debug
```bash
flutter build windows --debug
```

### Windows Release
```bash
flutter build windows --release
```

---

## Common Issues & Solutions

### Issue: Build fails with "Namespace not specified"
**Cause:** Forgot to run `fix_namespaces.sh` after `flutter pub get`

**Solution:**
```bash
bash fix_namespaces.sh
flutter build apk --debug
```

### Issue: Script says "Done" but build still fails
**Cause:** Gradle cached old configuration

**Solution:** The script now handles this automatically, but you can manually run:
```bash
cd android
./gradlew clean
cd ..
flutter build apk --debug
```

### Issue: Ran script before `flutter pub get`
**Cause:** Script can't fix packages that don't exist yet

**Solution:** Run in correct order:
```bash
flutter pub get              # First!
bash fix_namespaces.sh       # Then fix
flutter build apk --debug    # Then build
```

---

## Files in This Repo

- **`fix_namespaces.sh`** - The automated fix script (run after `pub get`)
- **`README_FLUTTER_UPGRADE.md`** - This file
- **`FLUTTER_UPGRADE_NOTES.md`** - Detailed technical notes (archived)
- **`BUILD_CHECKLIST.md`** - Quick reference (archived)

---

## Success Criteria

✅ Windows builds successfully
✅ Android builds successfully
✅ App runs without crashes
✅ Media playback works
✅ Navigation works
✅ API calls work
✅ Media controls visible with good contrast

---

## Git Commits

- `77e47fd` - Android Gradle configuration updates
- `e8ba8c9` - Localization imports update
- `338271b` - Android build namespace fixes
- `f5facf7` - Media controls visibility improvements
- `df7ae9a` - Comprehensive upgrade documentation

---

## Future Flutter Updates

When upgrading Flutter in the future:

1. Check Flutter release notes for breaking changes
2. Run `flutter pub get`
3. Run `bash fix_namespaces.sh`
4. Test both platforms
5. Update this document with any new findings

---

## Package Updates

Run `flutter pub outdated` to see available updates:
- 116 packages have newer versions available
- Constrained by current dependencies
- Consider updating gradually in future maintenance

**Note:** One package (`palette_generator`) is discontinued but still works.

---

## Questions?

If the build fails:

1. Did you run `flutter pub get` first?
2. Did you run `bash fix_namespaces.sh` second?
3. Check the script output - did it say "Added namespace..."?
4. Try manually cleaning: `cd android && ./gradlew clean && cd ..`

The process is proven to work - just follow the order! 🎯
