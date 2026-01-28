import 'package:freezed_annotation/freezed_annotation.dart';

part 'youtube_models.freezed.dart';
part 'youtube_models.g.dart';

/// Represents a YouTube video search result from Invidious API
@freezed
class YouTubeSearchResult with _$YouTubeSearchResult {
  const factory YouTubeSearchResult({
    required String videoId,
    required String title,
    required String author,
    required int lengthSeconds,
    String? description,
    String? thumbnail,
    int? viewCount,
  }) = _YouTubeSearchResult;

  factory YouTubeSearchResult.fromJson(Map<String, dynamic> json) =>
      _$YouTubeSearchResultFromJson(json);
}

/// Represents a YouTube audio stream with metadata
@freezed
class YouTubeAudioStream with _$YouTubeAudioStream {
  const factory YouTubeAudioStream({
    required String url,
    required String videoId,
    required int bitrate,
    required String audioQuality,
    required int audioSampleRate,
    required String codec,
    required DateTime expiresAt,
    String? container,
    int? contentLength,
  }) = _YouTubeAudioStream;

  factory YouTubeAudioStream.fromJson(Map<String, dynamic> json) =>
      _$YouTubeAudioStreamFromJson(json);
}

/// Represents detailed video information from Invidious API
@freezed
class YouTubeVideoInfo with _$YouTubeVideoInfo {
  const factory YouTubeVideoInfo({
    required String videoId,
    required String title,
    required String author,
    required int lengthSeconds,
    String? description,
    required List<YouTubeAudioFormat> adaptiveFormats,
  }) = _YouTubeVideoInfo;

  factory YouTubeVideoInfo.fromJson(Map<String, dynamic> json) =>
      _$YouTubeVideoInfoFromJson(json);
}

/// Represents an audio format from video's adaptiveFormats
@freezed
class YouTubeAudioFormat with _$YouTubeAudioFormat {
  const factory YouTubeAudioFormat({
    required String url,
    required String type,
    String? audioQuality,
    String? audioSampleRate,
    int? bitrate,
    int? clen,
    String? container,
    String? encoding,
  }) = _YouTubeAudioFormat;

  factory YouTubeAudioFormat.fromJson(Map<String, dynamic> json) =>
      _$YouTubeAudioFormatFromJson(json);

  /// Extract codec from type string (e.g., "audio/mp4; codecs=\"mp4a.40.2\"")
  static String? extractCodec(String type) {
    final codecMatch = RegExp(r'codecs="([^"]+)"').firstMatch(type);
    if (codecMatch != null) {
      return codecMatch.group(1);
    }
    // Fallback: try to extract from container
    if (type.contains('mp4')) return 'mp4a';
    if (type.contains('webm')) return 'opus';
    if (type.contains('ogg')) return 'vorbis';
    return null;
  }

  /// Check if this format is an audio-only stream
  static bool isAudioOnly(String type) {
    return type.startsWith('audio/');
  }
}

/// Represents the raw search response from Invidious API
/// This is used internally for parsing before converting to YouTubeSearchResult
class InvidiousSearchResponse {
  final String type;
  final String videoId;
  final String title;
  final String author;
  final int lengthSeconds;
  final String? description;
  final List<dynamic>? videoThumbnails;
  final int? viewCount;

  const InvidiousSearchResponse({
    required this.type,
    required this.videoId,
    required this.title,
    required this.author,
    required this.lengthSeconds,
    this.description,
    this.videoThumbnails,
    this.viewCount,
  });

  factory InvidiousSearchResponse.fromJson(Map<String, dynamic> json) {
    return InvidiousSearchResponse(
      type: json['type'] as String? ?? 'video',
      videoId: json['videoId'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      lengthSeconds: json['lengthSeconds'] as int,
      description: json['description'] as String?,
      videoThumbnails: json['videoThumbnails'] as List<dynamic>?,
      viewCount: json['viewCount'] as int?,
    );
  }

  /// Get thumbnail URL (prefer medium quality)
  String? getThumbnailUrl() {
    if (videoThumbnails == null || videoThumbnails!.isEmpty) {
      return null;
    }

    // Try to find medium quality thumbnail
    for (final thumb in videoThumbnails!) {
      if (thumb is Map<String, dynamic> && thumb['quality'] == 'medium') {
        return thumb['url'] as String?;
      }
    }

    // Fallback to first thumbnail
    if (videoThumbnails!.first is Map<String, dynamic>) {
      return (videoThumbnails!.first as Map<String, dynamic>)['url'] as String?;
    }

    return null;
  }

  /// Convert to YouTubeSearchResult
  YouTubeSearchResult toSearchResult() {
    return YouTubeSearchResult(
      videoId: videoId,
      title: title,
      author: author,
      lengthSeconds: lengthSeconds,
      description: description,
      thumbnail: getThumbnailUrl(),
      viewCount: viewCount,
    );
  }
}

/// Represents the raw video info response from Invidious API
/// This is used internally for parsing before converting to YouTubeVideoInfo
class InvidiousVideoResponse {
  final String videoId;
  final String title;
  final String author;
  final int lengthSeconds;
  final String? description;
  final List<dynamic> adaptiveFormats;

  const InvidiousVideoResponse({
    required this.videoId,
    required this.title,
    required this.author,
    required this.lengthSeconds,
    this.description,
    required this.adaptiveFormats,
  });

  factory InvidiousVideoResponse.fromJson(Map<String, dynamic> json) {
    return InvidiousVideoResponse(
      videoId: json['videoId'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      lengthSeconds: json['lengthSeconds'] as int,
      description: json['description'] as String?,
      adaptiveFormats: json['adaptiveFormats'] as List<dynamic>? ?? [],
    );
  }

  /// Convert to YouTubeVideoInfo
  /// Works with both Invidious and yt-dlp API responses
  YouTubeVideoInfo toVideoInfo() {
    final audioFormats = adaptiveFormats
        .where((format) =>
            format is Map<String, dynamic> &&
            YouTubeAudioFormat.isAudioOnly(format['type'] as String? ?? ''))
        .map((format) {
      final map = Map<String, dynamic>.from(format as Map<String, dynamic>);

      // Normalize numeric fields - handle both Invidious and yt-dlp formats
      // audioSampleRate: yt-dlp returns int, Freezed expects String
      if (map['audioSampleRate'] is int) {
        map['audioSampleRate'] = map['audioSampleRate'].toString();
      } else if (map['audioSampleRate'] is double) {
        map['audioSampleRate'] = map['audioSampleRate'].toInt().toString();
      }

      // bitrate: yt-dlp may return double, Freezed expects int
      if (map['bitrate'] is String) {
        map['bitrate'] = int.tryParse(map['bitrate'] as String);
      } else if (map['bitrate'] is double) {
        map['bitrate'] = (map['bitrate'] as double).toInt();
      }

      // clen (content length): handle String or numeric
      if (map['clen'] is String) {
        map['clen'] = int.tryParse(map['clen'] as String);
      } else if (map['clen'] is double) {
        map['clen'] = (map['clen'] as double).toInt();
      }

      // audioQuality: yt-dlp returns double (e.g. 2.0), Freezed expects String
      if (map['audioQuality'] is double || map['audioQuality'] is int) {
        final quality = (map['audioQuality'] as num).toInt();
        // Map numeric quality to standard quality strings
        if (quality >= 3) {
          map['audioQuality'] = 'AUDIO_QUALITY_HIGH';
        } else if (quality >= 2) {
          map['audioQuality'] = 'AUDIO_QUALITY_MEDIUM';
        } else {
          map['audioQuality'] = 'AUDIO_QUALITY_LOW';
        }
      }

      return YouTubeAudioFormat.fromJson(map);
    }).toList();

    return YouTubeVideoInfo(
      videoId: videoId,
      title: title,
      author: author,
      lengthSeconds: lengthSeconds,
      description: description,
      adaptiveFormats: audioFormats,
    );
  }
}
