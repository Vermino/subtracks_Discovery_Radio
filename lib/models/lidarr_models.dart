import 'package:freezed_annotation/freezed_annotation.dart';

part 'lidarr_models.freezed.dart';
part 'lidarr_models.g.dart';

/// Represents an artist in Lidarr/MusicBrainz
@freezed
class LidarrArtist with _$LidarrArtist {
  const factory LidarrArtist({
    String? id, // Lidarr internal ID (only present after being added)
    required String artistName,
    required String foreignArtistId, // MusicBrainz ID
    String? overview,
    List<LidarrImage>? images,
    int? qualityProfileId,
    int? metadataProfileId,
    bool? monitored,
    String? rootFolderPath,
  }) = _LidarrArtist;

  factory LidarrArtist.fromJson(Map<String, dynamic> json) =>
      _$LidarrArtistFromJson(json);
}

/// Represents an image associated with a Lidarr artist
@freezed
class LidarrImage with _$LidarrImage {
  const factory LidarrImage({
    required String url,
    String? coverType,
    String? extension,
  }) = _LidarrImage;

  factory LidarrImage.fromJson(Map<String, dynamic> json) =>
      _$LidarrImageFromJson(json);
}

/// Result of a Lidarr download request
@freezed
class LidarrDownloadResult with _$LidarrDownloadResult {
  const factory LidarrDownloadResult.success({
    required String artistName,
    required String foreignArtistId,
    required String message,
  }) = LidarrDownloadSuccess;

  const factory LidarrDownloadResult.alreadyExists({
    required String artistName,
    required String message,
  }) = LidarrDownloadAlreadyExists;

  const factory LidarrDownloadResult.notFound({
    required String message,
  }) = LidarrDownloadNotFound;

  const factory LidarrDownloadResult.error({
    required String message,
    Object? error,
  }) = LidarrDownloadError;
}

/// Represents a Lidarr quality profile
@freezed
class LidarrQualityProfile with _$LidarrQualityProfile {
  const factory LidarrQualityProfile({
    required int id,
    required String name,
  }) = _LidarrQualityProfile;

  factory LidarrQualityProfile.fromJson(Map<String, dynamic> json) =>
      _$LidarrQualityProfileFromJson(json);
}

/// Represents a Lidarr root folder (music library location)
@freezed
class LidarrRootFolder with _$LidarrRootFolder {
  const factory LidarrRootFolder({
    required int id,
    required String path,
    int? freeSpace,
  }) = _LidarrRootFolder;

  factory LidarrRootFolder.fromJson(Map<String, dynamic> json) =>
      _$LidarrRootFolderFromJson(json);
}
