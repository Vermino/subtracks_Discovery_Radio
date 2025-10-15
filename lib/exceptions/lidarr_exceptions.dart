/// Base exception for all Lidarr-related errors
class LidarrException implements Exception {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  LidarrException(this.message, [this.error, this.stackTrace]);

  @override
  String toString() => 'LidarrException: $message';
}

/// Thrown when Lidarr API returns an error response
class LidarrApiException extends LidarrException {
  final int? statusCode;

  LidarrApiException(
    String message, {
    this.statusCode,
    Object? error,
    StackTrace? stackTrace,
  }) : super(message, error, stackTrace);

  @override
  String toString() => 'LidarrApiException ($statusCode): $message';
}

/// Thrown when artist cannot be found in MusicBrainz/Lidarr
class LidarrArtistNotFoundException extends LidarrException {
  final String artistName;

  LidarrArtistNotFoundException(this.artistName)
      : super('Artist not found: $artistName');

  @override
  String toString() => 'LidarrArtistNotFoundException: $artistName';
}

/// Thrown when network request to Lidarr fails
class LidarrNetworkException extends LidarrException {
  LidarrNetworkException(super.message, [super.error, super.stackTrace]);

  @override
  String toString() => 'LidarrNetworkException: $message';
}

/// Thrown when Lidarr configuration is invalid or missing
class LidarrConfigurationException extends LidarrException {
  LidarrConfigurationException(super.message);

  @override
  String toString() => 'LidarrConfigurationException: $message';
}
