// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browse_page.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$albumsCategoryListHash() =>
    r'e0516a585bf39e8140c72c08fd41f33a817c747d';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [albumsCategoryList].
@ProviderFor(albumsCategoryList)
const albumsCategoryListProvider = AlbumsCategoryListFamily();

/// See also [albumsCategoryList].
class AlbumsCategoryListFamily extends Family<AsyncValue<List<Album>>> {
  /// See also [albumsCategoryList].
  const AlbumsCategoryListFamily();

  /// See also [albumsCategoryList].
  AlbumsCategoryListProvider call(
    ListQuery opt,
  ) {
    return AlbumsCategoryListProvider(
      opt,
    );
  }

  @override
  AlbumsCategoryListProvider getProviderOverride(
    covariant AlbumsCategoryListProvider provider,
  ) {
    return call(
      provider.opt,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'albumsCategoryListProvider';
}

/// See also [albumsCategoryList].
class AlbumsCategoryListProvider
    extends AutoDisposeStreamProvider<List<Album>> {
  /// See also [albumsCategoryList].
  AlbumsCategoryListProvider(
    ListQuery opt,
  ) : this._internal(
          (ref) => albumsCategoryList(
            ref as AlbumsCategoryListRef,
            opt,
          ),
          from: albumsCategoryListProvider,
          name: r'albumsCategoryListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$albumsCategoryListHash,
          dependencies: AlbumsCategoryListFamily._dependencies,
          allTransitiveDependencies:
              AlbumsCategoryListFamily._allTransitiveDependencies,
          opt: opt,
        );

  AlbumsCategoryListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.opt,
  }) : super.internal();

  final ListQuery opt;

  @override
  Override overrideWith(
    Stream<List<Album>> Function(AlbumsCategoryListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AlbumsCategoryListProvider._internal(
        (ref) => create(ref as AlbumsCategoryListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        opt: opt,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Album>> createElement() {
    return _AlbumsCategoryListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AlbumsCategoryListProvider && other.opt == opt;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, opt.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AlbumsCategoryListRef on AutoDisposeStreamProviderRef<List<Album>> {
  /// The parameter `opt` of this provider.
  ListQuery get opt;
}

class _AlbumsCategoryListProviderElement
    extends AutoDisposeStreamProviderElement<List<Album>>
    with AlbumsCategoryListRef {
  _AlbumsCategoryListProviderElement(super.provider);

  @override
  ListQuery get opt => (origin as AlbumsCategoryListProvider).opt;
}

String _$albumsForStationHash() => r'fc8de9c9cdae7338fa153f8d4cb8c1b2db9ba965';

/// See also [albumsForStation].
@ProviderFor(albumsForStation)
const albumsForStationProvider = AlbumsForStationFamily();

/// See also [albumsForStation].
class AlbumsForStationFamily extends Family<AsyncValue<List<Album>>> {
  /// See also [albumsForStation].
  const AlbumsForStationFamily();

  /// See also [albumsForStation].
  AlbumsForStationProvider call(
    int stationId,
  ) {
    return AlbumsForStationProvider(
      stationId,
    );
  }

  @override
  AlbumsForStationProvider getProviderOverride(
    covariant AlbumsForStationProvider provider,
  ) {
    return call(
      provider.stationId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'albumsForStationProvider';
}

/// See also [albumsForStation].
class AlbumsForStationProvider extends AutoDisposeFutureProvider<List<Album>> {
  /// See also [albumsForStation].
  AlbumsForStationProvider(
    int stationId,
  ) : this._internal(
          (ref) => albumsForStation(
            ref as AlbumsForStationRef,
            stationId,
          ),
          from: albumsForStationProvider,
          name: r'albumsForStationProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$albumsForStationHash,
          dependencies: AlbumsForStationFamily._dependencies,
          allTransitiveDependencies:
              AlbumsForStationFamily._allTransitiveDependencies,
          stationId: stationId,
        );

  AlbumsForStationProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.stationId,
  }) : super.internal();

  final int stationId;

  @override
  Override overrideWith(
    FutureOr<List<Album>> Function(AlbumsForStationRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AlbumsForStationProvider._internal(
        (ref) => create(ref as AlbumsForStationRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        stationId: stationId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Album>> createElement() {
    return _AlbumsForStationProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AlbumsForStationProvider && other.stationId == stationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, stationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AlbumsForStationRef on AutoDisposeFutureProviderRef<List<Album>> {
  /// The parameter `stationId` of this provider.
  int get stationId;
}

class _AlbumsForStationProviderElement
    extends AutoDisposeFutureProviderElement<List<Album>>
    with AlbumsForStationRef {
  _AlbumsForStationProviderElement(super.provider);

  @override
  int get stationId => (origin as AlbumsForStationProvider).stationId;
}

String _$savedStationsHash() => r'd841edf1318b3d5e25f55ceadd0eb19cee40001b';

/// See also [SavedStations].
@ProviderFor(SavedStations)
final savedStationsProvider = AutoDisposeAsyncNotifierProvider<SavedStations,
    List<DiscoverySession>>.internal(
  SavedStations.new,
  name: r'savedStationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$savedStationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SavedStations = AutoDisposeAsyncNotifier<List<DiscoverySession>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
