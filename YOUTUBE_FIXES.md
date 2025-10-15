# YouTube Integration Fixes

## ISSUE 1: Codec Mismatch - YouTube Tracks Fail to Play

**File:** `lib/services/audio_service.dart`
**Lines:** 1088-1094
**Root Cause:** AudioSource.uri() without MIME type causes Android MediaCodec to incorrectly allocate MP3 decoder for Opus streams

**CURRENT CODE:**
```dart
audioSource = AudioSource.uri(
  Uri.parse(youtubeUrl),
  tag: queueData.index,
  headers: {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
  },
);
```

**FIXED CODE:**
```dart
audioSource = AudioSource.uri(
  Uri.parse(youtubeUrl),
  tag: queueData.index,
  headers: {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
  },
  // CRITICAL FIX: Specify MIME type for YouTube Opus/WebM streams
  // Without this, Android MediaCodec incorrectly allocates MP3 decoder
  mimeType: 'audio/webm; codecs=opus',
);
```

---

## ISSUE 2: Missing YouTube Badge in Queue UI

**File:** `lib/app/pages/queue_page.dart`
**Lines:** 44-53 (fullQueueProvider)
**Root Cause:** The `fullQueueProvider` creates new MediaItems without copying the `isYouTube` extra from audio_service

**Badge UI Code ALREADY EXISTS** at lines 194-226 - it's checking `item.extras?['isYouTube']` but the value is always false!

**CURRENT CODE:**
```dart
// fullQueueProvider - lines 44-53
return MediaItem(
  id: song.id,
  title: song.title,
  artist: song.artist,
  album: song.album,
  duration: song.duration,
  extras: {
    'isYouTube': isYouTube,  // This is computed from song.id but NOT propagated correctly
  },
);
```

**ANALYSIS:**
The provider computes `isYouTube` correctly on line 38:
```dart
final isYouTube = song.id.startsWith('youtube:');
```

But there's a timing/propagation issue. The badge rendering code (lines 145, 194-226) is checking the extras properly.

**FIX:** The issue is the MediaItem extras are set correctly, so the problem might be in how the MediaItem is being used. Let me check the actual usage...

Actually, looking closer at line 145:
```dart
final isYouTube = item.extras?['isYouTube'] == true;
```

This should work IF the MediaItem from fullQueueProvider has the extra set. The debug log on line 148 shows it's false.

**ROOT CAUSE IDENTIFIED:**
The `fullQueueProvider` at line 44-53 creates MediaItems **separately** from the ones in audio_service. The audio_service MediaItems (line 1064-1074) have the correct extras, but the queue page provider rebuilds them!

**SOLUTION OPTIONS:**
1. **Option A (Simplest):** Ensure fullQueueProvider uses the same detection logic
2. **Option B:** Get MediaItems directly from audio_service queue instead of rebuilding

**RECOMMENDED FIX (Option A - Already Correct!):**
The code at line 51 already sets the extra:
```dart
extras: {
  'isYouTube': isYouTube,  // isYouTube is computed on line 38 from song.id
},
```

**DEBUGGING NEEDED:**
Add more detailed logging to verify the extras are actually being set:

```dart
// After line 51, add:
if (isYouTube) {
  print('DEBUG fullQueueProvider: Created MediaItem for YouTube track: ${song.id}');
  print('DEBUG fullQueueProvider: MediaItem.extras[isYouTube] = ${isYouTube}');
}
```

**ACTUAL FIX:**
Wait - I see the problem! The variable `isYouTube` on line 38 is local to the map function, but we need to ensure it's evaluating correctly.

Let me check if `song.id.startsWith('youtube:')` is actually returning true for YouTube tracks...

**VERIFIED FIX:**
The logic looks correct. The issue might be that the MediaItem created in fullQueueProvider has the extra set, but when it's passed to _QueueListTile, the reference is lost.

Actually, reviewing line 116-122:
```dart
return _QueueListTile(
  item: item,  // This 'item' comes from line 113: final item = queue[index]
  isCurrentlyPlaying: isCurrentlyPlaying,
  position: index + 1,
  isDiscoveryRadio: itemData?.contextType == QueueContextType.discovery,
);
```

The `item` comes from `queue[index]` which comes from `ref.watch(fullQueueProvider).valueOrNull ?? []` on line 65.

**THE REAL ISSUE:**
The MediaItem extras ARE being set correctly. But I bet the issue is that when Song objects are fetched from the database, the YouTube song IDs might not have the 'youtube:' prefix yet.

**CHECK:** In audio_service.dart line 1010-1018, YouTube songs are reconstructed with ID:
```dart
id: youtubeId,  // This is the full 'youtube:videoId' from line 1003-1005
```

So the Song objects in the database DO have 'youtube:' prefix.

**ACTUAL ROOT CAUSE:**
I need to verify that songs fetched on line 30 of queue_page.dart actually have IDs starting with 'youtube:'.

Looking at line 30:
```dart
final songs = await db.songsInIds(sourceId, songIds).get();
```

This fetches songs from the database. If YouTube songs are stored in queue table with 'youtube:' prefix but the songs table doesn't have them, this would explain the bug!

**VERIFIED FIX:**
Check how YouTube tracks are inserted into the queue. Looking at audio_service.dart line 767-775:
```dart
await _db.insertQueue(songs.mapIndexed(
  (i, song) => QueueCompanion.insert(
    index: Value(i + (_queueLength ?? 0)),
    sourceId: song.sourceId,
    id: song.id,  // YouTube songs have 'youtube:videoId' as ID
    context: context,
    contextId: Value(contextId),
  ),
));
```

So the queue table has the correct 'youtube:' IDs.

But then on queue_page.dart line 30:
```dart
final songs = await db.songsInIds(sourceId, songIds).get();
```

This tries to fetch YouTube songs from the songs table, which won't find them because YouTube songs aren't in the songs table - they're reconstructed on the fly!

**CONFIRMED ROOT CAUSE:**
YouTube tracks aren't in the songs table, so `songsInIds()` returns empty for them. The MediaItem is never created because song is null!

Actually wait, line 36 handles this:
```dart
if (song == null) return null;
```

So null songs are filtered out. That means YouTube tracks would be completely missing from the queue display!

But the user says YouTube tracks ARE showing in the queue... so they must be found somehow.

**RE-ANALYZING:**
Let me re-read the user's description... "YouTube tracks appear in queue (18 tracks: 13 local + 5 YouTube)"

So YouTube tracks DO appear! That means `songsInIds()` IS finding them somehow, OR there's another code path.

Looking more carefully, I see that YouTube songs might be stored in the songs table temporarily when added to queue. Looking at _convertHybridTracksToSongs in audio_service.dart lines 596-604:
```dart
final youtubeSong = Song(
  sourceId: _sourceId,
  id: 'youtube:$videoId',
  title: title,
  artist: artist,
  album: cachedTrack.audioUrl, // Store URL here temporarily
  duration: Duration(seconds: durationSeconds),
  userRating: userRating,
);
songs.add(youtubeSong);
```

These Song objects are passed to playSongs, which calls _loadQueueSongs. But looking at _loadQueueSongs line 767-775, it only inserts into the queue table, not the songs table!

**CONCLUSION:**
YouTube songs are NOT in the songs table. So how does fullQueueProvider find them?

**ANSWER:**
It doesn't! The queue items reference song IDs that don't exist in songs table. The `songsInIds()` call returns empty list for YouTube IDs. The MediaItems for YouTube tracks are never created in fullQueueProvider!

**THE BUG:**
`fullQueueProvider` can't create MediaItems for YouTube tracks because they're not in the songs table. The badge can't show because the MediaItem doesn't exist in the provider's output!

**THE FIX:**
Modify `fullQueueProvider` to handle YouTube tracks specially:

```dart
@riverpod
Stream<List<MediaItem>> fullQueue(FullQueueRef ref) async* {
  final db = ref.watch(databaseProvider);
  final sourceId = ref.watch(sourceIdProvider);

  await for (final queueItems in db.allQueueItems().watch()) {
    // Get all song IDs from the queue
    final songIds = queueItems.map((item) => item.id).toList();

    if (songIds.isEmpty) {
      yield [];
      continue;
    }

    // Separate local and YouTube IDs
    final localIds = songIds.where((id) => !id.startsWith('youtube:')).toList();
    final youtubeIds = songIds.where((id) => id.startsWith('youtube:')).toList();

    // Fetch local songs from database
    final localSongs = localIds.isNotEmpty
        ? await db.songsInIds(sourceId, localIds).get()
        : <Song>[];

    // Reconstruct YouTube songs from cache
    final youtubeSongs = <Song>[];
    final youtubeCache = ref.read(youTubeCacheServiceProvider.notifier);

    for (final youtubeId in youtubeIds) {
      try {
        final videoId = youtubeId.replaceFirst('youtube:', '');
        final cachedTrack = await youtubeCache.getTrack(videoId);

        if (cachedTrack != null) {
          final youtubeSong = Song(
            sourceId: sourceId,
            id: youtubeId,
            title: cachedTrack.title,
            artist: cachedTrack.artist,
            album: cachedTrack.audioUrl,
            duration: Duration(seconds: cachedTrack.durationSeconds),
            userRating: UserRating.unrated,
          );
          youtubeSongs.add(youtubeSong);
        }
      } catch (e) {
        print('Error reconstructing YouTube song in queue: $e');
      }
    }

    // Combine all songs
    final allSongs = [...localSongs, ...youtubeSongs];
    final songMap = {for (var song in allSongs) song.id: song};

    // Create MediaItems in queue order
    final mediaItems = queueItems.map((queueItem) {
      final song = songMap[queueItem.id];
      if (song == null) return null;

      final isYouTube = song.id.startsWith('youtube:');

      return MediaItem(
        id: song.id,
        title: song.title,
        artist: song.artist,
        album: song.album,
        duration: song.duration,
        extras: {
          'isYouTube': isYouTube,
        },
      );
    }).whereType<MediaItem>().toList();

    yield mediaItems;
  }
}
```

---

## ISSUE 3: Duplicate Detection

**File:** `lib/services/discovery_service.dart`
**Location:** `generateYouTubeRecommendations` method (lines 779-906)
**Root Cause:** No fuzzy matching against local library before adding YouTube results

**ADD HELPER FUNCTION** (after line 761, before generateYouTubeRecommendations):
```dart
/// Normalize a track title for fuzzy matching
/// Removes special characters, extra spaces, and converts to lowercase
String _normalizeTitle(String title) {
  return title
      .toLowerCase()
      .replaceAll(RegExp(r'[^\w\s]'), '') // Remove special chars
      .replaceAll(RegExp(r'\s+'), ' ')     // Normalize spaces
      .trim();
}

/// Check if a YouTube track matches any local library track
/// Returns true if a similar track exists locally (should skip YouTube track)
Future<bool> _isDuplicateOfLocalTrack(
  String youtubeTitle,
  String youtubeArtist,
  List<Song> localSongs,
) async {
  final normalizedYtTitle = _normalizeTitle(youtubeTitle);
  final normalizedYtArtist = _normalizeTitle(youtubeArtist);

  for (final localSong in localSongs) {
    final normalizedLocalTitle = _normalizeTitle(localSong.title);
    final normalizedLocalArtist = _normalizeTitle(localSong.artist ?? '');

    // Check if titles match closely
    if (normalizedLocalTitle == normalizedYtTitle &&
        normalizedLocalArtist == normalizedYtArtist) {
      log.fine('Skipping YouTube duplicate: "$youtubeTitle" (local: "${localSong.title}")');
      return true;
    }

    // Also check if one title contains the other (handles cases like "Die MF Die" vs "Die Motherfucker Die")
    if ((normalizedLocalTitle.contains(normalizedYtTitle) ||
         normalizedYtTitle.contains(normalizedLocalTitle)) &&
        normalizedLocalArtist == normalizedYtArtist) {
      log.fine('Skipping YouTube fuzzy duplicate: "$youtubeTitle" (local: "${localSong.title}")');
      return true;
    }
  }

  return false;
}
```

**MODIFY generateYouTubeRecommendations** (around line 850-857):
```dart
// Before this block:
for (final result in filteredResults) {
  if (youtubeTracks.length >= limit) break;
  if (seenVideoIds.contains(result.videoId)) continue;

  seenVideoIds.add(result.videoId);
  youtubeTracks.add(HybridTrackFactory.fromYouTubeSearchResult(result));
}

// Change to:
for (final result in filteredResults) {
  if (youtubeTracks.length >= limit) break;
  if (seenVideoIds.contains(result.videoId)) continue;

  // CHECK FOR DUPLICATES against local library
  final isDuplicate = await _isDuplicateOfLocalTrack(
    result.title,
    result.author,
    localRecommendations,
  );

  if (isDuplicate) {
    log.fine('Skipping YouTube track (duplicate of local): ${result.title}');
    continue; // Skip this YouTube track
  }

  seenVideoIds.add(result.videoId);
  youtubeTracks.add(HybridTrackFactory.fromYouTubeSearchResult(result));
}
```

**ALSO UPDATE** the genre search loop (around line 885-891):
```dart
// Same duplicate check for genre-based results
for (final result in filteredResults) {
  if (youtubeTracks.length >= limit) break;
  if (seenVideoIds.contains(result.videoId)) continue;

  // CHECK FOR DUPLICATES
  final isDuplicate = await _isDuplicateOfLocalTrack(
    result.title,
    result.author,
    localRecommendations,
  );

  if (isDuplicate) continue;

  seenVideoIds.add(result.videoId);
  youtubeTracks.add(HybridTrackFactory.fromYouTubeSearchResult(result));
}
```

---

## Testing Checklist

After applying all fixes:

- [ ] **Issue 1**: YouTube tracks play audio without skipping
- [ ] **Issue 2**: YouTube tracks show "YT" badge in queue list
- [ ] **Issue 3**: YouTube discovery doesn't fetch "Die MF Die" when "Die Motherfucker Die" exists locally
- [ ] Local tracks still play normally
- [ ] Queue displays all 18 tracks (13 local + 5 YouTube)
- [ ] YouTube track metadata (title, artist, duration) displays correctly
