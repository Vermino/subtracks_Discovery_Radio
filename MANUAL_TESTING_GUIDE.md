# Subtracks Offline Mode - Manual Testing Guide

## Introduction

This guide provides step-by-step instructions for manually testing the new offline mode enhancements in Subtracks. It's designed for QA testers, developers, and beta users who want to verify that all features work as expected.

**Target Audience:** QA Engineers, Beta Testers, Developers
**Estimated Testing Time:** 2-3 hours for full test suite
**Prerequisites:** Android device or emulator with Subtracks installed

---

## Table of Contents

1. [Test Environment Setup](#test-environment-setup)
2. [Quick Start Guide](#quick-start-guide)
3. [Feature 1: Download Preferences](#feature-1-download-preferences)
4. [Feature 2: Automatic Station Downloads](#feature-2-automatic-station-downloads)
5. [Feature 3: Thumbs Up/Down Auto-Actions](#feature-3-thumbs-updown-auto-actions)
6. [Troubleshooting](#troubleshooting)
7. [Reporting Issues](#reporting-issues)

---

## Test Environment Setup

### Prerequisites

**Hardware:**
- Android device (Android 8.0+) OR Android emulator
- Ability to switch between WiFi and mobile data
- At least 2GB free storage space
- Access to a WiFi network

**Software:**
- Subtracks app installed (version 2.0.0-alpha.3+12 or later)
- Music source configured (Subsonic/Navidrome server)
- Some music synced to the app

### Initial Setup Steps

1. **Install the App**
   ```bash
   # If testing from source
   flutter run --release

   # Or install APK
   adb install subtracks.apk
   ```

2. **Configure Music Source**
   - Open Subtracks
   - Go to Settings > Sources
   - Add your Subsonic/Navidrome server
   - Sync some music (at least 50 songs)

3. **Enable Developer Logging** (Optional)
   ```bash
   # View logs in real-time
   adb logcat | grep -i subtracks
   ```

4. **Clear App Data** (For fresh start)
   ```bash
   adb shell pm clear com.austinried.subtracks
   ```

5. **Verify Database Version**
   - After opening app, check logs for:
   - "Database schema version: 11"

---

## Quick Start Guide

### 5-Minute Smoke Test

This quick test verifies basic functionality:

1. **Check Settings Exist**
   - Open Settings
   - Look for "Download Preferences" section
   - Verify three options: WiFi Only, Any Connection, Manual Only

2. **Create a Station**
   - Create an offline mode discovery station
   - Verify it starts playing
   - Check if downloads begin (depends on your settings)

3. **Test Thumbs Up**
   - Give a song a thumbs up
   - Check if download starts (if enabled)

4. **Test Thumbs Down**
   - Download a song manually
   - Give it thumbs down
   - Verify file is deleted (if enabled)

**Expected Time:** 5 minutes
**Pass Criteria:** All features accessible and responding

---

## Feature 1: Download Preferences

### Test 1.1: Verify Settings UI

**Objective:** Ensure all download preference options are visible and functional

**Steps:**

1. Open Subtracks
2. Tap the menu (☰) or navigate to Settings
3. Look for "Download Preferences" or "Offline Mode" section

**Expected Results:**

You should see:
- [ ] **Download Preference** dropdown or radio buttons with three options:
  - [ ] "WiFi Only" - Downloads only on WiFi networks
  - [ ] "Any Connection" - Downloads on any network (WiFi or mobile)
  - [ ] "Manual Only" - Never auto-download
- [ ] **Auto-download thumbs up songs** toggle switch
- [ ] **Auto-delete thumbs down songs** toggle switch

**Screenshot Location:** `screenshots/settings-download-preferences.png`

**Pass Criteria:**
✅ All three options visible
✅ Toggles work (can enable/disable)
✅ Current selection is highlighted

---

### Test 1.2: Change Download Preference

**Objective:** Verify preference changes persist across app restarts

**Steps:**

1. Open Settings > Download Preferences
2. Select "WiFi Only"
3. Close Settings
4. Force quit the app (swipe away from recent apps)
5. Reopen Subtracks
6. Check Settings > Download Preferences again

**Expected Result:**
- [ ] "WiFi Only" is still selected
- [ ] Setting persisted after app restart

**Pass Criteria:**
✅ Setting saved to database
✅ Setting restored on app launch

---

### Test 1.3: Test Each Preference Mode

**Objective:** Verify each mode behaves correctly

#### Test 1.3a: WiFi Only Mode

1. Set download preference to "WiFi Only"
2. Connect to WiFi
3. Create an offline mode station
4. Observe behavior

**Expected:**
- [ ] Downloads start immediately
- [ ] You see a SnackBar: "Downloading station songs in background"

5. Now switch to mobile data (disable WiFi)
6. Create another offline mode station
7. Observe behavior

**Expected:**
- [ ] Downloads do NOT start
- [ ] You see a SnackBar: "Downloads queued - will start when WiFi is available"

8. Switch back to WiFi
9. Wait 10 seconds

**Expected:**
- [ ] Queued downloads automatically start
- [ ] Check logs for "Network changed: mobile -> wifi"

**Pass Criteria:**
✅ Downloads only on WiFi
✅ Queues on mobile
✅ Queued downloads trigger when WiFi returns

---

#### Test 1.3b: Any Connection Mode

1. Set download preference to "Any Connection"
2. Connect to WiFi
3. Create an offline mode station

**Expected:**
- [ ] Downloads start immediately

4. Switch to mobile data
5. Create another offline mode station

**Expected:**
- [ ] Downloads start even on mobile data
- [ ] No "queued" message

**Pass Criteria:**
✅ Downloads work on both WiFi and mobile
✅ No network restrictions

---

#### Test 1.3c: Manual Only Mode

1. Set download preference to "Manual Only"
2. Create an offline mode station (on any network)

**Expected:**
- [ ] No downloads start automatically
- [ ] No SnackBar about downloads
- [ ] Station still plays (streaming)

3. Manually download an album
4. Verify manual downloads still work

**Expected:**
- [ ] Manual downloads work normally

**Pass Criteria:**
✅ No automatic downloads
✅ Manual downloads unaffected

---

## Feature 2: Automatic Station Downloads

### Test 2.1: Create Offline Mode Station

**Objective:** Verify automatic downloads work for new stations

**Prerequisites:**
- Download preference: "Any Connection"
- Connected to any network
- At least 50 songs in library

**Steps:**

1. Open Subtracks
2. Navigate to Browse or Library
3. Find "Create Station" or "Discovery Radio" button
4. Tap "Create Station"
5. Select a seed (song, artist, album, or genre)
6. In the dialog:
   - Set **Mode** to "Offline" (toggle switch)
   - Set **Playlist Size** to 50
   - Tap "Create Station"

**Expected Results:**
- [ ] Station starts playing immediately
- [ ] First song plays (may be seed song)
- [ ] SnackBar appears: "Downloading station songs in background"
- [ ] Downloads begin in background
- [ ] Check Android notification area for download progress (if enabled)

**How to Verify Downloads:**

Method 1: Check File Manager
```
/Android/data/com.austinried.subtracks/files/documents/downloads/
```

Method 2: Check Logs
```bash
adb logcat | grep "Auto-download\|Downloading song"
```

Method 3: Check in App
- Go to a song in the station
- Look for download icon or "Downloaded" indicator

**Pass Criteria:**
✅ Station plays immediately
✅ Downloads start without manual intervention
✅ Downloaded songs become available offline
✅ No crashes or errors

**Estimated Time:** 5-10 minutes (depending on song count)

---

### Test 2.2: Network Switching During Downloads

**Objective:** Verify downloads handle network changes gracefully

**Prerequisites:**
- Download preference: "WiFi Only"
- Ability to toggle WiFi on/off

**Steps:**

1. Connect to WiFi
2. Set download preference to "WiFi Only"
3. Create offline station with 100 songs
4. Observe downloads starting
5. After 10-20 seconds, disable WiFi (switch to mobile)
6. Wait 30 seconds
7. Re-enable WiFi

**Expected Results:**
- [ ] Downloads start on WiFi (step 3-4)
- [ ] Downloads pause when switching to mobile (step 5)
- [ ] Downloads resume when WiFi returns (step 7)
- [ ] No duplicate downloads
- [ ] All songs eventually download

**How to Monitor:**

Check logs for these messages:
```
Network changed: wifi -> mobile
Network changed: mobile -> wifi
Network now suitable for downloads, processing queue
```

**Pass Criteria:**
✅ Downloads respect current network
✅ Smooth transitions between networks
✅ No errors or crashes
✅ Complete download despite interruptions

---

### Test 2.3: Multiple Stations

**Objective:** Verify multiple stations can download concurrently

**Steps:**

1. Set download preference to "Any Connection"
2. Create offline station A
3. Immediately create offline station B
4. Create offline station C
5. Monitor download progress for all three

**Expected Results:**
- [ ] All three stations trigger downloads
- [ ] Downloads are queued/managed efficiently
- [ ] No download failures
- [ ] All stations eventually fully downloaded

**Pass Criteria:**
✅ Multiple stations handled correctly
✅ No resource contention issues
✅ App remains responsive

---

### Test 2.4: Already Downloaded Songs

**Objective:** Verify no duplicate downloads occur

**Steps:**

1. Manually download Album X (5 songs)
2. Verify all songs from Album X show as downloaded
3. Create offline station that includes songs from Album X
4. Monitor downloads

**Expected Results:**
- [ ] Songs from Album X are skipped (not re-downloaded)
- [ ] Only new songs are downloaded
- [ ] Logs show: "Song already downloaded: [title]"

**Pass Criteria:**
✅ No duplicate downloads
✅ Efficient download management

---

## Feature 3: Thumbs Up/Down Auto-Actions

### Test 3.1: Thumbs Up Auto-Download Setup

**Objective:** Enable and verify thumbs up auto-download setting

**Steps:**

1. Open Settings > Download Preferences
2. Enable "Auto-download thumbs up songs" toggle
3. Set download preference to "Any Connection"

**Expected:**
- [ ] Toggle turns on (visual feedback)
- [ ] Setting saved

---

### Test 3.2: Thumbs Up Downloads Song

**Objective:** Verify song downloads when given thumbs up

**Prerequisites:**
- "Auto-download thumbs up songs" enabled
- Download preference: "Any Connection"
- Song NOT already downloaded

**Steps:**

1. Play a song that is **not** downloaded
2. Verify the song is streaming (not offline)
3. Tap the thumbs up button 👍
4. Observe behavior

**Expected Results:**
- [ ] Song rating changes to thumbs up ✅
- [ ] Download starts immediately
- [ ] Logs show: "Auto-downloading thumbs up song: [title]"
- [ ] Download progress visible (notification or downloads page)
- [ ] After completion, song shows as downloaded

**How to Verify:**
- Check file manager for downloaded file
- Check song details for "Downloaded" badge
- Try playing song in airplane mode

**Pass Criteria:**
✅ Rating saved
✅ Download triggered
✅ File successfully downloaded
✅ Song playable offline

**Estimated Time:** 2-3 minutes per song

---

### Test 3.3: Thumbs Up - Already Downloaded

**Objective:** Verify no duplicate download for already-downloaded song

**Steps:**

1. Download a song manually
2. Verify it shows as downloaded
3. Give the same song thumbs up 👍

**Expected Results:**
- [ ] Rating changes to thumbs up
- [ ] NO new download starts
- [ ] Logs show: "Song already downloaded: [title]"

**Pass Criteria:**
✅ No duplicate download
✅ Rating still saved

---

### Test 3.4: Thumbs Up with WiFi Only Preference

**Objective:** Verify network preference respected for thumbs up downloads

**Prerequisites:**
- "Auto-download thumbs up songs" enabled
- Download preference: "WiFi Only"
- Connected to mobile network (NOT WiFi)

**Steps:**

1. Disable WiFi, use mobile data
2. Play a non-downloaded song
3. Give it thumbs up 👍
4. Observe behavior

**Expected Results:**
- [ ] Rating changes to thumbs up
- [ ] Download is queued (not started immediately)
- [ ] Logs show: "Network conditions not suitable, queueing"

5. Enable WiFi
6. Wait 10 seconds

**Expected:**
- [ ] Download starts automatically
- [ ] Song downloads successfully

**Pass Criteria:**
✅ Respects network preference
✅ Queued download triggers on WiFi

---

### Test 3.5: Thumbs Up Disabled

**Objective:** Verify nothing happens when feature disabled

**Steps:**

1. Open Settings
2. Disable "Auto-download thumbs up songs" toggle
3. Play a non-downloaded song
4. Give it thumbs up 👍

**Expected Results:**
- [ ] Rating changes to thumbs up
- [ ] NO download starts
- [ ] Logs show: "Thumbs up auto-download is disabled"

**Pass Criteria:**
✅ Feature can be disabled
✅ Disabled state works correctly

---

### Test 3.6: Thumbs Down Auto-Delete Setup

**Objective:** Enable and verify thumbs down auto-delete setting

**Steps:**

1. Open Settings > Download Preferences
2. Enable "Auto-delete thumbs down songs" toggle

**Expected:**
- [ ] Toggle turns on
- [ ] Setting saved

---

### Test 3.7: Thumbs Down Deletes Downloaded Song

**Objective:** Verify downloaded file is deleted on thumbs down

**Prerequisites:**
- "Auto-delete thumbs down songs" enabled
- Song is downloaded

**Steps:**

1. Download a song manually
2. Verify it shows as downloaded
3. Note the file path (check logs or file manager)
4. Play the song
5. Give it thumbs down 👎

**Expected Results:**
- [ ] Rating changes to thumbs down
- [ ] If song is currently playing, it skips to next track
- [ ] File is deleted from storage
- [ ] Logs show: "Deleted downloaded file for thumbs down: [title]"
- [ ] Song no longer shows as "Downloaded"
- [ ] Database updated (download_file_path cleared)

**How to Verify Deletion:**

Method 1: Check file manager - file should be gone

Method 2: Try playing in airplane mode - should fail or stream

Method 3: Check logs:
```bash
adb logcat | grep "Auto-deleting thumbs down"
```

**Pass Criteria:**
✅ File deleted from filesystem
✅ Database updated
✅ UI reflects change (no "Downloaded" badge)
✅ Playback skips to next if currently playing

---

### Test 3.8: Thumbs Down Non-Downloaded Song

**Objective:** Verify graceful handling when song not downloaded

**Steps:**

1. Play a streaming song (not downloaded)
2. Give it thumbs down 👎

**Expected Results:**
- [ ] Rating changes to thumbs down
- [ ] No errors
- [ ] Logs show: "Song not downloaded, nothing to delete"
- [ ] App continues working normally

**Pass Criteria:**
✅ No crash
✅ Graceful handling of non-existent file

---

### Test 3.9: Thumbs Down - File Already Missing

**Objective:** Verify database cleanup when file manually deleted

**Steps:**

1. Download a song
2. Manually delete the file using file manager:
   ```
   /Android/data/com.austinried.subtracks/files/documents/downloads/[source_id]/[song_file]
   ```
3. In app, give that song thumbs down 👎

**Expected Results:**
- [ ] No crash
- [ ] Database entry still cleaned up
- [ ] Logs show: "Download file does not exist: [path]"
- [ ] Song marked as not downloaded in UI

**Pass Criteria:**
✅ No crash
✅ Database properly cleaned
✅ Handles missing file gracefully

---

### Test 3.10: Thumbs Down Disabled

**Objective:** Verify deletion doesn't occur when feature disabled

**Steps:**

1. Open Settings
2. Disable "Auto-delete thumbs down songs" toggle
3. Download a song
4. Give it thumbs down 👎

**Expected Results:**
- [ ] Rating changes to thumbs down
- [ ] File is NOT deleted
- [ ] Song still shows as downloaded
- [ ] Logs show: "Thumbs down auto-delete is disabled"

**Pass Criteria:**
✅ Feature can be disabled
✅ File remains when disabled

---

### Test 3.11: Rapid Rating Changes

**Objective:** Verify no race conditions with rapid rating changes

**Prerequisites:**
- Both auto-download and auto-delete enabled
- Song not downloaded initially

**Steps:**

1. Play a song
2. Rapidly tap: Thumbs up 👍
3. Wait 2 seconds
4. Tap: Thumbs down 👎
5. Wait 2 seconds
6. Tap: Thumbs up 👍 again
7. Wait 2 seconds
8. Tap: Clear rating (if available)

**Expected Results:**
- [ ] Final rating is correctly saved
- [ ] No crashes
- [ ] No file system corruption
- [ ] Download starts/stops appropriately
- [ ] Logs show all operations completed

**How to Monitor:**
```bash
adb logcat | grep "Rating update\|Auto-download\|Auto-delet"
```

**Pass Criteria:**
✅ App handles rapid changes
✅ No race conditions
✅ Final state is consistent
✅ No orphaned files

---

## Combined Feature Testing

### Test 4.1: Full Offline Station Workflow

**Objective:** Test complete flow from station creation to offline playback

**Prerequisites:**
- Download preference: "WiFi Only"
- Connected to WiFi
- Both thumbs up and thumbs down features enabled

**Steps:**

1. **Create Station**
   - Create offline mode discovery station
   - Playlist size: 50 songs
   - Verify downloads start

2. **Rate Songs**
   - Play through 10 songs
   - Give thumbs up to 3 songs
   - Give thumbs down to 2 songs

3. **Verify Auto-Actions**
   - Thumbs up songs start downloading (if not already)
   - Thumbs down songs are deleted (if downloaded)

4. **Test Offline Playback**
   - Enable airplane mode
   - Continue playing station
   - Verify downloaded songs play
   - Verify non-downloaded songs skip or show error

5. **Network Recovery**
   - Disable airplane mode
   - Connect to WiFi
   - Verify streaming resumes

**Expected Results:**
- [ ] Station created successfully
- [ ] Initial downloads started
- [ ] Thumbs up downloads triggered
- [ ] Thumbs down deletions occurred
- [ ] Offline playback works with downloaded songs
- [ ] Seamless transition back to streaming

**Pass Criteria:**
✅ Complete workflow works end-to-end
✅ No errors or crashes
✅ User experience is smooth

**Estimated Time:** 15-20 minutes

---

### Test 4.2: Preference Changes Mid-Operation

**Objective:** Verify changing preferences during active operations

**Steps:**

1. Start with "Any Connection"
2. Create large offline station (100 songs)
3. Wait until 20 songs are downloading
4. Change preference to "Manual Only"
5. Observe behavior

**Expected Results:**
- [ ] In-progress downloads may continue or pause
- [ ] No new downloads start
- [ ] No crashes

6. Change back to "Any Connection"
7. Observe behavior

**Expected:**
- [ ] Downloads resume (if paused)
- [ ] Station continues to populate

**Pass Criteria:**
✅ Graceful handling of preference changes
✅ No data loss
✅ No crashes

---

## Troubleshooting

### Issue: Downloads Not Starting

**Symptoms:**
- Station created but no downloads
- No SnackBar message

**Debugging Steps:**
1. Check download preference setting (may be "Manual Only")
2. Check network connection
3. Check logs for errors:
   ```bash
   adb logcat | grep "Auto-download\|ERROR"
   ```
4. Verify songs in playlist aren't already downloaded
5. Check storage space (may be full)

**Solutions:**
- Change to "Any Connection" preference
- Ensure stable network
- Free up storage space

---

### Issue: Thumbs Up Not Downloading

**Symptoms:**
- Song rated but download doesn't start

**Debugging Steps:**
1. Check "Auto-download thumbs up songs" is enabled
2. Check download preference isn't "Manual Only"
3. Check song isn't already downloaded
4. Check network connection
5. Check logs:
   ```bash
   adb logcat | grep "downloadThumbsUpSong"
   ```

**Solutions:**
- Enable the feature in settings
- Change network preference
- Verify network connection

---

### Issue: Thumbs Down Not Deleting

**Symptoms:**
- Song rated thumbs down but file remains

**Debugging Steps:**
1. Check "Auto-delete thumbs down songs" is enabled
2. Verify song was actually downloaded (check file manager)
3. Check logs:
   ```bash
   adb logcat | grep "deleteThumbsDownSong"
   ```

**Solutions:**
- Enable the feature in settings
- Manually delete file if stuck

---

### Issue: App Crashes on Rating

**Symptoms:**
- App closes when tapping thumbs up/down

**Debugging Steps:**
1. Get crash logs:
   ```bash
   adb logcat | grep "FATAL\|AndroidRuntime"
   ```
2. Note the exact steps to reproduce
3. Check if specific song or network condition

**Action:**
- Report as critical bug with logs

---

### Issue: Downloads Use Too Much Data

**Symptoms:**
- Large data usage on mobile network

**Solutions:**
- Set download preference to "WiFi Only"
- Disable "Auto-download thumbs up songs"
- Use "Manual Only" and download on WiFi manually

---

### Issue: Storage Full

**Symptoms:**
- Downloads fail
- "Insufficient storage" errors

**Solutions:**
1. Check available storage:
   ```bash
   adb shell df /data
   ```
2. Delete old downloads
3. Clear app cache (Settings > Apps > Subtracks > Clear Cache)

---

## Reporting Issues

### Bug Report Template

When reporting issues, please include:

```markdown
**Bug Title:** [Brief description]

**Severity:** Critical / High / Medium / Low

**Steps to Reproduce:**
1. [First step]
2. [Second step]
3. [Third step]

**Expected Result:**
[What should happen]

**Actual Result:**
[What actually happened]

**Environment:**
- Device: [e.g., Pixel 5, Samsung Galaxy S21]
- Android Version: [e.g., Android 12]
- App Version: [e.g., 2.0.0-alpha.3+12]
- Network: [WiFi / Mobile / Offline]

**Settings:**
- Download Preference: [WiFi Only / Any Connection / Manual Only]
- Thumbs Up Auto-Download: [Enabled / Disabled]
- Thumbs Down Auto-Delete: [Enabled / Disabled]

**Logs:**
```
[Paste relevant logs here from adb logcat]
```

**Screenshots:**
[Attach screenshots if applicable]

**Additional Context:**
[Any other relevant information]
```

### Where to Report

- **GitHub Issues:** https://github.com/austinried/subtracks/issues
- **Discord:** [If available]
- **Email:** [Developer email if applicable]

---

## Test Results Checklist

Use this checklist to track your testing progress:

### Settings Tests
- [ ] 1.1: Settings UI visible
- [ ] 1.2: Preference persists
- [ ] 1.3a: WiFi Only mode
- [ ] 1.3b: Any Connection mode
- [ ] 1.3c: Manual Only mode

### Station Download Tests
- [ ] 2.1: Create offline station
- [ ] 2.2: Network switching
- [ ] 2.3: Multiple stations
- [ ] 2.4: Skip downloaded songs

### Thumbs Up Tests
- [ ] 3.1: Enable auto-download
- [ ] 3.2: Downloads on thumbs up
- [ ] 3.3: Skip if downloaded
- [ ] 3.4: WiFi only preference
- [ ] 3.5: Feature disabled

### Thumbs Down Tests
- [ ] 3.6: Enable auto-delete
- [ ] 3.7: Deletes on thumbs down
- [ ] 3.8: Graceful for non-downloaded
- [ ] 3.9: Handles missing file
- [ ] 3.10: Feature disabled
- [ ] 3.11: Rapid rating changes

### Integration Tests
- [ ] 4.1: Full workflow
- [ ] 4.2: Preference changes

### Overall Assessment
- [ ] No crashes observed
- [ ] Performance acceptable
- [ ] User experience smooth
- [ ] All features working

**Testing Completed By:** _______________
**Date:** _______________
**Result:** PASS / FAIL / PARTIAL

---

## Tips for Testers

1. **Test on Real Device:** Emulators may not accurately simulate network changes
2. **Monitor Storage:** Keep an eye on storage space during testing
3. **Keep Logs:** Always capture logs when testing, especially if issues occur
4. **Test Edge Cases:** Try unusual scenarios like rapid button presses
5. **Document Everything:** Take screenshots and notes for bug reports
6. **Be Patient:** Downloads can take time, especially on mobile networks
7. **Clean Environment:** Start with fresh app data for consistent results

---

## Appendix: ADB Commands Reference

```bash
# Install app
adb install subtracks.apk

# View logs
adb logcat | grep -i subtracks

# Clear app data
adb shell pm clear com.austinried.subtracks

# Check storage
adb shell df /data

# List downloaded files
adb shell ls -la /sdcard/Android/data/com.austinried.subtracks/files/documents/downloads/

# Pull database for inspection
adb pull /data/data/com.austinried.subtracks/app_flutter/subtracks.sqlite

# Force stop app
adb shell am force-stop com.austinried.subtracks

# Enable/disable WiFi
adb shell svc wifi enable
adb shell svc wifi disable

# Enable/disable mobile data
adb shell svc data enable
adb shell svc data disable
```

---

**Document Version:** 1.0
**Last Updated:** 2025-10-15
**Maintainer:** Testing Team

Thank you for helping test Subtracks offline mode enhancements! 🎵
