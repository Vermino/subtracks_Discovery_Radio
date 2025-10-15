// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_download_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$autoDownloadServiceHash() =>
    r'50409c817fcd7b6a7e6031b46b5f1b25848d9e35';

/// Service for managing automatic song downloads with network awareness
///
/// This service handles:
/// - Checking if downloads are allowed based on user preferences and network
/// - Automatically downloading station songs when conditions are met
/// - Queuing downloads for later when network isn't suitable (e.g., WiFi-only but on mobile)
/// - Monitoring network changes and triggering queued downloads
///
/// Copied from [AutoDownloadService].
@ProviderFor(AutoDownloadService)
final autoDownloadServiceProvider =
    NotifierProvider<AutoDownloadService, void>.internal(
  AutoDownloadService.new,
  name: r'autoDownloadServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$autoDownloadServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AutoDownloadService = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
