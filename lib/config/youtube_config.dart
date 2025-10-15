/// Configuration constants for YouTube Discovery Service
///
/// Uses yt-dlp API for reliable YouTube audio stream extraction
/// API is compatible with Invidious format but uses yt-dlp for better reliability
class YouTubeConfig {
  /// Enable/disable YouTube integration
  static const bool youtubeEnabled = true;

  /// yt-dlp API endpoint (self-hosted)
  /// Compatible with Invidious API format but uses yt-dlp for extraction
  static const String invidiousBaseUrl = 'https://youtube.404oak.com';

  /// Fallback Invidious instances to try if primary fails
  static const List<String> fallbackInstances = [
    'https://youtube.404oak.com',
    'https://yewtu.be',
    'https://invidious.privacyredirect.com',
  ];

  /// Maximum number of search results to request from Invidious
  static const int maxSearchResults = 20;

  /// Minimum acceptable audio bitrate in bits per second (96 kbps)
  static const int minAudioBitrate = 96000;

  /// Buffer time before URL expiry to ensure safe playback
  /// YouTube stream URLs typically expire in 6 hours, we refresh 30 minutes before
  static const Duration urlExpiryBuffer = Duration(minutes: 30);

  /// Maximum number of retry attempts for failed API calls
  static const int maxRetries = 3;

  /// Initial delay between retry attempts (exponential backoff)
  static const Duration retryDelay = Duration(seconds: 2);

  /// Maximum requests per second to prevent rate limiting
  static const int rateLimitPerSecond = 10;

  /// Timeout for API requests
  static const Duration requestTimeout = Duration(seconds: 30);

  /// Preferred audio quality levels (in order of preference)
  static const List<String> preferredAudioQualities = [
    'AUDIO_QUALITY_HIGH',
    'AUDIO_QUALITY_MEDIUM',
    'AUDIO_QUALITY_LOW',
  ];

  /// Preferred audio codecs (in order of preference)
  static const List<String> preferredAudioCodecs = [
    'opus',
    'mp4a',
    'vorbis',
  ];

  /// Keywords that indicate non-music content (for filtering)
  static const List<String> nonMusicKeywords = [
    'interview',
    'podcast',
    'documentary',
    'behind the scenes',
    'making of',
    'reaction',
    'tutorial',
    'lesson',
    'cover explanation',
    'analysis',
  ];

  /// Keywords that indicate official music content
  static const List<String> musicKeywords = [
    'official video',
    'official audio',
    'official music video',
    'lyric video',
    'lyrics',
  ];

  /// Minimum acceptable video duration (2 minutes) for music filtering
  static const Duration minMusicDuration = Duration(minutes: 2);

  /// Maximum acceptable video duration (10 minutes) for music filtering
  static const Duration maxMusicDuration = Duration(minutes: 10);

  /// Preferred channel name suffixes that indicate official content
  static const List<String> officialChannelSuffixes = [
    'VEVO',
    'Topic',
    'Official',
  ];
}
