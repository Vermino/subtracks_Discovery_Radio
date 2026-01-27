import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/database.dart';
import '../http/client.dart';
import '../models/settings.dart';
import '../sources/subsonic/client.dart';
import '../state/init.dart';
import 'download_service.dart';

part 'settings_service.g.dart';

@Riverpod(keepAlive: true)
class SettingsService extends _$SettingsService {
  SubtracksDatabase get _db => ref.read(databaseProvider);

  @override
  Settings build() {
    return const Settings();
  }

  Future<void> init() async {
    final sources = await _db.allSubsonicSources().get();
    final settings = await _db.getAppSettings().getSingleOrNull();

    state = Settings(
      sources: sources
          .sorted((a, b) => a.createdAt.compareTo(b.createdAt))
          .toIList(),
      activeSource: sources.singleWhereOrNull((e) => e.isActive == true),
      app: settings ?? const AppSettings(),
    );
  }

  Future<void> createSource(
    SourcesCompanion source,
    SubsonicSourcesCompanion subsonic,
  ) async {
    final client = SubsonicClient(
      SubsonicSettings(
        id: 1,
        name: source.name.value,
        address: source.address.value,
        features: IList(),
        username: subsonic.username.value,
        password: subsonic.password.value,
        useTokenAuth: subsonic.useTokenAuth.present
            ? subsonic.useTokenAuth.value
            : true,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      ref.read(httpClientProvider),
    );

    await client.test();

    final features = IList([
      if (await client.testFeature(SubsonicFeature.emptyQuerySearch))
        SubsonicFeature.emptyQuerySearch,
    ]);

    await _db.createSource(
      source,
      subsonic.copyWith(features: Value(features)),
    );
    await init();
  }

  Future<void> updateSource(SubsonicSettings source) async {
    final client = SubsonicClient(source, ref.read(httpClientProvider));

    await client.test();

    await _db.updateSource(source);
    await init();
  }

  Future<void> deleteSource(int sourceId) async {
    await ref.read(downloadServiceProvider.notifier).deleteAll(sourceId);
    await _db.deleteSource(sourceId);
    await init();
  }

  Future<void> setActiveSource(int id) async {
    await _db.setActiveSource(id);
    await init();
  }

  Future<void> addTestSource(String prefix) async {
    // defaults for 'TEST'
    const name = 'Subsonic Demo';
    const address = 'http://demo.subsonic.org';
    const username = 'guest';
    const password = 'guest';

    await createSource(
      SourcesCompanion.insert(
        name: name,
        address: Uri.parse(address),
      ),
      SubsonicSourcesCompanion.insert(
        features: IList(),
        username: username,
        password: password,
        useTokenAuth: const Value(true),
      ),
    );

    await init();
  }

  Future<void> setMaxBitrateWifi(int bitrate) async {
    await _db.updateSettings(
      state.app.copyWith(maxBitrateWifi: bitrate).toCompanion(),
    );
    await init();
  }

  Future<void> setMaxBitrateMobile(int bitrate) async {
    await _db.updateSettings(
      state.app.copyWith(maxBitrateMobile: bitrate).toCompanion(),
    );
    await init();
  }

  Future<void> setStreamFormat(String? streamFormat) async {
    await _db.updateSettings(
      state.app.copyWith(streamFormat: streamFormat).toCompanion(),
    );
    await init();
  }

  Future<void> setYouTubeDiscoveryEnabled(bool enabled) async {
    await _db.updateSettings(
      state.app.copyWith(youtubeDiscoveryEnabled: enabled).toCompanion(),
    );
    await init();
  }

  Future<void> setYouTubeRatio(double ratio) async {
    await _db.updateSettings(
      state.app.copyWith(youtubeDiscoveryRatio: ratio).toCompanion(),
    );
    await init();
  }

  Future<void> setYouTubeQualityFilter(String filter) async {
    await _db.updateSettings(
      state.app.copyWith(youtubeQualityFilter: filter).toCompanion(),
    );
    await init();
  }

  Future<void> setYouTubePreferOfficial(bool prefer) async {
    await _db.updateSettings(
      state.app.copyWith(youtubePreferOfficial: prefer).toCompanion(),
    );
    await init();
  }

  Future<void> setThemePreset(String preset) async {
    await _db.updateSettings(
      state.app.copyWith(themePreset: preset).toCompanion(),
    );
    await init();
  }

  Future<void> setEnableDynamicColors(bool enabled) async {
    await _db.updateSettings(
      state.app.copyWith(enableDynamicColors: enabled).toCompanion(),
    );
    await init();
  }

  Future<void> setCustomSeedColor(int? color) async {
    await _db.updateSettings(
      state.app.copyWith(
        themePreset: 'custom',
        customSeedColor: color,
      ).toCompanion(),
    );
    await init();
  }

  Future<void> setDownloadPreference(String value) async {
    await _db.updateSettings(
      state.app.copyWith(downloadPreference: value).toCompanion(),
    );
    await init();
  }

  Future<void> setThumbsUpAutoDownload(bool value) async {
    await _db.updateSettings(
      state.app.copyWith(thumbsUpAutoDownload: value).toCompanion(),
    );
    await init();
  }

  Future<void> setThumbsDownAutoDelete(bool value) async {
    await _db.updateSettings(
      state.app.copyWith(thumbsDownAutoDelete: value).toCompanion(),
    );
    await init();
  }
}
