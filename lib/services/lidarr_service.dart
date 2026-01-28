import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/database.dart';
import '../exceptions/lidarr_exceptions.dart';
import '../log.dart';
import '../models/lidarr_models.dart';

part 'lidarr_service.g.dart';

@Riverpod(keepAlive: true)
class LidarrService extends _$LidarrService {
  static const String baseUrl = 'https://lidarr.404oak.com/api/v1';
  static const String apiKey = '97559dd2947143288c213cdc170f3444';

  late final http.Client _http;
  SubtracksDatabase get _db => ref.read(databaseProvider);

  @override
  void build() {
    _http = http.Client();
    ref.onDispose(() {
      _http.close();
    });
  }

  /// Search for artist in Lidarr/MusicBrainz
  Future<List<LidarrArtist>> searchArtist(String artistName) async {
    try {
      log.info('Lidarr: Searching for artist: $artistName');

      final uri = Uri.parse('$baseUrl/artist/lookup').replace(
        queryParameters: {'term': artistName},
      );

      final response = await _http.get(
        uri,
        headers: {'X-Api-Key': apiKey},
      );

      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        final artists = json
            .map((e) => LidarrArtist.fromJson(e as Map<String, dynamic>))
            .toList();
        log.info('Lidarr: Found ${artists.length} results for: $artistName');
        return artists;
      } else {
        log.warning(
            'Lidarr: Search failed with status ${response.statusCode}: ${response.body}');
        throw LidarrApiException(
          'Failed to search artist',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is LidarrException) rethrow;
      log.severe('Lidarr: Search error for $artistName', e, stackTrace);
      throw LidarrNetworkException(
        'Network error while searching for artist',
        e,
        stackTrace,
      );
    }
  }

  /// Add artist to Lidarr for monitoring and download
  Future<LidarrArtist> addArtist({
    required String artistName,
    required String foreignArtistId,
    int qualityProfileId = 1,
    int metadataProfileId = 1,
    String rootFolderPath = '/music',
  }) async {
    try {
      log.info(
          'Lidarr: Adding artist to library: $artistName (MusicBrainz: $foreignArtistId)');

      final uri = Uri.parse('$baseUrl/artist');

      final body = {
        'artistName': artistName,
        'foreignArtistId': foreignArtistId,
        'qualityProfileId': qualityProfileId,
        'metadataProfileId': metadataProfileId,
        'monitored': true,
        'rootFolderPath': rootFolderPath,
        'addOptions': {
          'searchForMissingAlbums': true,
          'monitor': 'all', // Monitor all albums
        },
      };

      final response = await _http.post(
        uri,
        headers: {
          'X-Api-Key': apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log.info('Lidarr: Successfully added artist: $artistName');
        return LidarrArtist.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        final errorBody = response.body;
        log.warning(
            'Lidarr: Failed to add artist (${response.statusCode}): $errorBody');
        throw LidarrApiException(
          'Failed to add artist: $errorBody',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is LidarrException) rethrow;
      log.severe('Lidarr: Error adding artist $artistName', e, stackTrace);
      throw LidarrNetworkException(
        'Network error while adding artist',
        e,
        stackTrace,
      );
    }
  }

  /// Check if artist is already in Lidarr library
  Future<bool> isArtistInLibrary(String foreignArtistId) async {
    try {
      final uri = Uri.parse('$baseUrl/artist');

      final response = await _http.get(
        uri,
        headers: {'X-Api-Key': apiKey},
      );

      if (response.statusCode == 200) {
        final List<dynamic> artists = jsonDecode(response.body);
        final exists = artists.any((a) =>
            a is Map<String, dynamic> &&
            a['foreignArtistId'] == foreignArtistId);
        log.fine(
            'Lidarr: Artist $foreignArtistId ${exists ? "exists" : "does not exist"} in library');
        return exists;
      }

      log.warning('Lidarr: Failed to check library (${response.statusCode})');
      return false;
    } catch (e, stackTrace) {
      log.warning('Lidarr: Error checking library', e, stackTrace);
      return false;
    }
  }

  /// Request download for YouTube track
  ///
  /// Extracts artist/track info, searches Lidarr, and adds if not present
  Future<LidarrDownloadResult> requestDownload({
    required String youtubeTitle,
    required String youtubeArtist,
    required String videoId,
  }) async {
    try {
      log.info(
          'Lidarr: Requesting download for "$youtubeTitle" by $youtubeArtist');

      // Clean artist name (remove featuring, etc.)
      final cleanArtist = _cleanArtistName(youtubeArtist);
      log.fine(
          'Lidarr: Cleaned artist name: "$youtubeArtist" -> "$cleanArtist"');

      // Search for artist
      final searchResults = await searchArtist(cleanArtist);

      if (searchResults.isEmpty) {
        log.warning('Lidarr: No results found for artist: $cleanArtist');

        // Track failed request in database
        await _recordLidarrRequest(
          youtubeVideoId: videoId,
          artistName: cleanArtist,
          foreignArtistId: null,
          status: 'not_found',
          errorMessage: 'Artist not found in MusicBrainz',
        );

        return LidarrDownloadResult.notFound(
          message: 'Artist "$cleanArtist" not found in MusicBrainz',
        );
      }

      // Use first result (best match)
      final artist = searchResults.first;
      log.info(
          'Lidarr: Best match: ${artist.artistName} (${artist.foreignArtistId})');

      // Check if already in library
      final alreadyExists = await isArtistInLibrary(artist.foreignArtistId);

      if (alreadyExists) {
        log.info('Lidarr: Artist already in library: ${artist.artistName}');

        // Track that it already exists
        await _recordLidarrRequest(
          youtubeVideoId: videoId,
          artistName: cleanArtist,
          foreignArtistId: artist.foreignArtistId,
          status: 'already_exists',
        );

        return LidarrDownloadResult.alreadyExists(
          artistName: artist.artistName,
          message: '${artist.artistName} is already in your library',
        );
      }

      // Add artist to Lidarr
      final addedArtist = await addArtist(
        artistName: artist.artistName,
        foreignArtistId: artist.foreignArtistId,
      );

      log.info('Lidarr: Successfully added artist: ${addedArtist.artistName}');

      // Track successful request in database
      await _recordLidarrRequest(
        youtubeVideoId: videoId,
        artistName: cleanArtist,
        foreignArtistId: artist.foreignArtistId,
        status: 'added',
      );

      return LidarrDownloadResult.success(
        artistName: addedArtist.artistName,
        foreignArtistId: artist.foreignArtistId,
        message: '${addedArtist.artistName} added to Lidarr for download',
      );
    } catch (e, stackTrace) {
      log.severe('Lidarr: Failed to request download for "$youtubeTitle"', e,
          stackTrace);

      // Track failed request
      await _recordLidarrRequest(
        youtubeVideoId: videoId,
        artistName: youtubeArtist,
        foreignArtistId: null,
        status: 'failed',
        errorMessage: e.toString(),
      );

      return LidarrDownloadResult.error(
        message: 'Failed to add to Lidarr: ${e.toString()}',
        error: e,
      );
    }
  }

  /// Clean artist name for better search results
  String _cleanArtistName(String artist) {
    // Remove common patterns that interfere with artist matching
    var cleaned = artist;

    // Remove featuring/ft patterns with everything after
    cleaned = cleaned.replaceAll(
        RegExp(r'\s*\(feat\..*\)', caseSensitive: false), '');
    cleaned =
        cleaned.replaceAll(RegExp(r'\s*\(ft\..*\)', caseSensitive: false), '');
    cleaned =
        cleaned.replaceAll(RegExp(r'\s*feat\..*', caseSensitive: false), '');
    cleaned =
        cleaned.replaceAll(RegExp(r'\s*ft\..*', caseSensitive: false), '');

    // Remove featuring with comma separator
    cleaned =
        cleaned.replaceAll(RegExp(r',\s*feat\..*', caseSensitive: false), '');
    cleaned =
        cleaned.replaceAll(RegExp(r',\s*ft\..*', caseSensitive: false), '');

    // Remove "VEVO" suffix
    cleaned =
        cleaned.replaceAll(RegExp(r'\s*-?\s*VEVO$', caseSensitive: false), '');

    // Remove " - Topic" suffix (YouTube auto-generated channels)
    cleaned =
        cleaned.replaceAll(RegExp(r'\s*-\s*Topic$', caseSensitive: false), '');

    // Clean up extra whitespace
    cleaned = cleaned.trim();

    return cleaned;
  }

  /// Record a Lidarr download request in the database
  Future<void> _recordLidarrRequest({
    required String youtubeVideoId,
    required String artistName,
    required String? foreignArtistId,
    required String status,
    String? errorMessage,
  }) async {
    try {
      await _db.recordLidarrRequest(
        youtubeVideoId: youtubeVideoId,
        artistName: artistName,
        foreignArtistId: foreignArtistId,
        status: status,
        errorMessage: errorMessage,
      );
    } catch (e, stackTrace) {
      log.warning('Failed to record Lidarr request in database', e, stackTrace);
      // Don't throw - this is a secondary operation
    }
  }

  /// Get quality profiles from Lidarr
  Future<List<LidarrQualityProfile>> getQualityProfiles() async {
    try {
      final uri = Uri.parse('$baseUrl/qualityprofile');

      final response = await _http.get(
        uri,
        headers: {'X-Api-Key': apiKey},
      );

      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        return json
            .map(
                (e) => LidarrQualityProfile.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw LidarrApiException(
          'Failed to get quality profiles',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is LidarrException) rethrow;
      log.severe('Lidarr: Error getting quality profiles', e, stackTrace);
      throw LidarrNetworkException(
        'Network error while getting quality profiles',
        e,
        stackTrace,
      );
    }
  }

  /// Get root folders from Lidarr
  Future<List<LidarrRootFolder>> getRootFolders() async {
    try {
      final uri = Uri.parse('$baseUrl/rootfolder');

      final response = await _http.get(
        uri,
        headers: {'X-Api-Key': apiKey},
      );

      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        return json
            .map((e) => LidarrRootFolder.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw LidarrApiException(
          'Failed to get root folders',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is LidarrException) rethrow;
      log.severe('Lidarr: Error getting root folders', e, stackTrace);
      throw LidarrNetworkException(
        'Network error while getting root folders',
        e,
        stackTrace,
      );
    }
  }

  /// Test connection to Lidarr
  Future<bool> testConnection() async {
    try {
      final uri = Uri.parse('$baseUrl/system/status');

      final response = await _http.get(
        uri,
        headers: {'X-Api-Key': apiKey},
      );

      if (response.statusCode == 200) {
        log.info('Lidarr: Connection test successful');
        return true;
      } else {
        log.warning('Lidarr: Connection test failed (${response.statusCode})');
        return false;
      }
    } catch (e, stackTrace) {
      log.warning('Lidarr: Connection test error', e, stackTrace);
      return false;
    }
  }
}
