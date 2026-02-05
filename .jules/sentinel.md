## 2026-01-30 - Hardcoded Infrastructure Credentials
**Vulnerability:** Found hardcoded credentials (password and API key) in `lib/config/infrastructure_config.dart`.
**Learning:** Unused or "development only" configuration files are a common source of secret leaks because they are often overlooked during code reviews. Even if code is unused, its presence in the repository exposes the secrets.
**Prevention:** Use environment variables for ALL credentials, including local development configurations. Scan "utility" or "config" folders specifically for hardcoded strings.

## 2026-02-04 - SQL Injection in CustomExpression
**Vulnerability:** Found SQL injection in `buildFilter` function which used string interpolation inside Drift's `CustomExpression`.
**Learning:** `CustomExpression` in Drift allows raw SQL. String interpolation within it bypasses the parameterized query protection that Drift usually provides. Developers must use `Variable` or expression builder extensions (like `.equals()`, `.isBiggerThan()`) which automatically bind variables.
**Prevention:** Avoid `CustomExpression` string interpolation for user input. Use parameterized queries or builder methods. Use strict lint rules if available.
