## 2024-05-22 - Missing Test Dependencies
**Learning:** `flutter_test` and `mockito` were missing from `dev_dependencies`, causing local tests to fail compilation. They must be added temporarily to verify changes if not present.
**Action:** Check `pubspec.yaml` `dev_dependencies` before running tests. If missing, add them, verify, then revert to avoid unauthorized dependency changes.
