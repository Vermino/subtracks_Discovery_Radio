# Subtracks Offline Mode Enhancement Testing Plan

## Overview

This document provides comprehensive testing scenarios for the offline mode enhancements implemented in Subtracks. The features include:

1. **Enhanced Offline Mode Settings** (Phase 1)
2. **Automatic Station Song Downloads** (Phase 2)
3. **Thumbs Up Auto-Download & Thumbs Down Auto-Delete** (Phase 3)

## Database Schema Verification

### Schema Migration Testing

**Test ID:** DB-001
**Feature:** Database Migration to v11
**Prerequisites:** Fresh installation or app upgraded from v10

**Test Steps:**
1. Install/upgrade app to trigger migration
2. Verify database version is 11
3. Check `app_settings` table has new columns:
   - `download_preference` (TEXT, default: 'any_connection')
   - `thumbs_up_auto_download` (BOOLEAN, default: 0)
   - `thumbs_down_auto_delete` (BOOLEAN, default: 0)

**Expected Results:**
- Migration completes without errors
- All three columns exist with correct data types
- Default values are properly set
- No data loss from previous schema

**SQL Verification:**
```sql
PRAGMA table_info(app_settings);
SELECT download_preference, thumbs_up_auto_download, thumbs_down_auto_delete FROM app_settings WHERE id = 1;
```

---

## Phase 1: Download Preference Settings

### Test Category: Settings Infrastructure

**Test ID:** PREF-001
**Test Name:** Default Download Preference
**Objective:** Verify default value for new installations

**Test Steps:**
1. Install fresh app
2. Navigate to Settings
3. Check download preference setting

**Expected Result:**
- Default value is "Any Connection" (`any_connection`)

---

**Test ID:** PREF-002
**Test Name:** Download Preference Persistence
**Objective:** Verify settings are saved and restored

**Test Steps:**
1. Open Settings
2. Change download preference to "WiFi Only"
3. Close app completely
4. Restart app
5. Check settings again

**Expected Result:**
- Setting persists as "WiFi Only" after app restart

---

**Test ID:** PREF-003
**Test Name:** Download Preference Options
**Objective:** Verify all three preference modes are available

**Test Steps:**
1. Navigate to Settings > Download Preferences
2. View available options

**Expected Result:**
- Three options available:
  1. "WiFi Only" - Downloads only on WiFi
  2. "Any Connection" - Downloads on any network
  3. "Manual Only" - Never auto-download

---

**Test ID:** PREF-004
**Test Name:** Settings UI Reflection
**Objective:** Verify UI updates reflect backend changes

**Test Steps:**
1. Change download preference in UI
2. Verify the change is reflected in database
3. Verify the change is used by auto-download service

**Expected Result:**
- UI changes immediately update database
- Auto-download service respects new setting without app restart

---

## Phase 2: Automatic Station Downloads

### Test Category: WiFi Only Preference

**Test ID:** AUTO-001
**Test Name:** Station Creation on WiFi with WiFi Only Preference
**Objective:** Verify downloads start immediately on WiFi

**Prerequisites:**
- Download preference: "WiFi Only"
- Device connected to WiFi network

**Test Steps:**
1. Set download preference to "WiFi Only"
2. Create an offline mode discovery station
3. Wait 5 seconds after station creation

**Expected Result:**
- SnackBar shows: "Downloading station songs in background"
- Downloads begin immediately
- Download progress visible in notifications or download manager
- Songs gradually become available offline

---

**Test ID:** AUTO-002
**Test Name:** Station Creation on Mobile with WiFi Only Preference
**Objective:** Verify downloads are queued when on mobile network

**Prerequisites:**
- Download preference: "WiFi Only"
- Device connected to mobile network (not WiFi)

**Test Steps:**
1. Set download preference to "WiFi Only"
2. Disable WiFi, enable mobile data
3. Create an offline mode discovery station
4. Observe behavior

**Expected Result:**
- SnackBar shows: "Downloads queued - will start when WiFi is available"
- No downloads start immediately
- Songs are not downloaded while on mobile network
- Station still plays (streams) but songs aren't saved offline

---

**Test ID:** AUTO-003
**Test Name:** Network Switch from Mobile to WiFi
**Objective:** Verify queued downloads trigger when WiFi becomes available

**Prerequisites:**
- Download preference: "WiFi Only"
- Start on mobile network

**Test Steps:**
1. Set download preference to "WiFi Only"
2. Create offline station on mobile network
3. Verify downloads are queued (no immediate download)
4. Connect to WiFi
5. Wait 10 seconds

**Expected Result:**
- Queued downloads automatically start when WiFi connects
- Log shows: "Network changed: mobile -> wifi"
- Log shows: "Network now suitable for downloads, processing queue"
- Downloads begin without user intervention

---

### Test Category: Any Connection Preference

**Test ID:** AUTO-004
**Test Name:** Station Creation on WiFi with Any Connection
**Objective:** Verify downloads work on WiFi

**Prerequisites:**
- Download preference: "Any Connection"
- Device connected to WiFi

**Test Steps:**
1. Set download preference to "Any Connection"
2. Create offline mode discovery station on WiFi
3. Observe behavior

**Expected Result:**
- Downloads start immediately
- SnackBar shows: "Downloading station songs in background"
- Songs downloaded successfully

---

**Test ID:** AUTO-005
**Test Name:** Station Creation on Mobile with Any Connection
**Objective:** Verify downloads work on mobile data

**Prerequisites:**
- Download preference: "Any Connection"
- Device connected to mobile network

**Test Steps:**
1. Set download preference to "Any Connection"
2. Disable WiFi, use mobile data
3. Create offline mode discovery station
4. Observe behavior

**Expected Result:**
- Downloads start immediately even on mobile
- SnackBar shows: "Downloading station songs in background"
- Songs downloaded successfully using mobile data

---

### Test Category: Manual Only Preference

**Test ID:** AUTO-006
**Test Name:** Station Creation with Manual Only Preference
**Objective:** Verify no auto-downloads occur

**Prerequisites:**
- Download preference: "Manual Only"

**Test Steps:**
1. Set download preference to "Manual Only"
2. Create offline mode discovery station
3. Wait 30 seconds

**Expected Result:**
- No automatic downloads start
- No download-related SnackBar appears
- Songs remain not downloaded
- User must manually download albums/playlists to get offline songs

---

**Test ID:** AUTO-007
**Test Name:** Manual Only Preference on Online Station
**Objective:** Verify online stations work with manual only

**Prerequisites:**
- Download preference: "Manual Only"

**Test Steps:**
1. Set download preference to "Manual Only"
2. Create **online** mode discovery station
3. Verify playback works

**Expected Result:**
- Station plays normally (streaming)
- No downloads occur
- Playback is not affected by manual-only preference

---

### Test Category: Network Change Scenarios

**Test ID:** AUTO-008
**Test Name:** Multiple Network Switches
**Objective:** Verify correct behavior through network changes

**Prerequisites:**
- Download preference: "WiFi Only"
- Ability to switch between WiFi and mobile

**Test Steps:**
1. Start on WiFi, create offline station (downloads start)
2. Switch to mobile network mid-download
3. Wait 10 seconds
4. Switch back to WiFi
5. Observe behavior

**Expected Result:**
- Downloads pause when switching to mobile
- Downloads resume when switching back to WiFi
- No duplicate downloads
- Partial downloads continue from where they left off

---

**Test ID:** AUTO-009
**Test Name:** No Network Connection
**Objective:** Verify graceful handling of no network

**Prerequisites:**
- Enable airplane mode or disable all connections

**Test Steps:**
1. Disconnect from all networks (airplane mode)
2. Attempt to create offline mode station

**Expected Result:**
- Station creation shows appropriate error message
- App doesn't crash
- User receives helpful feedback about network requirement

---

### Test Category: Download Progress Tracking

**Test ID:** AUTO-010
**Test Name:** Download Progress Monitoring
**Objective:** Verify user can see download progress

**Prerequisites:**
- Download preference: "Any Connection"

**Test Steps:**
1. Create offline station with 50+ songs
2. Monitor downloads through UI
3. Check for progress indicators

**Expected Result:**
- User can see which songs are downloading
- Progress percentage visible
- Downloaded songs marked as "offline available"
- Clear indication of how many songs remain

---

**Test ID:** AUTO-011
**Test Name:** Already Downloaded Songs
**Objective:** Verify no duplicate downloads

**Prerequisites:**
- Some songs already downloaded

**Test Steps:**
1. Download an album manually
2. Create offline station that includes songs from that album
3. Observe download behavior

**Expected Result:**
- Already downloaded songs are skipped
- Only missing songs are downloaded
- Log shows: "Song already downloaded: [title]"
- No duplicate download attempts

---

## Phase 3: Thumbs Up/Down Auto Actions

### Test Category: Thumbs Up Auto-Download

**Test ID:** THUMBS-001
**Test Name:** Thumbs Up with Auto-Download Enabled on WiFi
**Objective:** Verify song downloads when thumbs up

**Prerequisites:**
- `thumbsUpAutoDownload` enabled
- Download preference: "Any Connection"
- Connected to WiFi

**Test Steps:**
1. Enable "Auto-download thumbs up songs" in settings
2. Play a song that is not downloaded
3. Give it a thumbs up
4. Wait 5 seconds

**Expected Result:**
- Song download starts immediately
- Album containing the song begins downloading
- Download progress visible
- Log shows: "Auto-downloading thumbs up song: [title]"

---

**Test ID:** THUMBS-002
**Test Name:** Thumbs Up with Auto-Download Disabled
**Objective:** Verify no download when feature disabled

**Prerequisites:**
- `thumbsUpAutoDownload` disabled

**Test Steps:**
1. Disable "Auto-download thumbs up songs" in settings
2. Play a song that is not downloaded
3. Give it a thumbs up
4. Wait 10 seconds

**Expected Result:**
- Song is rated but NOT downloaded
- No download activity
- Rating is saved in database

---

**Test ID:** THUMBS-003
**Test Name:** Thumbs Up Already Downloaded Song
**Objective:** Verify no duplicate download

**Prerequisites:**
- `thumbsUpAutoDownload` enabled
- Song already downloaded

**Test Steps:**
1. Download a song manually first
2. Give it a thumbs up

**Expected Result:**
- No download starts (song already downloaded)
- Log shows: "Song already downloaded: [title]"
- Rating is still saved

---

**Test ID:** THUMBS-004
**Test Name:** Thumbs Up with Manual Only Preference
**Objective:** Verify manual-only overrides thumbs up auto-download

**Prerequisites:**
- `thumbsUpAutoDownload` enabled
- Download preference: "Manual Only"

**Test Steps:**
1. Enable thumbs up auto-download
2. Set download preference to "Manual Only"
3. Give a song thumbs up

**Expected Result:**
- No download occurs (manual-only takes precedence)
- Rating is saved
- User must manually download if they want it offline

---

**Test ID:** THUMBS-005
**Test Name:** Thumbs Up on Mobile with WiFi Only
**Objective:** Verify download respects network preference

**Prerequisites:**
- `thumbsUpAutoDownload` enabled
- Download preference: "WiFi Only"
- Connected to mobile network

**Test Steps:**
1. Connect to mobile network only
2. Give a song thumbs up

**Expected Result:**
- Download is queued (not started immediately)
- Will download when WiFi becomes available
- Rating is saved immediately

---

### Test Category: Thumbs Down Auto-Delete

**Test ID:** THUMBS-006
**Test Name:** Thumbs Down Downloaded Song with Auto-Delete Enabled
**Objective:** Verify downloaded file is deleted

**Prerequisites:**
- `thumbsDownAutoDelete` enabled
- Song is downloaded offline

**Test Steps:**
1. Enable "Auto-delete thumbs down songs" in settings
2. Download a song
3. Verify song is available offline
4. Give it a thumbs down
5. Wait 3 seconds
6. Check if file still exists

**Expected Result:**
- Downloaded file is immediately deleted
- Database updated to remove download status
- Log shows: "Deleted downloaded file for thumbs down: [title]"
- Log shows: "Auto-deleting thumbs down song: [title]"
- Song can still be streamed if online

---

**Test ID:** THUMBS-007
**Test Name:** Thumbs Down with Auto-Delete Disabled
**Objective:** Verify file is not deleted when feature disabled

**Prerequisites:**
- `thumbsDownAutoDelete` disabled
- Song is downloaded

**Test Steps:**
1. Disable "Auto-delete thumbs down songs"
2. Download a song
3. Give it a thumbs down
4. Check file still exists

**Expected Result:**
- Downloaded file remains
- Rating is saved
- User must manually delete if desired

---

**Test ID:** THUMBS-008
**Test Name:** Thumbs Down Non-Downloaded Song
**Objective:** Verify graceful handling when file doesn't exist

**Prerequisites:**
- `thumbsDownAutoDelete` enabled
- Song not downloaded

**Test Steps:**
1. Play a streaming song (not downloaded)
2. Give it a thumbs down

**Expected Result:**
- No error occurs
- Rating is saved
- Log shows: "Song not downloaded, nothing to delete: [title]"
- App continues functioning normally

---

**Test ID:** THUMBS-009
**Test Name:** Thumbs Down File Already Deleted
**Objective:** Verify database cleanup when file missing

**Prerequisites:**
- `thumbsDownAutoDelete` enabled
- Song marked as downloaded in DB but file manually deleted

**Test Steps:**
1. Download a song
2. Manually delete the file from filesystem
3. Give the song a thumbs down

**Expected Result:**
- No crash or error
- Database entry cleared
- Log shows: "Download file does not exist: [path]"
- App continues functioning

---

**Test ID:** THUMBS-010
**Test Name:** Thumbs Down Database Cleanup
**Objective:** Verify database properly updated after deletion

**Prerequisites:**
- `thumbsDownAutoDelete` enabled

**Test Steps:**
1. Download a song
2. Query database for download status
3. Give song thumbs down
4. Query database again

**Expected Result:**
- Before: `download_file_path` is set
- After: `download_file_path` is NULL
- After: `download_task_id` is NULL
- Song no longer shows as "downloaded" in UI

---

## Integration Testing

### Test Category: Combined Feature Testing

**Test ID:** INT-001
**Test Name:** Full Offline Station Workflow
**Objective:** Test complete flow from station creation to playback

**Prerequisites:**
- Download preference: "WiFi Only"
- Connected to WiFi
- Both thumbs up and thumbs down features enabled

**Test Steps:**
1. Create offline mode discovery station
2. Verify initial downloads start
3. Play through several songs
4. Give thumbs up to 3 songs
5. Give thumbs down to 2 songs
6. Verify all expected downloads and deletions occur
7. Enable airplane mode
8. Verify station still plays with downloaded songs

**Expected Result:**
- Station songs download automatically
- Thumbs up songs download (including new ones)
- Thumbs down songs deleted
- Offline playback works with downloaded content
- No network errors in airplane mode

---

**Test ID:** INT-002
**Test Name:** Network Change During Active Station
**Objective:** Verify behavior when network changes during playback

**Prerequisites:**
- Download preference: "WiFi Only"
- Active offline station playing

**Test Steps:**
1. Start on WiFi with downloading station
2. Switch to mobile during playback
3. Continue giving thumbs up/down
4. Switch back to WiFi
5. Observe download behavior

**Expected Result:**
- Playback continues uninterrupted
- Thumbs up on mobile queues downloads
- Thumbs down on mobile still deletes
- Queued downloads start when WiFi returns
- No duplicate downloads

---

**Test ID:** INT-003
**Test Name:** Preference Change Mid-Download
**Objective:** Verify behavior when changing preferences during active downloads

**Prerequisites:**
- Downloads in progress

**Test Steps:**
1. Start station downloads with "Any Connection"
2. While downloading, change to "Manual Only"
3. Observe behavior

**Expected Result:**
- Current downloads may continue or pause gracefully
- No new downloads start
- No crashes or errors
- Downloads can be managed manually

---

**Test ID:** INT-004
**Test Name:** Multiple Stations with Different Preferences
**Objective:** Verify each station respects current settings

**Test Steps:**
1. Create offline station A with "WiFi Only" on WiFi
2. Change to "Manual Only"
3. Create offline station B
4. Observe download behavior

**Expected Result:**
- Station A downloads occurred (created with WiFi Only on WiFi)
- Station B does not trigger downloads (Manual Only active)
- Each station respects settings at time of creation

---

### Test Category: Error Handling & Edge Cases

**Test ID:** EDGE-001
**Test Name:** Rapid Rating Changes
**Objective:** Verify no race conditions with rapid thumbs up/down

**Test Steps:**
1. Enable both auto-download and auto-delete
2. Quickly toggle between thumbs up and thumbs down on same song
3. Repeat 5 times rapidly

**Expected Result:**
- Final rating is correctly saved
- No orphaned downloads
- No file system corruption
- No duplicate downloads
- Log shows all operations completed

---

**Test ID:** EDGE-002
**Test Name:** App Restart During Downloads
**Objective:** Verify download recovery after restart

**Test Steps:**
1. Start large station download (100+ songs)
2. Force quit app mid-download
3. Restart app
4. Check download status

**Expected Result:**
- App resumes downloads from where it left off
- No duplicate downloads
- No corrupted files
- Download progress preserved
- Log shows: "Syncing download tasks"

---

**Test ID:** EDGE-003
**Test Name:** Low Storage Space
**Objective:** Verify graceful handling of insufficient storage

**Prerequisites:**
- Device with very low storage space

**Test Steps:**
1. Fill device storage until < 100MB free
2. Attempt to download large station

**Expected Result:**
- App detects low storage
- Shows error message to user
- Doesn't crash
- Allows user to free up space and retry
- Partial downloads cleaned up properly

---

**Test ID:** EDGE-004
**Test Name:** Delete While Playing
**Objective:** Verify safe deletion of currently playing song

**Test Steps:**
1. Play a downloaded song
2. Give it thumbs down (auto-delete enabled)
3. Continue playback

**Expected Result:**
- Playback continues until song ends
- File deleted after playback completes OR
- Playback switches to streaming seamlessly
- No crash or audio glitches

---

**Test ID:** EDGE-005
**Test Name:** Network Timeout During Download
**Objective:** Verify handling of network failures

**Test Steps:**
1. Start downloads
2. Simulate network timeout/failure
3. Observe behavior

**Expected Result:**
- Failed downloads marked appropriately
- Retry logic kicks in
- User notified of failures
- Partial files cleaned up
- Other downloads continue

---

## Performance Testing

### Test Category: Download Performance

**Test ID:** PERF-001
**Test Name:** Large Station Download Performance
**Objective:** Verify app remains responsive during large downloads

**Test Steps:**
1. Create offline station with 100 songs
2. Monitor app responsiveness during downloads
3. Navigate between screens
4. Check CPU and memory usage

**Expected Result:**
- App remains responsive
- UI doesn't freeze
- CPU usage reasonable (< 50%)
- Memory usage stable
- Background downloads don't impact foreground performance

---

**Test ID:** PERF-002
**Test Name:** Multiple Concurrent Downloads
**Objective:** Verify handling of multiple stations downloading

**Test Steps:**
1. Create 3 offline stations in quick succession
2. Monitor download behavior
3. Check network utilization

**Expected Result:**
- Downloads are queued/managed efficiently
- Network bandwidth used effectively
- No download failures due to contention
- All stations eventually fully downloaded

---

## Test Execution Checklist

Use this checklist when executing the test plan:

### Pre-Testing Setup
- [ ] Fresh app installation or clean test environment
- [ ] Database backed up
- [ ] Network connectivity verified
- [ ] Ability to switch between WiFi and mobile
- [ ] Sufficient storage space available
- [ ] Logging enabled for debugging

### Settings Tests
- [ ] PREF-001: Default preference
- [ ] PREF-002: Preference persistence
- [ ] PREF-003: All options available
- [ ] PREF-004: UI reflection

### Auto-Download Tests (WiFi Only)
- [ ] AUTO-001: WiFi + WiFi Only
- [ ] AUTO-002: Mobile + WiFi Only
- [ ] AUTO-003: Network switch to WiFi

### Auto-Download Tests (Any Connection)
- [ ] AUTO-004: WiFi + Any Connection
- [ ] AUTO-005: Mobile + Any Connection

### Auto-Download Tests (Manual Only)
- [ ] AUTO-006: Manual Only no downloads
- [ ] AUTO-007: Manual Only online station

### Network Tests
- [ ] AUTO-008: Multiple switches
- [ ] AUTO-009: No network
- [ ] AUTO-010: Progress monitoring
- [ ] AUTO-011: Skip downloaded songs

### Thumbs Up Tests
- [ ] THUMBS-001: Auto-download enabled
- [ ] THUMBS-002: Auto-download disabled
- [ ] THUMBS-003: Already downloaded
- [ ] THUMBS-004: Manual only preference
- [ ] THUMBS-005: Mobile + WiFi Only

### Thumbs Down Tests
- [ ] THUMBS-006: Auto-delete enabled
- [ ] THUMBS-007: Auto-delete disabled
- [ ] THUMBS-008: Non-downloaded song
- [ ] THUMBS-009: File already deleted
- [ ] THUMBS-010: Database cleanup

### Integration Tests
- [ ] INT-001: Full workflow
- [ ] INT-002: Network changes
- [ ] INT-003: Preference changes
- [ ] INT-004: Multiple stations

### Edge Case Tests
- [ ] EDGE-001: Rapid rating changes
- [ ] EDGE-002: App restart
- [ ] EDGE-003: Low storage
- [ ] EDGE-004: Delete while playing
- [ ] EDGE-005: Network timeout

### Performance Tests
- [ ] PERF-001: Large downloads
- [ ] PERF-002: Concurrent downloads

## Test Results Template

For each test, record results using this format:

```
Test ID: [e.g., AUTO-001]
Test Name: [e.g., Station Creation on WiFi with WiFi Only]
Date: [YYYY-MM-DD]
Tester: [Name]
Environment: [Device model, Android/iOS version]
Build Version: [App version]

Result: [ ] PASS  [ ] FAIL  [ ] BLOCKED

Actual Result:
[Description of what actually happened]

Issues Found:
[List any bugs, unexpected behavior, or concerns]

Screenshots/Logs:
[Attach relevant screenshots or log excerpts]

Notes:
[Any additional observations]
```

## Test Environment Requirements

### Device Requirements
- **Android Device:** Android 8.0+ or emulator
- **iOS Device:** iOS 12.0+ or simulator
- **Root Access:** Not required
- **Developer Options:** Enabled for logging

### Network Requirements
- WiFi network access
- Mobile data access (or ability to simulate)
- Ability to toggle networks quickly
- Network monitoring tools (optional)

### Storage Requirements
- Minimum 2GB free space for downloads
- Ability to simulate low storage (optional)

### Tools Needed
- ADB (Android) or XCode (iOS) for logs
- File explorer for manual verification
- SQLite browser for database inspection
- Network monitoring tool (Wireshark, Charles Proxy)

## Success Criteria

Testing is considered successful when:

1. **All Priority 1 tests pass** (AUTO-001 through AUTO-007, THUMBS-001, THUMBS-006)
2. **No critical bugs found** (crashes, data loss, security issues)
3. **Performance acceptable** (< 5% battery drain, < 200MB memory)
4. **User experience smooth** (responsive UI, clear feedback)
5. **Database integrity maintained** (no corruption, migrations work)
6. **Network transitions handled gracefully** (no playback interruptions)

## Known Limitations

Document any known limitations discovered during testing:

1. **Queued downloads:** Currently, the queue processing is implemented but not fully persistent across app restarts
2. **Download cancellation:** May not immediately stop network requests
3. **Storage estimation:** App doesn't pre-calculate required storage
4. **Partial downloads:** Resume functionality depends on download service implementation

## Next Steps After Testing

1. **Bug Triage:** Prioritize and file issues found
2. **Performance Optimization:** Address any performance concerns
3. **Documentation Updates:** Update user docs based on test findings
4. **Regression Suite:** Add automated tests for critical paths
5. **User Acceptance:** Get feedback from beta users

---

**Document Version:** 1.0
**Last Updated:** 2025-10-15
**Next Review:** After Phase 4 completion
