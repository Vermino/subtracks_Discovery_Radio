// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lidarr_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LidarrArtist _$LidarrArtistFromJson(Map<String, dynamic> json) {
  return _LidarrArtist.fromJson(json);
}

/// @nodoc
mixin _$LidarrArtist {
  String? get id =>
      throw _privateConstructorUsedError; // Lidarr internal ID (only present after being added)
  String get artistName => throw _privateConstructorUsedError;
  String get foreignArtistId =>
      throw _privateConstructorUsedError; // MusicBrainz ID
  String? get overview => throw _privateConstructorUsedError;
  List<LidarrImage>? get images => throw _privateConstructorUsedError;
  int? get qualityProfileId => throw _privateConstructorUsedError;
  int? get metadataProfileId => throw _privateConstructorUsedError;
  bool? get monitored => throw _privateConstructorUsedError;
  String? get rootFolderPath => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LidarrArtistCopyWith<LidarrArtist> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LidarrArtistCopyWith<$Res> {
  factory $LidarrArtistCopyWith(
          LidarrArtist value, $Res Function(LidarrArtist) then) =
      _$LidarrArtistCopyWithImpl<$Res, LidarrArtist>;
  @useResult
  $Res call(
      {String? id,
      String artistName,
      String foreignArtistId,
      String? overview,
      List<LidarrImage>? images,
      int? qualityProfileId,
      int? metadataProfileId,
      bool? monitored,
      String? rootFolderPath});
}

/// @nodoc
class _$LidarrArtistCopyWithImpl<$Res, $Val extends LidarrArtist>
    implements $LidarrArtistCopyWith<$Res> {
  _$LidarrArtistCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? artistName = null,
    Object? foreignArtistId = null,
    Object? overview = freezed,
    Object? images = freezed,
    Object? qualityProfileId = freezed,
    Object? metadataProfileId = freezed,
    Object? monitored = freezed,
    Object? rootFolderPath = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      artistName: null == artistName
          ? _value.artistName
          : artistName // ignore: cast_nullable_to_non_nullable
              as String,
      foreignArtistId: null == foreignArtistId
          ? _value.foreignArtistId
          : foreignArtistId // ignore: cast_nullable_to_non_nullable
              as String,
      overview: freezed == overview
          ? _value.overview
          : overview // ignore: cast_nullable_to_non_nullable
              as String?,
      images: freezed == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<LidarrImage>?,
      qualityProfileId: freezed == qualityProfileId
          ? _value.qualityProfileId
          : qualityProfileId // ignore: cast_nullable_to_non_nullable
              as int?,
      metadataProfileId: freezed == metadataProfileId
          ? _value.metadataProfileId
          : metadataProfileId // ignore: cast_nullable_to_non_nullable
              as int?,
      monitored: freezed == monitored
          ? _value.monitored
          : monitored // ignore: cast_nullable_to_non_nullable
              as bool?,
      rootFolderPath: freezed == rootFolderPath
          ? _value.rootFolderPath
          : rootFolderPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LidarrArtistImplCopyWith<$Res>
    implements $LidarrArtistCopyWith<$Res> {
  factory _$$LidarrArtistImplCopyWith(
          _$LidarrArtistImpl value, $Res Function(_$LidarrArtistImpl) then) =
      __$$LidarrArtistImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String artistName,
      String foreignArtistId,
      String? overview,
      List<LidarrImage>? images,
      int? qualityProfileId,
      int? metadataProfileId,
      bool? monitored,
      String? rootFolderPath});
}

/// @nodoc
class __$$LidarrArtistImplCopyWithImpl<$Res>
    extends _$LidarrArtistCopyWithImpl<$Res, _$LidarrArtistImpl>
    implements _$$LidarrArtistImplCopyWith<$Res> {
  __$$LidarrArtistImplCopyWithImpl(
      _$LidarrArtistImpl _value, $Res Function(_$LidarrArtistImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? artistName = null,
    Object? foreignArtistId = null,
    Object? overview = freezed,
    Object? images = freezed,
    Object? qualityProfileId = freezed,
    Object? metadataProfileId = freezed,
    Object? monitored = freezed,
    Object? rootFolderPath = freezed,
  }) {
    return _then(_$LidarrArtistImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      artistName: null == artistName
          ? _value.artistName
          : artistName // ignore: cast_nullable_to_non_nullable
              as String,
      foreignArtistId: null == foreignArtistId
          ? _value.foreignArtistId
          : foreignArtistId // ignore: cast_nullable_to_non_nullable
              as String,
      overview: freezed == overview
          ? _value.overview
          : overview // ignore: cast_nullable_to_non_nullable
              as String?,
      images: freezed == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<LidarrImage>?,
      qualityProfileId: freezed == qualityProfileId
          ? _value.qualityProfileId
          : qualityProfileId // ignore: cast_nullable_to_non_nullable
              as int?,
      metadataProfileId: freezed == metadataProfileId
          ? _value.metadataProfileId
          : metadataProfileId // ignore: cast_nullable_to_non_nullable
              as int?,
      monitored: freezed == monitored
          ? _value.monitored
          : monitored // ignore: cast_nullable_to_non_nullable
              as bool?,
      rootFolderPath: freezed == rootFolderPath
          ? _value.rootFolderPath
          : rootFolderPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LidarrArtistImpl implements _LidarrArtist {
  const _$LidarrArtistImpl(
      {this.id,
      required this.artistName,
      required this.foreignArtistId,
      this.overview,
      final List<LidarrImage>? images,
      this.qualityProfileId,
      this.metadataProfileId,
      this.monitored,
      this.rootFolderPath})
      : _images = images;

  factory _$LidarrArtistImpl.fromJson(Map<String, dynamic> json) =>
      _$$LidarrArtistImplFromJson(json);

  @override
  final String? id;
// Lidarr internal ID (only present after being added)
  @override
  final String artistName;
  @override
  final String foreignArtistId;
// MusicBrainz ID
  @override
  final String? overview;
  final List<LidarrImage>? _images;
  @override
  List<LidarrImage>? get images {
    final value = _images;
    if (value == null) return null;
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? qualityProfileId;
  @override
  final int? metadataProfileId;
  @override
  final bool? monitored;
  @override
  final String? rootFolderPath;

  @override
  String toString() {
    return 'LidarrArtist(id: $id, artistName: $artistName, foreignArtistId: $foreignArtistId, overview: $overview, images: $images, qualityProfileId: $qualityProfileId, metadataProfileId: $metadataProfileId, monitored: $monitored, rootFolderPath: $rootFolderPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LidarrArtistImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.artistName, artistName) ||
                other.artistName == artistName) &&
            (identical(other.foreignArtistId, foreignArtistId) ||
                other.foreignArtistId == foreignArtistId) &&
            (identical(other.overview, overview) ||
                other.overview == overview) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.qualityProfileId, qualityProfileId) ||
                other.qualityProfileId == qualityProfileId) &&
            (identical(other.metadataProfileId, metadataProfileId) ||
                other.metadataProfileId == metadataProfileId) &&
            (identical(other.monitored, monitored) ||
                other.monitored == monitored) &&
            (identical(other.rootFolderPath, rootFolderPath) ||
                other.rootFolderPath == rootFolderPath));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      artistName,
      foreignArtistId,
      overview,
      const DeepCollectionEquality().hash(_images),
      qualityProfileId,
      metadataProfileId,
      monitored,
      rootFolderPath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LidarrArtistImplCopyWith<_$LidarrArtistImpl> get copyWith =>
      __$$LidarrArtistImplCopyWithImpl<_$LidarrArtistImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LidarrArtistImplToJson(
      this,
    );
  }
}

abstract class _LidarrArtist implements LidarrArtist {
  const factory _LidarrArtist(
      {final String? id,
      required final String artistName,
      required final String foreignArtistId,
      final String? overview,
      final List<LidarrImage>? images,
      final int? qualityProfileId,
      final int? metadataProfileId,
      final bool? monitored,
      final String? rootFolderPath}) = _$LidarrArtistImpl;

  factory _LidarrArtist.fromJson(Map<String, dynamic> json) =
      _$LidarrArtistImpl.fromJson;

  @override
  String? get id;
  @override // Lidarr internal ID (only present after being added)
  String get artistName;
  @override
  String get foreignArtistId;
  @override // MusicBrainz ID
  String? get overview;
  @override
  List<LidarrImage>? get images;
  @override
  int? get qualityProfileId;
  @override
  int? get metadataProfileId;
  @override
  bool? get monitored;
  @override
  String? get rootFolderPath;
  @override
  @JsonKey(ignore: true)
  _$$LidarrArtistImplCopyWith<_$LidarrArtistImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LidarrImage _$LidarrImageFromJson(Map<String, dynamic> json) {
  return _LidarrImage.fromJson(json);
}

/// @nodoc
mixin _$LidarrImage {
  String get url => throw _privateConstructorUsedError;
  String? get coverType => throw _privateConstructorUsedError;
  String? get extension => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LidarrImageCopyWith<LidarrImage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LidarrImageCopyWith<$Res> {
  factory $LidarrImageCopyWith(
          LidarrImage value, $Res Function(LidarrImage) then) =
      _$LidarrImageCopyWithImpl<$Res, LidarrImage>;
  @useResult
  $Res call({String url, String? coverType, String? extension});
}

/// @nodoc
class _$LidarrImageCopyWithImpl<$Res, $Val extends LidarrImage>
    implements $LidarrImageCopyWith<$Res> {
  _$LidarrImageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? coverType = freezed,
    Object? extension = freezed,
  }) {
    return _then(_value.copyWith(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      coverType: freezed == coverType
          ? _value.coverType
          : coverType // ignore: cast_nullable_to_non_nullable
              as String?,
      extension: freezed == extension
          ? _value.extension
          : extension // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LidarrImageImplCopyWith<$Res>
    implements $LidarrImageCopyWith<$Res> {
  factory _$$LidarrImageImplCopyWith(
          _$LidarrImageImpl value, $Res Function(_$LidarrImageImpl) then) =
      __$$LidarrImageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String url, String? coverType, String? extension});
}

/// @nodoc
class __$$LidarrImageImplCopyWithImpl<$Res>
    extends _$LidarrImageCopyWithImpl<$Res, _$LidarrImageImpl>
    implements _$$LidarrImageImplCopyWith<$Res> {
  __$$LidarrImageImplCopyWithImpl(
      _$LidarrImageImpl _value, $Res Function(_$LidarrImageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? coverType = freezed,
    Object? extension = freezed,
  }) {
    return _then(_$LidarrImageImpl(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      coverType: freezed == coverType
          ? _value.coverType
          : coverType // ignore: cast_nullable_to_non_nullable
              as String?,
      extension: freezed == extension
          ? _value.extension
          : extension // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LidarrImageImpl implements _LidarrImage {
  const _$LidarrImageImpl({required this.url, this.coverType, this.extension});

  factory _$LidarrImageImpl.fromJson(Map<String, dynamic> json) =>
      _$$LidarrImageImplFromJson(json);

  @override
  final String url;
  @override
  final String? coverType;
  @override
  final String? extension;

  @override
  String toString() {
    return 'LidarrImage(url: $url, coverType: $coverType, extension: $extension)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LidarrImageImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.coverType, coverType) ||
                other.coverType == coverType) &&
            (identical(other.extension, extension) ||
                other.extension == extension));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, url, coverType, extension);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LidarrImageImplCopyWith<_$LidarrImageImpl> get copyWith =>
      __$$LidarrImageImplCopyWithImpl<_$LidarrImageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LidarrImageImplToJson(
      this,
    );
  }
}

abstract class _LidarrImage implements LidarrImage {
  const factory _LidarrImage(
      {required final String url,
      final String? coverType,
      final String? extension}) = _$LidarrImageImpl;

  factory _LidarrImage.fromJson(Map<String, dynamic> json) =
      _$LidarrImageImpl.fromJson;

  @override
  String get url;
  @override
  String? get coverType;
  @override
  String? get extension;
  @override
  @JsonKey(ignore: true)
  _$$LidarrImageImplCopyWith<_$LidarrImageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$LidarrDownloadResult {
  String get message => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String artistName, String foreignArtistId, String message)
        success,
    required TResult Function(String artistName, String message) alreadyExists,
    required TResult Function(String message) notFound,
    required TResult Function(String message, Object? error) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String artistName, String foreignArtistId, String message)?
        success,
    TResult? Function(String artistName, String message)? alreadyExists,
    TResult? Function(String message)? notFound,
    TResult? Function(String message, Object? error)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String artistName, String foreignArtistId, String message)?
        success,
    TResult Function(String artistName, String message)? alreadyExists,
    TResult Function(String message)? notFound,
    TResult Function(String message, Object? error)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LidarrDownloadSuccess value) success,
    required TResult Function(LidarrDownloadAlreadyExists value) alreadyExists,
    required TResult Function(LidarrDownloadNotFound value) notFound,
    required TResult Function(LidarrDownloadError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LidarrDownloadSuccess value)? success,
    TResult? Function(LidarrDownloadAlreadyExists value)? alreadyExists,
    TResult? Function(LidarrDownloadNotFound value)? notFound,
    TResult? Function(LidarrDownloadError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LidarrDownloadSuccess value)? success,
    TResult Function(LidarrDownloadAlreadyExists value)? alreadyExists,
    TResult Function(LidarrDownloadNotFound value)? notFound,
    TResult Function(LidarrDownloadError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $LidarrDownloadResultCopyWith<LidarrDownloadResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LidarrDownloadResultCopyWith<$Res> {
  factory $LidarrDownloadResultCopyWith(LidarrDownloadResult value,
          $Res Function(LidarrDownloadResult) then) =
      _$LidarrDownloadResultCopyWithImpl<$Res, LidarrDownloadResult>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$LidarrDownloadResultCopyWithImpl<$Res,
        $Val extends LidarrDownloadResult>
    implements $LidarrDownloadResultCopyWith<$Res> {
  _$LidarrDownloadResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LidarrDownloadSuccessImplCopyWith<$Res>
    implements $LidarrDownloadResultCopyWith<$Res> {
  factory _$$LidarrDownloadSuccessImplCopyWith(
          _$LidarrDownloadSuccessImpl value,
          $Res Function(_$LidarrDownloadSuccessImpl) then) =
      __$$LidarrDownloadSuccessImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String artistName, String foreignArtistId, String message});
}

/// @nodoc
class __$$LidarrDownloadSuccessImplCopyWithImpl<$Res>
    extends _$LidarrDownloadResultCopyWithImpl<$Res,
        _$LidarrDownloadSuccessImpl>
    implements _$$LidarrDownloadSuccessImplCopyWith<$Res> {
  __$$LidarrDownloadSuccessImplCopyWithImpl(_$LidarrDownloadSuccessImpl _value,
      $Res Function(_$LidarrDownloadSuccessImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? artistName = null,
    Object? foreignArtistId = null,
    Object? message = null,
  }) {
    return _then(_$LidarrDownloadSuccessImpl(
      artistName: null == artistName
          ? _value.artistName
          : artistName // ignore: cast_nullable_to_non_nullable
              as String,
      foreignArtistId: null == foreignArtistId
          ? _value.foreignArtistId
          : foreignArtistId // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$LidarrDownloadSuccessImpl implements LidarrDownloadSuccess {
  const _$LidarrDownloadSuccessImpl(
      {required this.artistName,
      required this.foreignArtistId,
      required this.message});

  @override
  final String artistName;
  @override
  final String foreignArtistId;
  @override
  final String message;

  @override
  String toString() {
    return 'LidarrDownloadResult.success(artistName: $artistName, foreignArtistId: $foreignArtistId, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LidarrDownloadSuccessImpl &&
            (identical(other.artistName, artistName) ||
                other.artistName == artistName) &&
            (identical(other.foreignArtistId, foreignArtistId) ||
                other.foreignArtistId == foreignArtistId) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, artistName, foreignArtistId, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LidarrDownloadSuccessImplCopyWith<_$LidarrDownloadSuccessImpl>
      get copyWith => __$$LidarrDownloadSuccessImplCopyWithImpl<
          _$LidarrDownloadSuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String artistName, String foreignArtistId, String message)
        success,
    required TResult Function(String artistName, String message) alreadyExists,
    required TResult Function(String message) notFound,
    required TResult Function(String message, Object? error) error,
  }) {
    return success(artistName, foreignArtistId, message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String artistName, String foreignArtistId, String message)?
        success,
    TResult? Function(String artistName, String message)? alreadyExists,
    TResult? Function(String message)? notFound,
    TResult? Function(String message, Object? error)? error,
  }) {
    return success?.call(artistName, foreignArtistId, message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String artistName, String foreignArtistId, String message)?
        success,
    TResult Function(String artistName, String message)? alreadyExists,
    TResult Function(String message)? notFound,
    TResult Function(String message, Object? error)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(artistName, foreignArtistId, message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LidarrDownloadSuccess value) success,
    required TResult Function(LidarrDownloadAlreadyExists value) alreadyExists,
    required TResult Function(LidarrDownloadNotFound value) notFound,
    required TResult Function(LidarrDownloadError value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LidarrDownloadSuccess value)? success,
    TResult? Function(LidarrDownloadAlreadyExists value)? alreadyExists,
    TResult? Function(LidarrDownloadNotFound value)? notFound,
    TResult? Function(LidarrDownloadError value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LidarrDownloadSuccess value)? success,
    TResult Function(LidarrDownloadAlreadyExists value)? alreadyExists,
    TResult Function(LidarrDownloadNotFound value)? notFound,
    TResult Function(LidarrDownloadError value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class LidarrDownloadSuccess implements LidarrDownloadResult {
  const factory LidarrDownloadSuccess(
      {required final String artistName,
      required final String foreignArtistId,
      required final String message}) = _$LidarrDownloadSuccessImpl;

  String get artistName;
  String get foreignArtistId;
  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$LidarrDownloadSuccessImplCopyWith<_$LidarrDownloadSuccessImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LidarrDownloadAlreadyExistsImplCopyWith<$Res>
    implements $LidarrDownloadResultCopyWith<$Res> {
  factory _$$LidarrDownloadAlreadyExistsImplCopyWith(
          _$LidarrDownloadAlreadyExistsImpl value,
          $Res Function(_$LidarrDownloadAlreadyExistsImpl) then) =
      __$$LidarrDownloadAlreadyExistsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String artistName, String message});
}

/// @nodoc
class __$$LidarrDownloadAlreadyExistsImplCopyWithImpl<$Res>
    extends _$LidarrDownloadResultCopyWithImpl<$Res,
        _$LidarrDownloadAlreadyExistsImpl>
    implements _$$LidarrDownloadAlreadyExistsImplCopyWith<$Res> {
  __$$LidarrDownloadAlreadyExistsImplCopyWithImpl(
      _$LidarrDownloadAlreadyExistsImpl _value,
      $Res Function(_$LidarrDownloadAlreadyExistsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? artistName = null,
    Object? message = null,
  }) {
    return _then(_$LidarrDownloadAlreadyExistsImpl(
      artistName: null == artistName
          ? _value.artistName
          : artistName // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$LidarrDownloadAlreadyExistsImpl implements LidarrDownloadAlreadyExists {
  const _$LidarrDownloadAlreadyExistsImpl(
      {required this.artistName, required this.message});

  @override
  final String artistName;
  @override
  final String message;

  @override
  String toString() {
    return 'LidarrDownloadResult.alreadyExists(artistName: $artistName, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LidarrDownloadAlreadyExistsImpl &&
            (identical(other.artistName, artistName) ||
                other.artistName == artistName) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, artistName, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LidarrDownloadAlreadyExistsImplCopyWith<_$LidarrDownloadAlreadyExistsImpl>
      get copyWith => __$$LidarrDownloadAlreadyExistsImplCopyWithImpl<
          _$LidarrDownloadAlreadyExistsImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String artistName, String foreignArtistId, String message)
        success,
    required TResult Function(String artistName, String message) alreadyExists,
    required TResult Function(String message) notFound,
    required TResult Function(String message, Object? error) error,
  }) {
    return alreadyExists(artistName, message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String artistName, String foreignArtistId, String message)?
        success,
    TResult? Function(String artistName, String message)? alreadyExists,
    TResult? Function(String message)? notFound,
    TResult? Function(String message, Object? error)? error,
  }) {
    return alreadyExists?.call(artistName, message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String artistName, String foreignArtistId, String message)?
        success,
    TResult Function(String artistName, String message)? alreadyExists,
    TResult Function(String message)? notFound,
    TResult Function(String message, Object? error)? error,
    required TResult orElse(),
  }) {
    if (alreadyExists != null) {
      return alreadyExists(artistName, message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LidarrDownloadSuccess value) success,
    required TResult Function(LidarrDownloadAlreadyExists value) alreadyExists,
    required TResult Function(LidarrDownloadNotFound value) notFound,
    required TResult Function(LidarrDownloadError value) error,
  }) {
    return alreadyExists(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LidarrDownloadSuccess value)? success,
    TResult? Function(LidarrDownloadAlreadyExists value)? alreadyExists,
    TResult? Function(LidarrDownloadNotFound value)? notFound,
    TResult? Function(LidarrDownloadError value)? error,
  }) {
    return alreadyExists?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LidarrDownloadSuccess value)? success,
    TResult Function(LidarrDownloadAlreadyExists value)? alreadyExists,
    TResult Function(LidarrDownloadNotFound value)? notFound,
    TResult Function(LidarrDownloadError value)? error,
    required TResult orElse(),
  }) {
    if (alreadyExists != null) {
      return alreadyExists(this);
    }
    return orElse();
  }
}

abstract class LidarrDownloadAlreadyExists implements LidarrDownloadResult {
  const factory LidarrDownloadAlreadyExists(
      {required final String artistName,
      required final String message}) = _$LidarrDownloadAlreadyExistsImpl;

  String get artistName;
  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$LidarrDownloadAlreadyExistsImplCopyWith<_$LidarrDownloadAlreadyExistsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LidarrDownloadNotFoundImplCopyWith<$Res>
    implements $LidarrDownloadResultCopyWith<$Res> {
  factory _$$LidarrDownloadNotFoundImplCopyWith(
          _$LidarrDownloadNotFoundImpl value,
          $Res Function(_$LidarrDownloadNotFoundImpl) then) =
      __$$LidarrDownloadNotFoundImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$LidarrDownloadNotFoundImplCopyWithImpl<$Res>
    extends _$LidarrDownloadResultCopyWithImpl<$Res,
        _$LidarrDownloadNotFoundImpl>
    implements _$$LidarrDownloadNotFoundImplCopyWith<$Res> {
  __$$LidarrDownloadNotFoundImplCopyWithImpl(
      _$LidarrDownloadNotFoundImpl _value,
      $Res Function(_$LidarrDownloadNotFoundImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$LidarrDownloadNotFoundImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$LidarrDownloadNotFoundImpl implements LidarrDownloadNotFound {
  const _$LidarrDownloadNotFoundImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'LidarrDownloadResult.notFound(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LidarrDownloadNotFoundImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LidarrDownloadNotFoundImplCopyWith<_$LidarrDownloadNotFoundImpl>
      get copyWith => __$$LidarrDownloadNotFoundImplCopyWithImpl<
          _$LidarrDownloadNotFoundImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String artistName, String foreignArtistId, String message)
        success,
    required TResult Function(String artistName, String message) alreadyExists,
    required TResult Function(String message) notFound,
    required TResult Function(String message, Object? error) error,
  }) {
    return notFound(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String artistName, String foreignArtistId, String message)?
        success,
    TResult? Function(String artistName, String message)? alreadyExists,
    TResult? Function(String message)? notFound,
    TResult? Function(String message, Object? error)? error,
  }) {
    return notFound?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String artistName, String foreignArtistId, String message)?
        success,
    TResult Function(String artistName, String message)? alreadyExists,
    TResult Function(String message)? notFound,
    TResult Function(String message, Object? error)? error,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LidarrDownloadSuccess value) success,
    required TResult Function(LidarrDownloadAlreadyExists value) alreadyExists,
    required TResult Function(LidarrDownloadNotFound value) notFound,
    required TResult Function(LidarrDownloadError value) error,
  }) {
    return notFound(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LidarrDownloadSuccess value)? success,
    TResult? Function(LidarrDownloadAlreadyExists value)? alreadyExists,
    TResult? Function(LidarrDownloadNotFound value)? notFound,
    TResult? Function(LidarrDownloadError value)? error,
  }) {
    return notFound?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LidarrDownloadSuccess value)? success,
    TResult Function(LidarrDownloadAlreadyExists value)? alreadyExists,
    TResult Function(LidarrDownloadNotFound value)? notFound,
    TResult Function(LidarrDownloadError value)? error,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(this);
    }
    return orElse();
  }
}

abstract class LidarrDownloadNotFound implements LidarrDownloadResult {
  const factory LidarrDownloadNotFound({required final String message}) =
      _$LidarrDownloadNotFoundImpl;

  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$LidarrDownloadNotFoundImplCopyWith<_$LidarrDownloadNotFoundImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LidarrDownloadErrorImplCopyWith<$Res>
    implements $LidarrDownloadResultCopyWith<$Res> {
  factory _$$LidarrDownloadErrorImplCopyWith(_$LidarrDownloadErrorImpl value,
          $Res Function(_$LidarrDownloadErrorImpl) then) =
      __$$LidarrDownloadErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, Object? error});
}

/// @nodoc
class __$$LidarrDownloadErrorImplCopyWithImpl<$Res>
    extends _$LidarrDownloadResultCopyWithImpl<$Res, _$LidarrDownloadErrorImpl>
    implements _$$LidarrDownloadErrorImplCopyWith<$Res> {
  __$$LidarrDownloadErrorImplCopyWithImpl(_$LidarrDownloadErrorImpl _value,
      $Res Function(_$LidarrDownloadErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? error = freezed,
  }) {
    return _then(_$LidarrDownloadErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      error: freezed == error ? _value.error : error,
    ));
  }
}

/// @nodoc

class _$LidarrDownloadErrorImpl implements LidarrDownloadError {
  const _$LidarrDownloadErrorImpl({required this.message, this.error});

  @override
  final String message;
  @override
  final Object? error;

  @override
  String toString() {
    return 'LidarrDownloadResult.error(message: $message, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LidarrDownloadErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other.error, error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, message, const DeepCollectionEquality().hash(error));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LidarrDownloadErrorImplCopyWith<_$LidarrDownloadErrorImpl> get copyWith =>
      __$$LidarrDownloadErrorImplCopyWithImpl<_$LidarrDownloadErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String artistName, String foreignArtistId, String message)
        success,
    required TResult Function(String artistName, String message) alreadyExists,
    required TResult Function(String message) notFound,
    required TResult Function(String message, Object? error) error,
  }) {
    return error(message, this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String artistName, String foreignArtistId, String message)?
        success,
    TResult? Function(String artistName, String message)? alreadyExists,
    TResult? Function(String message)? notFound,
    TResult? Function(String message, Object? error)? error,
  }) {
    return error?.call(message, this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String artistName, String foreignArtistId, String message)?
        success,
    TResult Function(String artistName, String message)? alreadyExists,
    TResult Function(String message)? notFound,
    TResult Function(String message, Object? error)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message, this.error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LidarrDownloadSuccess value) success,
    required TResult Function(LidarrDownloadAlreadyExists value) alreadyExists,
    required TResult Function(LidarrDownloadNotFound value) notFound,
    required TResult Function(LidarrDownloadError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LidarrDownloadSuccess value)? success,
    TResult? Function(LidarrDownloadAlreadyExists value)? alreadyExists,
    TResult? Function(LidarrDownloadNotFound value)? notFound,
    TResult? Function(LidarrDownloadError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LidarrDownloadSuccess value)? success,
    TResult Function(LidarrDownloadAlreadyExists value)? alreadyExists,
    TResult Function(LidarrDownloadNotFound value)? notFound,
    TResult Function(LidarrDownloadError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class LidarrDownloadError implements LidarrDownloadResult {
  const factory LidarrDownloadError(
      {required final String message,
      final Object? error}) = _$LidarrDownloadErrorImpl;

  @override
  String get message;
  Object? get error;
  @override
  @JsonKey(ignore: true)
  _$$LidarrDownloadErrorImplCopyWith<_$LidarrDownloadErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LidarrQualityProfile _$LidarrQualityProfileFromJson(Map<String, dynamic> json) {
  return _LidarrQualityProfile.fromJson(json);
}

/// @nodoc
mixin _$LidarrQualityProfile {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LidarrQualityProfileCopyWith<LidarrQualityProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LidarrQualityProfileCopyWith<$Res> {
  factory $LidarrQualityProfileCopyWith(LidarrQualityProfile value,
          $Res Function(LidarrQualityProfile) then) =
      _$LidarrQualityProfileCopyWithImpl<$Res, LidarrQualityProfile>;
  @useResult
  $Res call({int id, String name});
}

/// @nodoc
class _$LidarrQualityProfileCopyWithImpl<$Res,
        $Val extends LidarrQualityProfile>
    implements $LidarrQualityProfileCopyWith<$Res> {
  _$LidarrQualityProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LidarrQualityProfileImplCopyWith<$Res>
    implements $LidarrQualityProfileCopyWith<$Res> {
  factory _$$LidarrQualityProfileImplCopyWith(_$LidarrQualityProfileImpl value,
          $Res Function(_$LidarrQualityProfileImpl) then) =
      __$$LidarrQualityProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name});
}

/// @nodoc
class __$$LidarrQualityProfileImplCopyWithImpl<$Res>
    extends _$LidarrQualityProfileCopyWithImpl<$Res, _$LidarrQualityProfileImpl>
    implements _$$LidarrQualityProfileImplCopyWith<$Res> {
  __$$LidarrQualityProfileImplCopyWithImpl(_$LidarrQualityProfileImpl _value,
      $Res Function(_$LidarrQualityProfileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_$LidarrQualityProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LidarrQualityProfileImpl implements _LidarrQualityProfile {
  const _$LidarrQualityProfileImpl({required this.id, required this.name});

  factory _$LidarrQualityProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$LidarrQualityProfileImplFromJson(json);

  @override
  final int id;
  @override
  final String name;

  @override
  String toString() {
    return 'LidarrQualityProfile(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LidarrQualityProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LidarrQualityProfileImplCopyWith<_$LidarrQualityProfileImpl>
      get copyWith =>
          __$$LidarrQualityProfileImplCopyWithImpl<_$LidarrQualityProfileImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LidarrQualityProfileImplToJson(
      this,
    );
  }
}

abstract class _LidarrQualityProfile implements LidarrQualityProfile {
  const factory _LidarrQualityProfile(
      {required final int id,
      required final String name}) = _$LidarrQualityProfileImpl;

  factory _LidarrQualityProfile.fromJson(Map<String, dynamic> json) =
      _$LidarrQualityProfileImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  @JsonKey(ignore: true)
  _$$LidarrQualityProfileImplCopyWith<_$LidarrQualityProfileImpl>
      get copyWith => throw _privateConstructorUsedError;
}

LidarrRootFolder _$LidarrRootFolderFromJson(Map<String, dynamic> json) {
  return _LidarrRootFolder.fromJson(json);
}

/// @nodoc
mixin _$LidarrRootFolder {
  int get id => throw _privateConstructorUsedError;
  String get path => throw _privateConstructorUsedError;
  int? get freeSpace => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LidarrRootFolderCopyWith<LidarrRootFolder> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LidarrRootFolderCopyWith<$Res> {
  factory $LidarrRootFolderCopyWith(
          LidarrRootFolder value, $Res Function(LidarrRootFolder) then) =
      _$LidarrRootFolderCopyWithImpl<$Res, LidarrRootFolder>;
  @useResult
  $Res call({int id, String path, int? freeSpace});
}

/// @nodoc
class _$LidarrRootFolderCopyWithImpl<$Res, $Val extends LidarrRootFolder>
    implements $LidarrRootFolderCopyWith<$Res> {
  _$LidarrRootFolderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? path = null,
    Object? freeSpace = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      freeSpace: freezed == freeSpace
          ? _value.freeSpace
          : freeSpace // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LidarrRootFolderImplCopyWith<$Res>
    implements $LidarrRootFolderCopyWith<$Res> {
  factory _$$LidarrRootFolderImplCopyWith(_$LidarrRootFolderImpl value,
          $Res Function(_$LidarrRootFolderImpl) then) =
      __$$LidarrRootFolderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String path, int? freeSpace});
}

/// @nodoc
class __$$LidarrRootFolderImplCopyWithImpl<$Res>
    extends _$LidarrRootFolderCopyWithImpl<$Res, _$LidarrRootFolderImpl>
    implements _$$LidarrRootFolderImplCopyWith<$Res> {
  __$$LidarrRootFolderImplCopyWithImpl(_$LidarrRootFolderImpl _value,
      $Res Function(_$LidarrRootFolderImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? path = null,
    Object? freeSpace = freezed,
  }) {
    return _then(_$LidarrRootFolderImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      freeSpace: freezed == freeSpace
          ? _value.freeSpace
          : freeSpace // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LidarrRootFolderImpl implements _LidarrRootFolder {
  const _$LidarrRootFolderImpl(
      {required this.id, required this.path, this.freeSpace});

  factory _$LidarrRootFolderImpl.fromJson(Map<String, dynamic> json) =>
      _$$LidarrRootFolderImplFromJson(json);

  @override
  final int id;
  @override
  final String path;
  @override
  final int? freeSpace;

  @override
  String toString() {
    return 'LidarrRootFolder(id: $id, path: $path, freeSpace: $freeSpace)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LidarrRootFolderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.freeSpace, freeSpace) ||
                other.freeSpace == freeSpace));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, path, freeSpace);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LidarrRootFolderImplCopyWith<_$LidarrRootFolderImpl> get copyWith =>
      __$$LidarrRootFolderImplCopyWithImpl<_$LidarrRootFolderImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LidarrRootFolderImplToJson(
      this,
    );
  }
}

abstract class _LidarrRootFolder implements LidarrRootFolder {
  const factory _LidarrRootFolder(
      {required final int id,
      required final String path,
      final int? freeSpace}) = _$LidarrRootFolderImpl;

  factory _LidarrRootFolder.fromJson(Map<String, dynamic> json) =
      _$LidarrRootFolderImpl.fromJson;

  @override
  int get id;
  @override
  String get path;
  @override
  int? get freeSpace;
  @override
  @JsonKey(ignore: true)
  _$$LidarrRootFolderImplCopyWith<_$LidarrRootFolderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
