## 2026-01-26 - Hardcoded .env Bundling
**Vulnerability:** The `.env` file, which may contain sensitive development secrets, was explicitly included in `pubspec.yaml` assets. This causes it to be bundled in the production application, potentially exposing secrets if the builder has a populated `.env`.
**Learning:** Even if `.env` is gitignored, including it in `assets` bundles it. `flutter_dotenv` encourages this pattern, but it is insecure for production if secrets are involved.
**Prevention:** Do not include `.env` in `pubspec.yaml` assets. Use `--dart-define` for compile-time configuration or secure storage for runtime secrets.
