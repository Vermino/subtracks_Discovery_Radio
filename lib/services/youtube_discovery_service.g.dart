// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'youtube_discovery_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$youTubeDiscoveryServiceHash() =>
    r'59960b6fba2caf8c2aeea00aa32b677326810a8a';

/// Service for discovering music on YouTube using self-hosted Invidious API
///
/// This service provides:
/// - Music search functionality
/// - Audio stream URL extraction
/// - Rate limiting and retry logic
/// - Comprehensive error handling
///
/// Copied from [YouTubeDiscoveryService].
@ProviderFor(YouTubeDiscoveryService)
final youTubeDiscoveryServiceProvider =
    NotifierProvider<YouTubeDiscoveryService, void>.internal(
  YouTubeDiscoveryService.new,
  name: r'youTubeDiscoveryServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$youTubeDiscoveryServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$YouTubeDiscoveryService = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
