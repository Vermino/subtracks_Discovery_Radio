## 2026-01-24 - Missing flutter_test dependency
**Learning:** The project was missing `flutter_test` in `dev_dependencies` despite having test files. This prevented tests from running.
**Action:** Always check `pubspec.yaml` for `flutter_test` when working with Flutter tests, and add it if missing. Also, `drift` and `matcher` conflict on `isNotNull`/`isNull`, requiring explicit hiding.
