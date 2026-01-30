## 2026-01-30 - Hardcoded Infrastructure Credentials
**Vulnerability:** Found hardcoded credentials (password and API key) in `lib/config/infrastructure_config.dart`.
**Learning:** Unused or "development only" configuration files are a common source of secret leaks because they are often overlooked during code reviews. Even if code is unused, its presence in the repository exposes the secrets.
**Prevention:** Use environment variables for ALL credentials, including local development configurations. Scan "utility" or "config" folders specifically for hardcoded strings.

## 2026-01-30 - Bundled .env Files in Flutter
**Vulnerability:** The `.env` file was included in `pubspec.yaml` assets, causing it to be bundled in the release APK/IPA, exposing any secrets it contained to anyone who decompiles the app.
**Learning:** Flutter assets are included verbatim in the build. Using `flutter_dotenv` with bundled assets is a common pattern for development convenience but poses a severe risk if not stripped before release. Comments like `TODO: remove before release` are easily missed.
**Prevention:** Do not bundle `.env` files in production apps. Use `--dart-define` for build-time configuration or secure native storage for runtime secrets. Enforce this via CI/CD checks that fail if `.env` is in `pubspec.yaml`.
