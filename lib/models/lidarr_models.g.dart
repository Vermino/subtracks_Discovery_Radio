// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lidarr_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LidarrArtistImpl _$$LidarrArtistImplFromJson(Map<String, dynamic> json) =>
    _$LidarrArtistImpl(
      id: json['id'] as String?,
      artistName: json['artistName'] as String,
      foreignArtistId: json['foreignArtistId'] as String,
      overview: json['overview'] as String?,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => LidarrImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      qualityProfileId: (json['qualityProfileId'] as num?)?.toInt(),
      metadataProfileId: (json['metadataProfileId'] as num?)?.toInt(),
      monitored: json['monitored'] as bool?,
      rootFolderPath: json['rootFolderPath'] as String?,
    );

Map<String, dynamic> _$$LidarrArtistImplToJson(_$LidarrArtistImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'artistName': instance.artistName,
      'foreignArtistId': instance.foreignArtistId,
      'overview': instance.overview,
      'images': instance.images,
      'qualityProfileId': instance.qualityProfileId,
      'metadataProfileId': instance.metadataProfileId,
      'monitored': instance.monitored,
      'rootFolderPath': instance.rootFolderPath,
    };

_$LidarrImageImpl _$$LidarrImageImplFromJson(Map<String, dynamic> json) =>
    _$LidarrImageImpl(
      url: json['url'] as String,
      coverType: json['coverType'] as String?,
      extension: json['extension'] as String?,
    );

Map<String, dynamic> _$$LidarrImageImplToJson(_$LidarrImageImpl instance) =>
    <String, dynamic>{
      'url': instance.url,
      'coverType': instance.coverType,
      'extension': instance.extension,
    };

_$LidarrQualityProfileImpl _$$LidarrQualityProfileImplFromJson(
        Map<String, dynamic> json) =>
    _$LidarrQualityProfileImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$$LidarrQualityProfileImplToJson(
        _$LidarrQualityProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

_$LidarrRootFolderImpl _$$LidarrRootFolderImplFromJson(
        Map<String, dynamic> json) =>
    _$LidarrRootFolderImpl(
      id: (json['id'] as num).toInt(),
      path: json['path'] as String,
      freeSpace: (json['freeSpace'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$LidarrRootFolderImplToJson(
        _$LidarrRootFolderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'path': instance.path,
      'freeSpace': instance.freeSpace,
    };
