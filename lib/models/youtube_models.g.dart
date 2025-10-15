// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'youtube_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$YouTubeSearchResultImpl _$$YouTubeSearchResultImplFromJson(
        Map<String, dynamic> json) =>
    _$YouTubeSearchResultImpl(
      videoId: json['videoId'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      lengthSeconds: (json['lengthSeconds'] as num).toInt(),
      description: json['description'] as String?,
      thumbnail: json['thumbnail'] as String?,
      viewCount: (json['viewCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$YouTubeSearchResultImplToJson(
        _$YouTubeSearchResultImpl instance) =>
    <String, dynamic>{
      'videoId': instance.videoId,
      'title': instance.title,
      'author': instance.author,
      'lengthSeconds': instance.lengthSeconds,
      'description': instance.description,
      'thumbnail': instance.thumbnail,
      'viewCount': instance.viewCount,
    };

_$YouTubeAudioStreamImpl _$$YouTubeAudioStreamImplFromJson(
        Map<String, dynamic> json) =>
    _$YouTubeAudioStreamImpl(
      url: json['url'] as String,
      videoId: json['videoId'] as String,
      bitrate: (json['bitrate'] as num).toInt(),
      audioQuality: json['audioQuality'] as String,
      audioSampleRate: (json['audioSampleRate'] as num).toInt(),
      codec: json['codec'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      container: json['container'] as String?,
      contentLength: (json['contentLength'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$YouTubeAudioStreamImplToJson(
        _$YouTubeAudioStreamImpl instance) =>
    <String, dynamic>{
      'url': instance.url,
      'videoId': instance.videoId,
      'bitrate': instance.bitrate,
      'audioQuality': instance.audioQuality,
      'audioSampleRate': instance.audioSampleRate,
      'codec': instance.codec,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'container': instance.container,
      'contentLength': instance.contentLength,
    };

_$YouTubeVideoInfoImpl _$$YouTubeVideoInfoImplFromJson(
        Map<String, dynamic> json) =>
    _$YouTubeVideoInfoImpl(
      videoId: json['videoId'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      lengthSeconds: (json['lengthSeconds'] as num).toInt(),
      description: json['description'] as String?,
      adaptiveFormats: (json['adaptiveFormats'] as List<dynamic>)
          .map((e) => YouTubeAudioFormat.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$YouTubeVideoInfoImplToJson(
        _$YouTubeVideoInfoImpl instance) =>
    <String, dynamic>{
      'videoId': instance.videoId,
      'title': instance.title,
      'author': instance.author,
      'lengthSeconds': instance.lengthSeconds,
      'description': instance.description,
      'adaptiveFormats': instance.adaptiveFormats,
    };

_$YouTubeAudioFormatImpl _$$YouTubeAudioFormatImplFromJson(
        Map<String, dynamic> json) =>
    _$YouTubeAudioFormatImpl(
      url: json['url'] as String,
      type: json['type'] as String,
      audioQuality: json['audioQuality'] as String?,
      audioSampleRate: json['audioSampleRate'] as String?,
      bitrate: (json['bitrate'] as num?)?.toInt(),
      clen: (json['clen'] as num?)?.toInt(),
      container: json['container'] as String?,
      encoding: json['encoding'] as String?,
    );

Map<String, dynamic> _$$YouTubeAudioFormatImplToJson(
        _$YouTubeAudioFormatImpl instance) =>
    <String, dynamic>{
      'url': instance.url,
      'type': instance.type,
      'audioQuality': instance.audioQuality,
      'audioSampleRate': instance.audioSampleRate,
      'bitrate': instance.bitrate,
      'clen': instance.clen,
      'container': instance.container,
      'encoding': instance.encoding,
    };
