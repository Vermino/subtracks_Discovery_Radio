/// Base exception class for all YouTube discovery service errors
class YouTubeServiceException implements Exception {
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;

  const YouTubeServiceException(
    this.message, {
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    if (originalError != null) {
      return 'YouTubeServiceException: $message\nCaused by: $originalError';
    }
    return 'YouTubeServiceException: $message';
  }
}

/// Exception thrown when Invidious API returns an error response
class InvidiousApiException extends YouTubeServiceException {
  final int? statusCode;
  final String? responseBody;

  const InvidiousApiException(
    super.message, {
    this.statusCode,
    this.responseBody,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('InvidiousApiException: $message');
    if (statusCode != null) {
      buffer.write(' (HTTP $statusCode)');
    }
    if (responseBody != null) {
      buffer.write('\nResponse: $responseBody');
    }
    if (originalError != null) {
      buffer.write('\nCaused by: $originalError');
    }
    return buffer.toString();
  }
}

/// Exception thrown when no audio stream can be extracted from video
class NoAudioStreamException extends YouTubeServiceException {
  final String videoId;

  const NoAudioStreamException(
    this.videoId, {
    super.originalError,
    super.stackTrace,
  }) : super('No audio stream available for video: $videoId');

  @override
  String toString() =>
      'NoAudioStreamException: No suitable audio stream found for video $videoId';
}

/// Exception thrown when rate limit is exceeded
class RateLimitException extends YouTubeServiceException {
  final int requestsPerSecond;
  final Duration retryAfter;

  const RateLimitException(
    this.requestsPerSecond,
    this.retryAfter, {
    super.originalError,
    super.stackTrace,
  }) : super('Rate limit exceeded: $requestsPerSecond requests/second');

  @override
  String toString() =>
      'RateLimitException: Rate limit of $requestsPerSecond req/s exceeded. Retry after ${retryAfter.inSeconds}s';
}

/// Exception thrown when video is not found
class VideoNotFoundException extends InvidiousApiException {
  final String videoId;

  const VideoNotFoundException(
    this.videoId, {
    super.responseBody,
    super.originalError,
    super.stackTrace,
  }) : super(
          'Video not found: $videoId',
          statusCode: 404,
        );

  @override
  String toString() =>
      'VideoNotFoundException: Video $videoId not found on YouTube';
}

/// Exception thrown when JSON parsing fails
class JsonParsingException extends YouTubeServiceException {
  final String jsonString;

  const JsonParsingException(
    super.message,
    this.jsonString, {
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() =>
      'JsonParsingException: $message\nJSON: ${jsonString.length > 200 ? '${jsonString.substring(0, 200)}...' : jsonString}';
}

/// Exception thrown when network request fails
class NetworkException extends YouTubeServiceException {
  const NetworkException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'NetworkException: $message';
}
