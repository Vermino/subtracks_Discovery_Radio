import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../http/client.dart';
import '../models/settings.dart';
import '../services/settings_service.dart';
import '../sources/music_source.dart';
import '../sources/subsonic/source.dart';

part 'settings.g.dart';

@Riverpod(keepAlive: true)
MusicSource? musicSource(MusicSourceRef ref) {
  final settings = ref.watch(settingsServiceProvider.select(
    (value) => value.activeSource,
  ));

  // Return null if no source is configured (first run or cleared data)
  if (settings == null) return null;

  final subsonicSettings = settings as SubsonicSettings;
  final streamFormat = ref.watch(settingsServiceProvider.select(
    (value) => value.app.streamFormat,
  ));
  final maxBitrate = ref.watch(maxBitrateProvider).requireValue;
  final http = ref.watch(httpClientProvider);

  return MusicSource(
    SubsonicSource(
      opt: subsonicSettings,
      http: http,
      maxBitrate: maxBitrate,
      streamFormat: streamFormat,
    ),
    ref,
  );
}

@Riverpod(keepAlive: true)
Stream<NetworkMode> networkMode(NetworkModeRef ref) async* {
  await for (var state in Connectivity().onConnectivityChanged) {
    switch (state) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
        yield NetworkMode.wifi;
        break;
      default:
        yield NetworkMode.mobile;
        break;
    }
  }
}

@Riverpod(keepAlive: true)
Future<int> maxBitrate(MaxBitrateRef ref) async {
  final settings = ref.watch(settingsServiceProvider.select(
    (value) => value.app,
  ));
  final networkMode = ref.watch(networkModeProvider).requireValue;

  return networkMode == NetworkMode.wifi
      ? settings.maxBitrateWifi
      : settings.maxBitrateMobile;
}

@Riverpod(keepAlive: true)
int sourceId(SourceIdRef ref) {
  final source = ref.watch(musicSourceProvider);
  if (source == null) {
    throw StateError('No music source configured - cannot get source ID');
  }
  return source.id;
}

@Riverpod(keepAlive: true)
class OfflineMode extends _$OfflineMode {
  @override
  bool build() {
    return false;
  }

  Future<void> setMode(bool value) async {
    final hasSource = ref.read(settingsServiceProvider.select(
      (value) => value.activeSource != null,
    ));
    if (!hasSource) return;

    if (value == false && state == true) {
      try {
        final source = ref.read(musicSourceProvider);
        if (source != null) {
          await source.ping();
        }
      } catch (err) {
        return;
      }
    }
    state = value;
  }
}
