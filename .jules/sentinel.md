## 2023-10-27 - Bundled .env Files in Flutter
**Vulnerability:** The `.env` file was included in `pubspec.yaml` assets, causing it to be bundled in the release APK/IPA, exposing any secrets it contained to anyone who decompiles the app.
**Learning:** Flutter assets are included verbatim in the build. Using `flutter_dotenv` with bundled assets is a common pattern for development convenience but poses a severe risk if not stripped before release. Comments like `TODO: remove before release` are easily missed.
**Prevention:** Do not bundle `.env` files in production apps. Use `--dart-define` for build-time configuration or secure native storage for runtime secrets. Enforce this via CI/CD checks that fail if `.env` is in `pubspec.yaml`.
