# Sentinel Journal

This journal records critical security learnings and vulnerability fixes.

## 2024-05-22 - [Bundled .env Vulnerability]
**Vulnerability:** The `.env` file was listed in `pubspec.yaml` assets, causing it to be bundled in the release application if present during build.
**Learning:** `flutter_dotenv` encourages adding `.env` to assets, but this exposes secrets if the file is not empty.
**Prevention:** Removed `.env` from assets. Updated `dotenv.load()` to be optional, preventing crashes in production where the file is naturally missing.
