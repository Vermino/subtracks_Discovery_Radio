// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hybrid_track.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$HybridTrack {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Song song) local,
    required TResult Function(String videoId, String title, String artist,
            int durationSeconds, String? thumbnailUrl, UserRating userRating)
        youtube,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Song song)? local,
    TResult? Function(String videoId, String title, String artist,
            int durationSeconds, String? thumbnailUrl, UserRating userRating)?
        youtube,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Song song)? local,
    TResult Function(String videoId, String title, String artist,
            int durationSeconds, String? thumbnailUrl, UserRating userRating)?
        youtube,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LocalTrack value) local,
    required TResult Function(YouTubeTrack value) youtube,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LocalTrack value)? local,
    TResult? Function(YouTubeTrack value)? youtube,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LocalTrack value)? local,
    TResult Function(YouTubeTrack value)? youtube,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HybridTrackCopyWith<$Res> {
  factory $HybridTrackCopyWith(
          HybridTrack value, $Res Function(HybridTrack) then) =
      _$HybridTrackCopyWithImpl<$Res, HybridTrack>;
}

/// @nodoc
class _$HybridTrackCopyWithImpl<$Res, $Val extends HybridTrack>
    implements $HybridTrackCopyWith<$Res> {
  _$HybridTrackCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$LocalTrackImplCopyWith<$Res> {
  factory _$$LocalTrackImplCopyWith(
          _$LocalTrackImpl value, $Res Function(_$LocalTrackImpl) then) =
      __$$LocalTrackImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Song song});

  $SongCopyWith<$Res> get song;
}

/// @nodoc
class __$$LocalTrackImplCopyWithImpl<$Res>
    extends _$HybridTrackCopyWithImpl<$Res, _$LocalTrackImpl>
    implements _$$LocalTrackImplCopyWith<$Res> {
  __$$LocalTrackImplCopyWithImpl(
      _$LocalTrackImpl _value, $Res Function(_$LocalTrackImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? song = null,
  }) {
    return _then(_$LocalTrackImpl(
      song: null == song
          ? _value.song
          : song // ignore: cast_nullable_to_non_nullable
              as Song,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $SongCopyWith<$Res> get song {
    return $SongCopyWith<$Res>(_value.song, (value) {
      return _then(_value.copyWith(song: value));
    });
  }
}

/// @nodoc

class _$LocalTrackImpl implements LocalTrack {
  const _$LocalTrackImpl({required this.song});

  @override
  final Song song;

  @override
  String toString() {
    return 'HybridTrack.local(song: $song)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocalTrackImpl &&
            (identical(other.song, song) || other.song == song));
  }

  @override
  int get hashCode => Object.hash(runtimeType, song);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LocalTrackImplCopyWith<_$LocalTrackImpl> get copyWith =>
      __$$LocalTrackImplCopyWithImpl<_$LocalTrackImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Song song) local,
    required TResult Function(String videoId, String title, String artist,
            int durationSeconds, String? thumbnailUrl, UserRating userRating)
        youtube,
  }) {
    return local(song);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Song song)? local,
    TResult? Function(String videoId, String title, String artist,
            int durationSeconds, String? thumbnailUrl, UserRating userRating)?
        youtube,
  }) {
    return local?.call(song);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Song song)? local,
    TResult Function(String videoId, String title, String artist,
            int durationSeconds, String? thumbnailUrl, UserRating userRating)?
        youtube,
    required TResult orElse(),
  }) {
    if (local != null) {
      return local(song);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LocalTrack value) local,
    required TResult Function(YouTubeTrack value) youtube,
  }) {
    return local(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LocalTrack value)? local,
    TResult? Function(YouTubeTrack value)? youtube,
  }) {
    return local?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LocalTrack value)? local,
    TResult Function(YouTubeTrack value)? youtube,
    required TResult orElse(),
  }) {
    if (local != null) {
      return local(this);
    }
    return orElse();
  }
}

abstract class LocalTrack implements HybridTrack {
  const factory LocalTrack({required final Song song}) = _$LocalTrackImpl;

  Song get song;
  @JsonKey(ignore: true)
  _$$LocalTrackImplCopyWith<_$LocalTrackImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$YouTubeTrackImplCopyWith<$Res> {
  factory _$$YouTubeTrackImplCopyWith(
          _$YouTubeTrackImpl value, $Res Function(_$YouTubeTrackImpl) then) =
      __$$YouTubeTrackImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {String videoId,
      String title,
      String artist,
      int durationSeconds,
      String? thumbnailUrl,
      UserRating userRating});
}

/// @nodoc
class __$$YouTubeTrackImplCopyWithImpl<$Res>
    extends _$HybridTrackCopyWithImpl<$Res, _$YouTubeTrackImpl>
    implements _$$YouTubeTrackImplCopyWith<$Res> {
  __$$YouTubeTrackImplCopyWithImpl(
      _$YouTubeTrackImpl _value, $Res Function(_$YouTubeTrackImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? videoId = null,
    Object? title = null,
    Object? artist = null,
    Object? durationSeconds = null,
    Object? thumbnailUrl = freezed,
    Object? userRating = null,
  }) {
    return _then(_$YouTubeTrackImpl(
      videoId: null == videoId
          ? _value.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      artist: null == artist
          ? _value.artist
          : artist // ignore: cast_nullable_to_non_nullable
              as String,
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      userRating: null == userRating
          ? _value.userRating
          : userRating // ignore: cast_nullable_to_non_nullable
              as UserRating,
    ));
  }
}

/// @nodoc

class _$YouTubeTrackImpl implements YouTubeTrack {
  const _$YouTubeTrackImpl(
      {required this.videoId,
      required this.title,
      required this.artist,
      required this.durationSeconds,
      this.thumbnailUrl,
      this.userRating = UserRating.unrated});

  @override
  final String videoId;
  @override
  final String title;
  @override
  final String artist;
  @override
  final int durationSeconds;
  @override
  final String? thumbnailUrl;
  @override
  @JsonKey()
  final UserRating userRating;

  @override
  String toString() {
    return 'HybridTrack.youtube(videoId: $videoId, title: $title, artist: $artist, durationSeconds: $durationSeconds, thumbnailUrl: $thumbnailUrl, userRating: $userRating)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$YouTubeTrackImpl &&
            (identical(other.videoId, videoId) || other.videoId == videoId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.artist, artist) || other.artist == artist) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.userRating, userRating) ||
                other.userRating == userRating));
  }

  @override
  int get hashCode => Object.hash(runtimeType, videoId, title, artist,
      durationSeconds, thumbnailUrl, userRating);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$YouTubeTrackImplCopyWith<_$YouTubeTrackImpl> get copyWith =>
      __$$YouTubeTrackImplCopyWithImpl<_$YouTubeTrackImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Song song) local,
    required TResult Function(String videoId, String title, String artist,
            int durationSeconds, String? thumbnailUrl, UserRating userRating)
        youtube,
  }) {
    return youtube(
        videoId, title, artist, durationSeconds, thumbnailUrl, userRating);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Song song)? local,
    TResult? Function(String videoId, String title, String artist,
            int durationSeconds, String? thumbnailUrl, UserRating userRating)?
        youtube,
  }) {
    return youtube?.call(
        videoId, title, artist, durationSeconds, thumbnailUrl, userRating);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Song song)? local,
    TResult Function(String videoId, String title, String artist,
            int durationSeconds, String? thumbnailUrl, UserRating userRating)?
        youtube,
    required TResult orElse(),
  }) {
    if (youtube != null) {
      return youtube(
          videoId, title, artist, durationSeconds, thumbnailUrl, userRating);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LocalTrack value) local,
    required TResult Function(YouTubeTrack value) youtube,
  }) {
    return youtube(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LocalTrack value)? local,
    TResult? Function(YouTubeTrack value)? youtube,
  }) {
    return youtube?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LocalTrack value)? local,
    TResult Function(YouTubeTrack value)? youtube,
    required TResult orElse(),
  }) {
    if (youtube != null) {
      return youtube(this);
    }
    return orElse();
  }
}

abstract class YouTubeTrack implements HybridTrack {
  const factory YouTubeTrack(
      {required final String videoId,
      required final String title,
      required final String artist,
      required final int durationSeconds,
      final String? thumbnailUrl,
      final UserRating userRating}) = _$YouTubeTrackImpl;

  String get videoId;
  String get title;
  String get artist;
  int get durationSeconds;
  String? get thumbnailUrl;
  UserRating get userRating;
  @JsonKey(ignore: true)
  _$$YouTubeTrackImplCopyWith<_$YouTubeTrackImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
