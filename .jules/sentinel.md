## 2026-01-27 - Bundled .env Files
**Vulnerability:** The `.env` file was explicitly listed in `pubspec.yaml` assets, causing it to be bundled with the release application. This allows anyone with the APK/IPA to extract secrets.
**Learning:** `flutter_dotenv` requires the env file to be an asset to load it at runtime, which inherently conflicts with keeping secrets out of the build artifact unless complex build-time exclusion is used.
**Prevention:** Do not use `flutter_dotenv` for secrets. Use `--dart-define` for compile-time variables or secure storage for runtime secrets. Never list `.env` in `pubspec.yaml` assets.
