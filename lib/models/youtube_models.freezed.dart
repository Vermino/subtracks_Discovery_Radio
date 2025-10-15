// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'youtube_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

YouTubeSearchResult _$YouTubeSearchResultFromJson(Map<String, dynamic> json) {
  return _YouTubeSearchResult.fromJson(json);
}

/// @nodoc
mixin _$YouTubeSearchResult {
  String get videoId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get author => throw _privateConstructorUsedError;
  int get lengthSeconds => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get thumbnail => throw _privateConstructorUsedError;
  int? get viewCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $YouTubeSearchResultCopyWith<YouTubeSearchResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $YouTubeSearchResultCopyWith<$Res> {
  factory $YouTubeSearchResultCopyWith(
          YouTubeSearchResult value, $Res Function(YouTubeSearchResult) then) =
      _$YouTubeSearchResultCopyWithImpl<$Res, YouTubeSearchResult>;
  @useResult
  $Res call(
      {String videoId,
      String title,
      String author,
      int lengthSeconds,
      String? description,
      String? thumbnail,
      int? viewCount});
}

/// @nodoc
class _$YouTubeSearchResultCopyWithImpl<$Res, $Val extends YouTubeSearchResult>
    implements $YouTubeSearchResultCopyWith<$Res> {
  _$YouTubeSearchResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? videoId = null,
    Object? title = null,
    Object? author = null,
    Object? lengthSeconds = null,
    Object? description = freezed,
    Object? thumbnail = freezed,
    Object? viewCount = freezed,
  }) {
    return _then(_value.copyWith(
      videoId: null == videoId
          ? _value.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      lengthSeconds: null == lengthSeconds
          ? _value.lengthSeconds
          : lengthSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnail: freezed == thumbnail
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String?,
      viewCount: freezed == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$YouTubeSearchResultImplCopyWith<$Res>
    implements $YouTubeSearchResultCopyWith<$Res> {
  factory _$$YouTubeSearchResultImplCopyWith(_$YouTubeSearchResultImpl value,
          $Res Function(_$YouTubeSearchResultImpl) then) =
      __$$YouTubeSearchResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String videoId,
      String title,
      String author,
      int lengthSeconds,
      String? description,
      String? thumbnail,
      int? viewCount});
}

/// @nodoc
class __$$YouTubeSearchResultImplCopyWithImpl<$Res>
    extends _$YouTubeSearchResultCopyWithImpl<$Res, _$YouTubeSearchResultImpl>
    implements _$$YouTubeSearchResultImplCopyWith<$Res> {
  __$$YouTubeSearchResultImplCopyWithImpl(_$YouTubeSearchResultImpl _value,
      $Res Function(_$YouTubeSearchResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? videoId = null,
    Object? title = null,
    Object? author = null,
    Object? lengthSeconds = null,
    Object? description = freezed,
    Object? thumbnail = freezed,
    Object? viewCount = freezed,
  }) {
    return _then(_$YouTubeSearchResultImpl(
      videoId: null == videoId
          ? _value.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      lengthSeconds: null == lengthSeconds
          ? _value.lengthSeconds
          : lengthSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnail: freezed == thumbnail
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String?,
      viewCount: freezed == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$YouTubeSearchResultImpl implements _YouTubeSearchResult {
  const _$YouTubeSearchResultImpl(
      {required this.videoId,
      required this.title,
      required this.author,
      required this.lengthSeconds,
      this.description,
      this.thumbnail,
      this.viewCount});

  factory _$YouTubeSearchResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$YouTubeSearchResultImplFromJson(json);

  @override
  final String videoId;
  @override
  final String title;
  @override
  final String author;
  @override
  final int lengthSeconds;
  @override
  final String? description;
  @override
  final String? thumbnail;
  @override
  final int? viewCount;

  @override
  String toString() {
    return 'YouTubeSearchResult(videoId: $videoId, title: $title, author: $author, lengthSeconds: $lengthSeconds, description: $description, thumbnail: $thumbnail, viewCount: $viewCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$YouTubeSearchResultImpl &&
            (identical(other.videoId, videoId) || other.videoId == videoId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.lengthSeconds, lengthSeconds) ||
                other.lengthSeconds == lengthSeconds) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.thumbnail, thumbnail) ||
                other.thumbnail == thumbnail) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, videoId, title, author,
      lengthSeconds, description, thumbnail, viewCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$YouTubeSearchResultImplCopyWith<_$YouTubeSearchResultImpl> get copyWith =>
      __$$YouTubeSearchResultImplCopyWithImpl<_$YouTubeSearchResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$YouTubeSearchResultImplToJson(
      this,
    );
  }
}

abstract class _YouTubeSearchResult implements YouTubeSearchResult {
  const factory _YouTubeSearchResult(
      {required final String videoId,
      required final String title,
      required final String author,
      required final int lengthSeconds,
      final String? description,
      final String? thumbnail,
      final int? viewCount}) = _$YouTubeSearchResultImpl;

  factory _YouTubeSearchResult.fromJson(Map<String, dynamic> json) =
      _$YouTubeSearchResultImpl.fromJson;

  @override
  String get videoId;
  @override
  String get title;
  @override
  String get author;
  @override
  int get lengthSeconds;
  @override
  String? get description;
  @override
  String? get thumbnail;
  @override
  int? get viewCount;
  @override
  @JsonKey(ignore: true)
  _$$YouTubeSearchResultImplCopyWith<_$YouTubeSearchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

YouTubeAudioStream _$YouTubeAudioStreamFromJson(Map<String, dynamic> json) {
  return _YouTubeAudioStream.fromJson(json);
}

/// @nodoc
mixin _$YouTubeAudioStream {
  String get url => throw _privateConstructorUsedError;
  String get videoId => throw _privateConstructorUsedError;
  int get bitrate => throw _privateConstructorUsedError;
  String get audioQuality => throw _privateConstructorUsedError;
  int get audioSampleRate => throw _privateConstructorUsedError;
  String get codec => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;
  String? get container => throw _privateConstructorUsedError;
  int? get contentLength => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $YouTubeAudioStreamCopyWith<YouTubeAudioStream> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $YouTubeAudioStreamCopyWith<$Res> {
  factory $YouTubeAudioStreamCopyWith(
          YouTubeAudioStream value, $Res Function(YouTubeAudioStream) then) =
      _$YouTubeAudioStreamCopyWithImpl<$Res, YouTubeAudioStream>;
  @useResult
  $Res call(
      {String url,
      String videoId,
      int bitrate,
      String audioQuality,
      int audioSampleRate,
      String codec,
      DateTime expiresAt,
      String? container,
      int? contentLength});
}

/// @nodoc
class _$YouTubeAudioStreamCopyWithImpl<$Res, $Val extends YouTubeAudioStream>
    implements $YouTubeAudioStreamCopyWith<$Res> {
  _$YouTubeAudioStreamCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? videoId = null,
    Object? bitrate = null,
    Object? audioQuality = null,
    Object? audioSampleRate = null,
    Object? codec = null,
    Object? expiresAt = null,
    Object? container = freezed,
    Object? contentLength = freezed,
  }) {
    return _then(_value.copyWith(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      videoId: null == videoId
          ? _value.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as String,
      bitrate: null == bitrate
          ? _value.bitrate
          : bitrate // ignore: cast_nullable_to_non_nullable
              as int,
      audioQuality: null == audioQuality
          ? _value.audioQuality
          : audioQuality // ignore: cast_nullable_to_non_nullable
              as String,
      audioSampleRate: null == audioSampleRate
          ? _value.audioSampleRate
          : audioSampleRate // ignore: cast_nullable_to_non_nullable
              as int,
      codec: null == codec
          ? _value.codec
          : codec // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      container: freezed == container
          ? _value.container
          : container // ignore: cast_nullable_to_non_nullable
              as String?,
      contentLength: freezed == contentLength
          ? _value.contentLength
          : contentLength // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$YouTubeAudioStreamImplCopyWith<$Res>
    implements $YouTubeAudioStreamCopyWith<$Res> {
  factory _$$YouTubeAudioStreamImplCopyWith(_$YouTubeAudioStreamImpl value,
          $Res Function(_$YouTubeAudioStreamImpl) then) =
      __$$YouTubeAudioStreamImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String url,
      String videoId,
      int bitrate,
      String audioQuality,
      int audioSampleRate,
      String codec,
      DateTime expiresAt,
      String? container,
      int? contentLength});
}

/// @nodoc
class __$$YouTubeAudioStreamImplCopyWithImpl<$Res>
    extends _$YouTubeAudioStreamCopyWithImpl<$Res, _$YouTubeAudioStreamImpl>
    implements _$$YouTubeAudioStreamImplCopyWith<$Res> {
  __$$YouTubeAudioStreamImplCopyWithImpl(_$YouTubeAudioStreamImpl _value,
      $Res Function(_$YouTubeAudioStreamImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? videoId = null,
    Object? bitrate = null,
    Object? audioQuality = null,
    Object? audioSampleRate = null,
    Object? codec = null,
    Object? expiresAt = null,
    Object? container = freezed,
    Object? contentLength = freezed,
  }) {
    return _then(_$YouTubeAudioStreamImpl(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      videoId: null == videoId
          ? _value.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as String,
      bitrate: null == bitrate
          ? _value.bitrate
          : bitrate // ignore: cast_nullable_to_non_nullable
              as int,
      audioQuality: null == audioQuality
          ? _value.audioQuality
          : audioQuality // ignore: cast_nullable_to_non_nullable
              as String,
      audioSampleRate: null == audioSampleRate
          ? _value.audioSampleRate
          : audioSampleRate // ignore: cast_nullable_to_non_nullable
              as int,
      codec: null == codec
          ? _value.codec
          : codec // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      container: freezed == container
          ? _value.container
          : container // ignore: cast_nullable_to_non_nullable
              as String?,
      contentLength: freezed == contentLength
          ? _value.contentLength
          : contentLength // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$YouTubeAudioStreamImpl implements _YouTubeAudioStream {
  const _$YouTubeAudioStreamImpl(
      {required this.url,
      required this.videoId,
      required this.bitrate,
      required this.audioQuality,
      required this.audioSampleRate,
      required this.codec,
      required this.expiresAt,
      this.container,
      this.contentLength});

  factory _$YouTubeAudioStreamImpl.fromJson(Map<String, dynamic> json) =>
      _$$YouTubeAudioStreamImplFromJson(json);

  @override
  final String url;
  @override
  final String videoId;
  @override
  final int bitrate;
  @override
  final String audioQuality;
  @override
  final int audioSampleRate;
  @override
  final String codec;
  @override
  final DateTime expiresAt;
  @override
  final String? container;
  @override
  final int? contentLength;

  @override
  String toString() {
    return 'YouTubeAudioStream(url: $url, videoId: $videoId, bitrate: $bitrate, audioQuality: $audioQuality, audioSampleRate: $audioSampleRate, codec: $codec, expiresAt: $expiresAt, container: $container, contentLength: $contentLength)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$YouTubeAudioStreamImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.videoId, videoId) || other.videoId == videoId) &&
            (identical(other.bitrate, bitrate) || other.bitrate == bitrate) &&
            (identical(other.audioQuality, audioQuality) ||
                other.audioQuality == audioQuality) &&
            (identical(other.audioSampleRate, audioSampleRate) ||
                other.audioSampleRate == audioSampleRate) &&
            (identical(other.codec, codec) || other.codec == codec) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.container, container) ||
                other.container == container) &&
            (identical(other.contentLength, contentLength) ||
                other.contentLength == contentLength));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      url,
      videoId,
      bitrate,
      audioQuality,
      audioSampleRate,
      codec,
      expiresAt,
      container,
      contentLength);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$YouTubeAudioStreamImplCopyWith<_$YouTubeAudioStreamImpl> get copyWith =>
      __$$YouTubeAudioStreamImplCopyWithImpl<_$YouTubeAudioStreamImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$YouTubeAudioStreamImplToJson(
      this,
    );
  }
}

abstract class _YouTubeAudioStream implements YouTubeAudioStream {
  const factory _YouTubeAudioStream(
      {required final String url,
      required final String videoId,
      required final int bitrate,
      required final String audioQuality,
      required final int audioSampleRate,
      required final String codec,
      required final DateTime expiresAt,
      final String? container,
      final int? contentLength}) = _$YouTubeAudioStreamImpl;

  factory _YouTubeAudioStream.fromJson(Map<String, dynamic> json) =
      _$YouTubeAudioStreamImpl.fromJson;

  @override
  String get url;
  @override
  String get videoId;
  @override
  int get bitrate;
  @override
  String get audioQuality;
  @override
  int get audioSampleRate;
  @override
  String get codec;
  @override
  DateTime get expiresAt;
  @override
  String? get container;
  @override
  int? get contentLength;
  @override
  @JsonKey(ignore: true)
  _$$YouTubeAudioStreamImplCopyWith<_$YouTubeAudioStreamImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

YouTubeVideoInfo _$YouTubeVideoInfoFromJson(Map<String, dynamic> json) {
  return _YouTubeVideoInfo.fromJson(json);
}

/// @nodoc
mixin _$YouTubeVideoInfo {
  String get videoId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get author => throw _privateConstructorUsedError;
  int get lengthSeconds => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  List<YouTubeAudioFormat> get adaptiveFormats =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $YouTubeVideoInfoCopyWith<YouTubeVideoInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $YouTubeVideoInfoCopyWith<$Res> {
  factory $YouTubeVideoInfoCopyWith(
          YouTubeVideoInfo value, $Res Function(YouTubeVideoInfo) then) =
      _$YouTubeVideoInfoCopyWithImpl<$Res, YouTubeVideoInfo>;
  @useResult
  $Res call(
      {String videoId,
      String title,
      String author,
      int lengthSeconds,
      String? description,
      List<YouTubeAudioFormat> adaptiveFormats});
}

/// @nodoc
class _$YouTubeVideoInfoCopyWithImpl<$Res, $Val extends YouTubeVideoInfo>
    implements $YouTubeVideoInfoCopyWith<$Res> {
  _$YouTubeVideoInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? videoId = null,
    Object? title = null,
    Object? author = null,
    Object? lengthSeconds = null,
    Object? description = freezed,
    Object? adaptiveFormats = null,
  }) {
    return _then(_value.copyWith(
      videoId: null == videoId
          ? _value.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      lengthSeconds: null == lengthSeconds
          ? _value.lengthSeconds
          : lengthSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      adaptiveFormats: null == adaptiveFormats
          ? _value.adaptiveFormats
          : adaptiveFormats // ignore: cast_nullable_to_non_nullable
              as List<YouTubeAudioFormat>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$YouTubeVideoInfoImplCopyWith<$Res>
    implements $YouTubeVideoInfoCopyWith<$Res> {
  factory _$$YouTubeVideoInfoImplCopyWith(_$YouTubeVideoInfoImpl value,
          $Res Function(_$YouTubeVideoInfoImpl) then) =
      __$$YouTubeVideoInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String videoId,
      String title,
      String author,
      int lengthSeconds,
      String? description,
      List<YouTubeAudioFormat> adaptiveFormats});
}

/// @nodoc
class __$$YouTubeVideoInfoImplCopyWithImpl<$Res>
    extends _$YouTubeVideoInfoCopyWithImpl<$Res, _$YouTubeVideoInfoImpl>
    implements _$$YouTubeVideoInfoImplCopyWith<$Res> {
  __$$YouTubeVideoInfoImplCopyWithImpl(_$YouTubeVideoInfoImpl _value,
      $Res Function(_$YouTubeVideoInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? videoId = null,
    Object? title = null,
    Object? author = null,
    Object? lengthSeconds = null,
    Object? description = freezed,
    Object? adaptiveFormats = null,
  }) {
    return _then(_$YouTubeVideoInfoImpl(
      videoId: null == videoId
          ? _value.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      lengthSeconds: null == lengthSeconds
          ? _value.lengthSeconds
          : lengthSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      adaptiveFormats: null == adaptiveFormats
          ? _value._adaptiveFormats
          : adaptiveFormats // ignore: cast_nullable_to_non_nullable
              as List<YouTubeAudioFormat>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$YouTubeVideoInfoImpl implements _YouTubeVideoInfo {
  const _$YouTubeVideoInfoImpl(
      {required this.videoId,
      required this.title,
      required this.author,
      required this.lengthSeconds,
      this.description,
      required final List<YouTubeAudioFormat> adaptiveFormats})
      : _adaptiveFormats = adaptiveFormats;

  factory _$YouTubeVideoInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$YouTubeVideoInfoImplFromJson(json);

  @override
  final String videoId;
  @override
  final String title;
  @override
  final String author;
  @override
  final int lengthSeconds;
  @override
  final String? description;
  final List<YouTubeAudioFormat> _adaptiveFormats;
  @override
  List<YouTubeAudioFormat> get adaptiveFormats {
    if (_adaptiveFormats is EqualUnmodifiableListView) return _adaptiveFormats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_adaptiveFormats);
  }

  @override
  String toString() {
    return 'YouTubeVideoInfo(videoId: $videoId, title: $title, author: $author, lengthSeconds: $lengthSeconds, description: $description, adaptiveFormats: $adaptiveFormats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$YouTubeVideoInfoImpl &&
            (identical(other.videoId, videoId) || other.videoId == videoId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.lengthSeconds, lengthSeconds) ||
                other.lengthSeconds == lengthSeconds) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._adaptiveFormats, _adaptiveFormats));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      videoId,
      title,
      author,
      lengthSeconds,
      description,
      const DeepCollectionEquality().hash(_adaptiveFormats));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$YouTubeVideoInfoImplCopyWith<_$YouTubeVideoInfoImpl> get copyWith =>
      __$$YouTubeVideoInfoImplCopyWithImpl<_$YouTubeVideoInfoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$YouTubeVideoInfoImplToJson(
      this,
    );
  }
}

abstract class _YouTubeVideoInfo implements YouTubeVideoInfo {
  const factory _YouTubeVideoInfo(
          {required final String videoId,
          required final String title,
          required final String author,
          required final int lengthSeconds,
          final String? description,
          required final List<YouTubeAudioFormat> adaptiveFormats}) =
      _$YouTubeVideoInfoImpl;

  factory _YouTubeVideoInfo.fromJson(Map<String, dynamic> json) =
      _$YouTubeVideoInfoImpl.fromJson;

  @override
  String get videoId;
  @override
  String get title;
  @override
  String get author;
  @override
  int get lengthSeconds;
  @override
  String? get description;
  @override
  List<YouTubeAudioFormat> get adaptiveFormats;
  @override
  @JsonKey(ignore: true)
  _$$YouTubeVideoInfoImplCopyWith<_$YouTubeVideoInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

YouTubeAudioFormat _$YouTubeAudioFormatFromJson(Map<String, dynamic> json) {
  return _YouTubeAudioFormat.fromJson(json);
}

/// @nodoc
mixin _$YouTubeAudioFormat {
  String get url => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String? get audioQuality => throw _privateConstructorUsedError;
  String? get audioSampleRate => throw _privateConstructorUsedError;
  int? get bitrate => throw _privateConstructorUsedError;
  int? get clen => throw _privateConstructorUsedError;
  String? get container => throw _privateConstructorUsedError;
  String? get encoding => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $YouTubeAudioFormatCopyWith<YouTubeAudioFormat> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $YouTubeAudioFormatCopyWith<$Res> {
  factory $YouTubeAudioFormatCopyWith(
          YouTubeAudioFormat value, $Res Function(YouTubeAudioFormat) then) =
      _$YouTubeAudioFormatCopyWithImpl<$Res, YouTubeAudioFormat>;
  @useResult
  $Res call(
      {String url,
      String type,
      String? audioQuality,
      String? audioSampleRate,
      int? bitrate,
      int? clen,
      String? container,
      String? encoding});
}

/// @nodoc
class _$YouTubeAudioFormatCopyWithImpl<$Res, $Val extends YouTubeAudioFormat>
    implements $YouTubeAudioFormatCopyWith<$Res> {
  _$YouTubeAudioFormatCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? type = null,
    Object? audioQuality = freezed,
    Object? audioSampleRate = freezed,
    Object? bitrate = freezed,
    Object? clen = freezed,
    Object? container = freezed,
    Object? encoding = freezed,
  }) {
    return _then(_value.copyWith(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      audioQuality: freezed == audioQuality
          ? _value.audioQuality
          : audioQuality // ignore: cast_nullable_to_non_nullable
              as String?,
      audioSampleRate: freezed == audioSampleRate
          ? _value.audioSampleRate
          : audioSampleRate // ignore: cast_nullable_to_non_nullable
              as String?,
      bitrate: freezed == bitrate
          ? _value.bitrate
          : bitrate // ignore: cast_nullable_to_non_nullable
              as int?,
      clen: freezed == clen
          ? _value.clen
          : clen // ignore: cast_nullable_to_non_nullable
              as int?,
      container: freezed == container
          ? _value.container
          : container // ignore: cast_nullable_to_non_nullable
              as String?,
      encoding: freezed == encoding
          ? _value.encoding
          : encoding // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$YouTubeAudioFormatImplCopyWith<$Res>
    implements $YouTubeAudioFormatCopyWith<$Res> {
  factory _$$YouTubeAudioFormatImplCopyWith(_$YouTubeAudioFormatImpl value,
          $Res Function(_$YouTubeAudioFormatImpl) then) =
      __$$YouTubeAudioFormatImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String url,
      String type,
      String? audioQuality,
      String? audioSampleRate,
      int? bitrate,
      int? clen,
      String? container,
      String? encoding});
}

/// @nodoc
class __$$YouTubeAudioFormatImplCopyWithImpl<$Res>
    extends _$YouTubeAudioFormatCopyWithImpl<$Res, _$YouTubeAudioFormatImpl>
    implements _$$YouTubeAudioFormatImplCopyWith<$Res> {
  __$$YouTubeAudioFormatImplCopyWithImpl(_$YouTubeAudioFormatImpl _value,
      $Res Function(_$YouTubeAudioFormatImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? type = null,
    Object? audioQuality = freezed,
    Object? audioSampleRate = freezed,
    Object? bitrate = freezed,
    Object? clen = freezed,
    Object? container = freezed,
    Object? encoding = freezed,
  }) {
    return _then(_$YouTubeAudioFormatImpl(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      audioQuality: freezed == audioQuality
          ? _value.audioQuality
          : audioQuality // ignore: cast_nullable_to_non_nullable
              as String?,
      audioSampleRate: freezed == audioSampleRate
          ? _value.audioSampleRate
          : audioSampleRate // ignore: cast_nullable_to_non_nullable
              as String?,
      bitrate: freezed == bitrate
          ? _value.bitrate
          : bitrate // ignore: cast_nullable_to_non_nullable
              as int?,
      clen: freezed == clen
          ? _value.clen
          : clen // ignore: cast_nullable_to_non_nullable
              as int?,
      container: freezed == container
          ? _value.container
          : container // ignore: cast_nullable_to_non_nullable
              as String?,
      encoding: freezed == encoding
          ? _value.encoding
          : encoding // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$YouTubeAudioFormatImpl implements _YouTubeAudioFormat {
  const _$YouTubeAudioFormatImpl(
      {required this.url,
      required this.type,
      this.audioQuality,
      this.audioSampleRate,
      this.bitrate,
      this.clen,
      this.container,
      this.encoding});

  factory _$YouTubeAudioFormatImpl.fromJson(Map<String, dynamic> json) =>
      _$$YouTubeAudioFormatImplFromJson(json);

  @override
  final String url;
  @override
  final String type;
  @override
  final String? audioQuality;
  @override
  final String? audioSampleRate;
  @override
  final int? bitrate;
  @override
  final int? clen;
  @override
  final String? container;
  @override
  final String? encoding;

  @override
  String toString() {
    return 'YouTubeAudioFormat(url: $url, type: $type, audioQuality: $audioQuality, audioSampleRate: $audioSampleRate, bitrate: $bitrate, clen: $clen, container: $container, encoding: $encoding)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$YouTubeAudioFormatImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.audioQuality, audioQuality) ||
                other.audioQuality == audioQuality) &&
            (identical(other.audioSampleRate, audioSampleRate) ||
                other.audioSampleRate == audioSampleRate) &&
            (identical(other.bitrate, bitrate) || other.bitrate == bitrate) &&
            (identical(other.clen, clen) || other.clen == clen) &&
            (identical(other.container, container) ||
                other.container == container) &&
            (identical(other.encoding, encoding) ||
                other.encoding == encoding));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, url, type, audioQuality,
      audioSampleRate, bitrate, clen, container, encoding);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$YouTubeAudioFormatImplCopyWith<_$YouTubeAudioFormatImpl> get copyWith =>
      __$$YouTubeAudioFormatImplCopyWithImpl<_$YouTubeAudioFormatImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$YouTubeAudioFormatImplToJson(
      this,
    );
  }
}

abstract class _YouTubeAudioFormat implements YouTubeAudioFormat {
  const factory _YouTubeAudioFormat(
      {required final String url,
      required final String type,
      final String? audioQuality,
      final String? audioSampleRate,
      final int? bitrate,
      final int? clen,
      final String? container,
      final String? encoding}) = _$YouTubeAudioFormatImpl;

  factory _YouTubeAudioFormat.fromJson(Map<String, dynamic> json) =
      _$YouTubeAudioFormatImpl.fromJson;

  @override
  String get url;
  @override
  String get type;
  @override
  String? get audioQuality;
  @override
  String? get audioSampleRate;
  @override
  int? get bitrate;
  @override
  int? get clen;
  @override
  String? get container;
  @override
  String? get encoding;
  @override
  @JsonKey(ignore: true)
  _$$YouTubeAudioFormatImplCopyWith<_$YouTubeAudioFormatImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
