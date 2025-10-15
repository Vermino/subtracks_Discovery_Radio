// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$musicSourceHash() => r'f63b8905f2563a2f12d4aa84870445342cac3c69';

/// See also [musicSource].
@ProviderFor(musicSource)
final musicSourceProvider = Provider<MusicSource?>.internal(
  musicSource,
  name: r'musicSourceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$musicSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MusicSourceRef = ProviderRef<MusicSource?>;
String _$networkModeHash() => r'813a60a454c6acaefbe3b56bf0152497ab18dcce';

/// See also [networkMode].
@ProviderFor(networkMode)
final networkModeProvider = StreamProvider<NetworkMode>.internal(
  networkMode,
  name: r'networkModeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$networkModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NetworkModeRef = StreamProviderRef<NetworkMode>;
String _$maxBitrateHash() => r'ec02d3ccbc9f3429acfc1b3f191cab791b1191e0';

/// See also [maxBitrate].
@ProviderFor(maxBitrate)
final maxBitrateProvider = FutureProvider<int>.internal(
  maxBitrate,
  name: r'maxBitrateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$maxBitrateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MaxBitrateRef = FutureProviderRef<int>;
String _$sourceIdHash() => r'e1b580799f4222410c2592c41951476aefd7cc54';

/// See also [sourceId].
@ProviderFor(sourceId)
final sourceIdProvider = Provider<int>.internal(
  sourceId,
  name: r'sourceIdProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$sourceIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SourceIdRef = ProviderRef<int>;
String _$offlineModeHash() => r'0668b6152e5aa896a4eb9013647d93ca4761c4b1';

/// See also [OfflineMode].
@ProviderFor(OfflineMode)
final offlineModeProvider = NotifierProvider<OfflineMode, bool>.internal(
  OfflineMode.new,
  name: r'offlineModeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$offlineModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OfflineMode = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
