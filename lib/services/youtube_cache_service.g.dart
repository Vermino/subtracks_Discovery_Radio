// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'youtube_cache_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$youTubeCacheServiceHash() =>
    r'3ff3a0be802cf6ce7bdb99b0a8154b8b080cf1ce';

/// Two-tier caching service for YouTube tracks
///
/// Provides:
/// - In-memory LRU cache for hot data (max 100 entries)
/// - Database persistence for all cached tracks
/// - Automatic URL expiry detection and refresh
/// - Background cleanup of expired/old tracks
/// - Proactive refresh of tracks expiring soon
///
/// Cache strategy:
/// 1. Check memory cache (fast)
/// 2. Check database cache (medium)
/// 3. Fetch from API and cache (slow)
///
/// Copied from [YouTubeCacheService].
@ProviderFor(YouTubeCacheService)
final youTubeCacheServiceProvider =
    NotifierProvider<YouTubeCacheService, void>.internal(
  YouTubeCacheService.new,
  name: r'youTubeCacheServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$youTubeCacheServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$YouTubeCacheService = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
