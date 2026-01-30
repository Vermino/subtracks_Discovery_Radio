import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Infrastructure configuration for Subtracks homelab integration
/// Contains all external service endpoints and credentials for development
class InfrastructureConfig {
  // Navidrome (Music Streaming Server)
  static String get navidromeBaseUrl => dotenv.env['NAVIDROME_URL'] ?? '';
  static String get navidromeUsername => dotenv.env['NAVIDROME_USERNAME'] ?? '';
  static String get navidromePassword => dotenv.env['NAVIDROME_PASSWORD'] ?? '';
  static const String navidromeApiPath = '/rest';

  // Lidarr (Music Collection Manager)
  static String get lidarrBaseUrl => dotenv.env['LIDARR_URL'] ?? '';
  static String get lidarrApiKey => dotenv.env['LIDARR_API_KEY'] ?? '';
  static const String lidarrApiPath = '/api/v1';

  // Discovery Configuration
  static const String ytDlpCommand = 'python -m yt_dlp';
  static const double defaultDiscoveryRatio = 0.3; // 30% discovery, 70% library
  static const int maxCachedDiscoveryTracks = 100;
  static const int cacheExpiryDays = 7;

  // API Endpoints
  static String get navidromeApiUrl => '$navidromeBaseUrl$navidromeApiPath';
  static String get lidarrApiUrl => '$lidarrBaseUrl$lidarrApiPath';

  // Headers for API calls
  static Map<String, String> get lidarrHeaders => {
    'X-Api-Key': lidarrApiKey,
    'Content-Type': 'application/json',
  };

  // Validation methods
  static bool get isConfigurationComplete {
    return navidromeBaseUrl.isNotEmpty &&
           navidromeUsername.isNotEmpty &&
           navidromePassword.isNotEmpty &&
           lidarrBaseUrl.isNotEmpty &&
           lidarrApiKey.isNotEmpty;
  }

  static Map<String, dynamic> get configSummary => {
    'navidrome': {
      'url': navidromeBaseUrl,
      'username': navidromeUsername,
      'configured': navidromeUsername.isNotEmpty,
    },
    'lidarr': {
      'url': lidarrBaseUrl,
      'api_key_set': lidarrApiKey.isNotEmpty,
      'configured': lidarrApiKey.isNotEmpty,
    },
    'discovery': {
      'yt_dlp_available': true,
      'cache_limit': maxCachedDiscoveryTracks,
      'discovery_ratio': defaultDiscoveryRatio,
    }
  };
}
