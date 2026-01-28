/// Example usage of Discovery Radio functionality
///
/// This file demonstrates how to integrate and use the Discovery Radio features
/// in the Subtracks application.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/music.dart';
import '../services/audio_service.dart';
import '../services/discovery_service.dart';

/// Example widget showing how to integrate Discovery Radio controls
class DiscoveryRadioExample extends ConsumerWidget {
  const DiscoveryRadioExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discovery Radio Example')),
      body: Column(
        children: [
          // Example: Start Discovery Radio from current song
          ElevatedButton(
            onPressed: () => _startDiscoveryFromCurrentSong(ref),
            child: const Text('Start Discovery Radio'),
          ),

          // Example: Start Discovery Radio in offline mode
          ElevatedButton(
            onPressed: () => _startOfflineDiscoveryRadio(ref),
            child: const Text('Start Offline Discovery Radio'),
          ),

          // Example: Start Discovery Radio by artist
          ElevatedButton(
            onPressed: () => _startArtistDiscoveryRadio(ref),
            child: const Text('Artist Discovery Radio'),
          ),

          // Example: Start Discovery Radio by genre
          ElevatedButton(
            onPressed: () => _startGenreDiscoveryRadio(ref),
            child: const Text('Genre Discovery Radio'),
          ),

          // Example: View Discovery Analytics
          ElevatedButton(
            onPressed: () => _showDiscoveryAnalytics(context, ref),
            child: const Text('View Discovery Analytics'),
          ),
        ],
      ),
    );
  }

  /// Start Discovery Radio from the currently playing song
  Future<void> _startDiscoveryFromCurrentSong(WidgetRef ref) async {
    final audioControl = ref.read(audioControlProvider);
    final currentMediaItem = audioControl.mediaItem.value;

    if (currentMediaItem == null) {
      // No song currently playing - could show an error or pick a random seed
      print('No song currently playing');
      return;
    }

    // Create a Song object from the current media item
    // In a real implementation, you'd have a method to convert MediaItem to Song
    final seedSong = Song(
      sourceId: currentMediaItem.data.sourceId,
      id: currentMediaItem.id,
      title: currentMediaItem.title,
      artist: currentMediaItem.artist,
      album: currentMediaItem.album,
      duration: currentMediaItem.duration,
    );

    // Start Discovery Radio
    await audioControl.playDiscoveryRadio(
      seedSong: seedSong,
      mode: DiscoveryMode.online,
      playlistSize: 50,
    );

    print('Started Discovery Radio with seed: ${seedSong.title}');
  }

  /// Start Discovery Radio in offline mode (downloaded songs only)
  Future<void> _startOfflineDiscoveryRadio(WidgetRef ref) async {
    final audioControl = ref.read(audioControlProvider);

    // For this example, we'll use a placeholder seed song
    // In a real app, you'd pick from available downloaded songs
    final seedSong = Song(
      sourceId: 1,
      id: 'offline-seed',
      title: 'Offline Seed Song',
      artist: 'Local Artist',
      downloadFilePath: '/path/to/downloaded/song.mp3',
    );

    await audioControl.playDiscoveryRadio(
      seedSong: seedSong,
      mode: DiscoveryMode.offline,
      playlistSize: 25, // Smaller playlist for offline mode
    );

    print('Started Offline Discovery Radio');
  }

  /// Start Discovery Radio based on a specific artist
  Future<void> _startArtistDiscoveryRadio(WidgetRef ref) async {
    final audioControl = ref.read(audioControlProvider);

    // Example artist ID - in a real app, this would come from user selection
    const artistId = 'example-artist-id';

    await audioControl.playDiscoveryRadioByArtist(
      artistId: artistId,
      mode: DiscoveryMode.online,
      playlistSize: 40,
    );

    print('Started Artist Discovery Radio for artist: $artistId');
  }

  /// Start Discovery Radio based on a specific genre
  Future<void> _startGenreDiscoveryRadio(WidgetRef ref) async {
    final audioControl = ref.read(audioControlProvider);

    // Example genre - in a real app, this would come from user selection
    const genre = 'Rock';

    await audioControl.playDiscoveryRadioByGenre(
      genre: genre,
      mode: DiscoveryMode.online,
      playlistSize: 35,
    );

    print('Started Genre Discovery Radio for genre: $genre');
  }

  /// Show Discovery Analytics
  Future<void> _showDiscoveryAnalytics(
      BuildContext context, WidgetRef ref) async {
    final discoveryService = ref.read(discoveryServiceProvider);

    // Get analytics for the last 30 days
    final analytics = await discoveryService.getDiscoveryAnalytics(
      1, // source ID
      period: const Duration(days: 30),
    );

    if (!context.mounted) return;

    // Show analytics in a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discovery Analytics'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total Sessions: ${analytics['total_sessions'] ?? 0}'),
              Text(
                  'Average Playlist Size: ${analytics['average_playlist_size']?.toStringAsFixed(1) ?? '0'}'),
              const SizedBox(height: 16),
              const Text('Mode Distribution:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...((analytics['mode_distribution'] as Map<String, int>?)
                          ?.entries ??
                      [])
                  .map((entry) => Text('${entry.key}: ${entry.value}')),
              const SizedBox(height: 16),
              const Text('Top Discovered Songs:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...((analytics['popular_songs'] as List?)?.take(5) ?? []).map(
                  (song) =>
                      Text('${song['song_id']} (${song['play_count']} plays)')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Example of custom discovery configuration
class CustomDiscoveryExample {
  static Future<void> startPersonalizedDiscovery(
      WidgetRef ref, Song seedSong) async {
    final discoveryService = ref.read(discoveryServiceProvider);

    // Create a custom configuration that heavily weights user preferences
    const personalizedConfig = DiscoveryConfig(
      artistSimilarityWeight: 0.20,
      genreSimilarityWeight: 0.15,
      userPreferenceWeight: 0.55, // Much higher weight for user ratings
      metadataCorrelationWeight: 0.10,
      maxRecommendations: 30,
      avoidRecentlyPlayed: true,
    );

    // Generate recommendations with custom config
    final recommendations = await discoveryService.generateSimilarSongs(
      seedSong,
      limit: 30,
      mode: DiscoveryMode.online,
      config: personalizedConfig,
    );

    print('Generated ${recommendations.length} personalized recommendations');
  }

  /// Example: Discovery Radio for exploration (more diverse recommendations)
  static Future<void> startExplorationDiscovery(
      WidgetRef ref, Song seedSong) async {
    final discoveryService = ref.read(discoveryServiceProvider);

    // Configuration that prioritizes diversity over user preferences
    const explorationConfig = DiscoveryConfig(
      artistSimilarityWeight: 0.30,
      genreSimilarityWeight: 0.40, // Higher genre variety
      userPreferenceWeight:
          0.20, // Lower user preference weight for exploration
      metadataCorrelationWeight: 0.10,
      maxRecommendations: 50,
      avoidRecentlyPlayed: true,
    );

    final recommendations = await discoveryService.generateSimilarSongs(
      seedSong,
      limit: 50,
      mode: DiscoveryMode.online,
      config: explorationConfig,
    );

    print('Generated ${recommendations.length} exploration recommendations');
  }
}

/// Example of tracking discovery interactions
class DiscoveryTrackingExample {
  /// Example: Track user interactions during discovery playback
  static void setupDiscoveryTracking(WidgetRef ref) {
    final discoveryService = ref.read(discoveryServiceProvider);
    final audioControl = ref.read(audioControlProvider);

    // Listen to audio position to track song completion
    audioControl.position.listen((position) {
      final currentSong = audioControl.mediaItem.value;
      if (currentSong != null && currentSong.duration != null) {
        final completionPercentage =
            position.inMilliseconds / currentSong.duration!.inMilliseconds;

        // If song is 80% complete, consider it "completed"
        if (completionPercentage >= 0.8) {
          // Record completion (you'd need to track position in playlist)
          discoveryService.recordSongCompleted(
            _mediaItemToSong(currentSong),
            0, // position in playlist - would need to track this
            position.inMilliseconds,
          );
        }
      }
    });

    // Listen to track changes to detect skips
    audioControl.mediaItem.listen((mediaItem) {
      if (mediaItem != null) {
        // Record that song started playing
        discoveryService.recordSongPlayed(
          _mediaItemToSong(mediaItem),
          0, // position in playlist
        );
      }
    });
  }

  /// Helper to convert MediaItem to Song
  static Song _mediaItemToSong(dynamic mediaItem) {
    // This is a simplified conversion - in reality you'd use the MediaItem.data
    return Song(
      sourceId: 1,
      id: mediaItem.id,
      title: mediaItem.title,
      artist: mediaItem.artist,
      album: mediaItem.album,
      duration: mediaItem.duration,
    );
  }
}

/// Example usage in a playlist or song list widget
class SongListWithDiscoveryExample extends ConsumerWidget {
  final List<Song> songs;

  const SongListWithDiscoveryExample({super.key, required this.songs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return ListTile(
          title: Text(song.title),
          subtitle: Text(song.artist ?? 'Unknown Artist'),
          trailing: PopupMenuButton<String>(
            onSelected: (action) => _handleSongAction(ref, song, action),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'play',
                child: Text('Play'),
              ),
              const PopupMenuItem(
                value: 'discovery',
                child: Text('Start Discovery Radio'),
              ),
              const PopupMenuItem(
                value: 'discovery_offline',
                child: Text('Start Offline Discovery'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleSongAction(WidgetRef ref, Song song, String action) async {
    final audioControl = ref.read(audioControlProvider);

    switch (action) {
      case 'play':
        // Play the song normally
        break;
      case 'discovery':
        await audioControl.playDiscoveryRadio(
          seedSong: song,
          mode: DiscoveryMode.online,
        );
        break;
      case 'discovery_offline':
        await audioControl.playDiscoveryRadio(
          seedSong: song,
          mode: DiscoveryMode.offline,
        );
        break;
    }
  }
}

/// Example of using Discovery Radio preferences in settings
class DiscoverySettingsExample extends StatefulWidget {
  const DiscoverySettingsExample({super.key});

  @override
  State<DiscoverySettingsExample> createState() =>
      _DiscoverySettingsExampleState();
}

class _DiscoverySettingsExampleState extends State<DiscoverySettingsExample> {
  double artistWeight = 0.35;
  double genreWeight = 0.25;
  double preferenceWeight = 0.30;
  double metadataWeight = 0.10;
  int playlistSize = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discovery Settings')),
      body: Column(
        children: [
          ListTile(
            title: const Text('Artist Similarity Weight'),
            subtitle: Slider(
              value: artistWeight,
              onChanged: (value) => setState(() => artistWeight = value),
              min: 0.0,
              max: 1.0,
            ),
          ),
          ListTile(
            title: const Text('Genre Similarity Weight'),
            subtitle: Slider(
              value: genreWeight,
              onChanged: (value) => setState(() => genreWeight = value),
              min: 0.0,
              max: 1.0,
            ),
          ),
          ListTile(
            title: const Text('User Preference Weight'),
            subtitle: Slider(
              value: preferenceWeight,
              onChanged: (value) => setState(() => preferenceWeight = value),
              min: 0.0,
              max: 1.0,
            ),
          ),
          ListTile(
            title: const Text('Metadata Correlation Weight'),
            subtitle: Slider(
              value: metadataWeight,
              onChanged: (value) => setState(() => metadataWeight = value),
              min: 0.0,
              max: 1.0,
            ),
          ),
          ListTile(
            title: const Text('Playlist Size'),
            subtitle: Slider(
              value: playlistSize.toDouble(),
              onChanged: (value) =>
                  setState(() => playlistSize = value.round()),
              min: 10,
              max: 100,
              divisions: 18,
              label: playlistSize.toString(),
            ),
          ),
          ElevatedButton(
            onPressed: _saveSettings,
            child: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    // Save the custom discovery configuration to user preferences
    final config = DiscoveryConfig(
      artistSimilarityWeight: artistWeight,
      genreSimilarityWeight: genreWeight,
      userPreferenceWeight: preferenceWeight,
      metadataCorrelationWeight: metadataWeight,
      maxRecommendations: playlistSize,
    );

    print('Saved discovery config: $config');
    // In a real app, you'd save this to SharedPreferences or a settings service
  }
}
