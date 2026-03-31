## 2025-01-22 - Flutter/Dart Version Mismatch
**Learning:** The project's `.fvmrc` specifies Flutter 3.24.5 (Dart 3.5.4), but `pubspec.lock` specifies `dart: ">=3.8.0-0 <4.0.0"`. This causes massive lockfile churn when running `flutter pub get` with the version specified in `.fvmrc`.
**Action:** Be cautious when running `flutter pub get`. If unrelated to the task, revert `pubspec.lock` changes to avoid polluting the PR.
