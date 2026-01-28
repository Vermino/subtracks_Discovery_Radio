## 2024-05-23 - Test Environment & Drift Conflicts
**Learning:** The project was missing `flutter_test` and `mockito` in `dev_dependencies`, which prevented tests from compiling. Additionally, `drift` and `flutter_test` (via `matcher`) have naming conflicts for `isNotNull` and `isNull`, requiring `hide` clauses in test imports.
**Action:** When running tests in a new Flutter project, verify `dev_dependencies` first. If using Drift, always expect potential conflicts with Matchers and preemptively use `hide`.
