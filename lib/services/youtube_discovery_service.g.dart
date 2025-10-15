// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'youtube_discovery_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$youTubeDiscoveryServiceHash() =>
    r'd5e2ee6bbd330357e0b2b7b543e4c437fc06a4e4';

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
