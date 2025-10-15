# Discovery Radio Implementation

This document outlines the implementation of Discovery Radio functionality in Subtracks, providing intelligent playlist generation based on user preferences and song similarity algorithms.

## Overview

Discovery Radio enhances the existing radio mode to build intelligent playlists based on a seed song, artist, or genre. It uses multiple recommendation algorithms combined with user preference learning to create personalized music discovery experiences.

## Architecture

### Core Components

1. **DiscoveryService** (`lib/services/discovery_service.dart`)
   - Core recommendation engine
   - Multiple similarity algorithms
   - User preference learning
   - Analytics and tracking

2. **Enhanced AudioService** (`lib/services/audio_service.dart`)
   - Integration with discovery service
   - Discovery radio playback methods
   - Offline/online mode handling

3. **Database Extensions** (`lib/database/tables.drift`)
   - Discovery session tracking tables
   - Interaction logging
   - Performance analytics

## Features

### 1. Recommendation Algorithms

#### Artist Similarity
- **Same Artist**: Highest weight for songs by the same artist
- **Genre Overlap**: Artists with similar genres get medium weight
- **User Preference**: Artists with thumbs-up songs get high weight

#### Genre-Based Recommendations
- **Exact Match**: Same genre songs get highest similarity
- **Related Genres**: Predefined genre relationships (rock → alternative, etc.)
- **Configurable Weights**: Adjustable similarity scoring

#### User Preference Learning
- **Thumbs Up**: 1.0 weight (highest preference)
- **Unrated**: 0.5 weight (neutral)
- **Thumbs Down**: 0.0 weight (excluded from recommendations)

#### Metadata Correlation
- **Duration Similarity**: Songs within 30% duration difference
- **Album Correlation**: Songs from the same album
- **Configurable Weights**: Adjustable correlation scoring

### 2. Discovery Modes

#### Online Mode
- Access to full music library
- All available songs for recommendations
- Best recommendation diversity

#### Offline Mode
- Downloaded songs only (`downloadFilePath != null`)
- Perfect for offline listening
- Maintains quality recommendations from available content

### 3. Smart Sampling

The recommendation engine uses intelligent sampling to balance quality with diversity:

- **Top 20%**: Guaranteed high-quality picks
- **Score Buckets**: Remaining slots filled from different score ranges
- **Diversity**: Prevents clustering around single similarity type
- **Randomization**: Maintains freshness in recommendations

### 4. Session Tracking

Every discovery session is tracked for analytics and improvement:

```sql
discovery_sessions:
- id, seed_song_id, seed_artist, seed_genre
- source_id, mode, playlist_size, created_at

discovery_interactions:
- session_id, song_id, action, position_in_playlist
- song_duration_ms, play_duration_ms, timestamp
```

## Usage Examples

### Basic Discovery Radio

```dart
// Start discovery radio from current song
await audioControl.playDiscoveryRadio(
  seedSong: currentSong,
  mode: DiscoveryMode.online,
  playlistSize: 50,
);
```

### Artist-Based Discovery

```dart
// Start discovery radio based on artist
await audioControl.playDiscoveryRadioByArtist(
  artistId: 'artist-id',
  mode: DiscoveryMode.online,
  playlistSize: 40,
);
```

### Genre-Based Discovery

```dart
// Start discovery radio based on genre
await audioControl.playDiscoveryRadioByGenre(
  genre: 'Rock',
  mode: DiscoveryMode.online,
  playlistSize: 35,
);
```

### Offline Discovery

```dart
// Start offline discovery radio
await audioControl.playDiscoveryRadio(
  seedSong: seedSong,
  mode: DiscoveryMode.offline,
  playlistSize: 25,
);
```

### Custom Configuration

```dart
// Personalized discovery with high user preference weight
const personalizedConfig = DiscoveryConfig(
  artistSimilarityWeight: 0.20,
  genreSimilarityWeight: 0.15,
  userPreferenceWeight: 0.55,
  metadataCorrelationWeight: 0.10,
);

final recommendations = await discoveryService.generateSimilarSongs(
  seedSong,
  config: personalizedConfig,
);
```

## Database Schema

### Discovery Sessions Table

```sql
CREATE TABLE discovery_sessions(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  seed_song_id TEXT NOT NULL,
  seed_artist TEXT,
  seed_genre TEXT,
  source_id INT NOT NULL,
  mode TEXT NOT NULL, -- 'online' or 'offline'
  playlist_size INT NOT NULL DEFAULT 50,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP)),
  FOREIGN KEY (source_id) REFERENCES sources (id) ON DELETE CASCADE
);
```

### Discovery Interactions Table

```sql
CREATE TABLE discovery_interactions(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id INTEGER NOT NULL,
  song_id TEXT NOT NULL,
  action TEXT NOT NULL, -- 'played', 'skipped', 'thumbs_up', 'thumbs_down', 'completed'
  position_in_playlist INTEGER NOT NULL,
  song_duration_ms INTEGER,
  play_duration_ms INTEGER,
  timestamp INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP)),
  FOREIGN KEY (session_id) REFERENCES discovery_sessions (id) ON DELETE CASCADE
);
```

## Analytics and Insights

### Discovery Analytics

```dart
final analytics = await discoveryService.getDiscoveryAnalytics(
  sourceId,
  period: Duration(days: 30),
);

// Returns:
// {
//   'total_sessions': 45,
//   'average_playlist_size': 42.3,
//   'popular_songs': [...],
//   'frequently_skipped': [...],
//   'mode_distribution': {'online': 40, 'offline': 5}
// }
```

### Available Queries

- `discoverySessionsBySource`: Get sessions for a source
- `discoveryInteractionsBySession`: Get interactions for a session
- `discoveryRecentSessions`: Get recent sessions
- `discoveryPopularSongs`: Get popular discovered songs
- `discoverySkippedSongs`: Get frequently skipped songs

## Configuration Options

### DiscoveryConfig Parameters

```dart
class DiscoveryConfig {
  final int maxRecommendations;           // Default: 50
  final double artistSimilarityWeight;    // Default: 0.35
  final double genreSimilarityWeight;     // Default: 0.25
  final double userPreferenceWeight;      // Default: 0.30
  final double metadataCorrelationWeight; // Default: 0.10
  final bool avoidRecentlyPlayed;         // Default: true
  final Duration recentPlayedWindow;      // Default: 2 hours
}
```

### Weight Normalization

All weights are automatically normalized to sum to 1.0, ensuring consistent scoring regardless of input values.

## Integration Points

### Audio Service Integration

The discovery radio integrates seamlessly with the existing audio service:

- Uses existing `playSongs()` method for playback
- Maintains queue management and state
- Supports all existing audio controls (shuffle, repeat, etc.)
- Works with offline downloading system

### Rating Service Integration

Discovery radio automatically excludes thumbs-down songs and prefers thumbs-up songs:

- Filters out `UserRating.thumbsDown` songs
- Weights `UserRating.thumbsUp` songs higher
- Responds to rating changes during playback

### UI Integration

Ready for UI integration with:
- Song action menus (Start Discovery Radio)
- Player controls (Discovery Mode toggle)
- Settings screens (Algorithm configuration)
- Analytics dashboards (Discovery insights)

## Performance Considerations

### Caching

- **Genre Relationships**: Cached to avoid repeated calculations
- **Artist Similarity**: Cached between songs from same artists
- **Recommendation Results**: Can be cached for repeated requests

### Database Optimization

- Indexed tables for fast lookups
- Efficient queries with proper joins
- Background processing for analytics

### Memory Management

- Streaming-based song processing
- Limited in-memory caches
- Cleanup of old session data

## Future Enhancements

### Phase 1 Improvements

1. **Machine Learning**: Train models on user interaction data
2. **Collaborative Filtering**: Use community listening patterns
3. **Time-based Preferences**: Consider listening time patterns
4. **Mood Detection**: Analyze audio features for mood matching

### Phase 2 Features

1. **External Integration**: YouTube-dl recommendations
2. **Social Features**: Friend-based recommendations
3. **Context Awareness**: Location/activity-based suggestions
4. **Advanced Analytics**: Detailed recommendation performance metrics

### Phase 3 Extensions

1. **Real-time Learning**: Immediate algorithm updates
2. **Cross-platform Sync**: Sync discovery preferences
3. **API Integration**: External music service recommendations
4. **AI-powered Insights**: Advanced user preference analysis

## Testing

### Unit Tests

Comprehensive test coverage for:
- Recommendation algorithms
- Score calculations
- Edge cases and error handling
- Configuration normalization

### Integration Tests

- End-to-end discovery radio flow
- Database integration
- Audio service integration
- Offline mode functionality

### Mock Data

Test helpers provide realistic data for:
- Song libraries with various genres
- User rating distributions
- Downloaded song scenarios
- Discovery session simulations

## Error Handling

### Graceful Degradation

- **No Recommendations**: Falls back to seed song only
- **Database Errors**: Continues without tracking
- **Missing Metadata**: Uses available information only
- **Network Issues**: Automatic offline mode detection

### Logging

- Detailed logging for debugging
- Performance metrics tracking
- Error reporting and recovery
- User interaction insights

## Security and Privacy

### Data Protection

- No sensitive user data in discovery tables
- Anonymous song interaction tracking
- Local database storage only
- Optional analytics disable

### Performance Impact

- Minimal impact on playback performance
- Background processing for recommendations
- Efficient database operations
- Memory-conscious implementation

## Migration Path

### Database Migration

The implementation includes automatic migration from schema version 2 to 3:

```dart
if (from < 3) {
  await migrator.createTable(discoverySessions);
  await migrator.createTable(discoveryInteractions);
}
```

### Backward Compatibility

- Existing radio mode unchanged
- Optional discovery features
- Graceful fallback for missing data
- Progressive enhancement approach

## API Documentation

### DiscoveryService Methods

- `generateSimilarSongs()`: Core recommendation engine
- `buildDiscoveryPlaylist()`: Complete playlist generation
- `getArtistSimilarSongs()`: Artist-based recommendations
- `getGenreSimilarSongs()`: Genre-based recommendations
- `getUserPreferenceWeightedSongs()`: Preference-based recommendations
- `recordSongPlayed()`: Track song playback
- `recordSongSkipped()`: Track song skips
- `recordSongCompleted()`: Track song completion
- `recordSongRated()`: Track rating changes
- `getDiscoveryAnalytics()`: Get analytics data

### AudioControl Methods

- `playDiscoveryRadio()`: Start discovery radio
- `playDiscoveryRadioByArtist()`: Start artist-based discovery
- `playDiscoveryRadioByGenre()`: Start genre-based discovery

### Database Methods

- `createDiscoverySession()`: Create tracking session
- `recordDiscoveryInteraction()`: Record user interaction
- `getDiscoverySessions()`: Retrieve sessions
- `getDiscoveryInteractions()`: Retrieve interactions
- `getDiscoveryPopularSongs()`: Get popular songs
- `getDiscoverySkippedSongs()`: Get skipped songs

This implementation provides a solid foundation for intelligent music discovery while maintaining the simplicity and performance of the existing Subtracks application.