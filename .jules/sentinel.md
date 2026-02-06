## 2026-01-30 - Hardcoded Infrastructure Credentials
**Vulnerability:** Found hardcoded credentials (password and API key) in `lib/config/infrastructure_config.dart`.
**Learning:** Unused or "development only" configuration files are a common source of secret leaks because they are often overlooked during code reviews. Even if code is unused, its presence in the repository exposes the secrets.
**Prevention:** Use environment variables for ALL credentials, including local development configurations. Scan "utility" or "config" folders specifically for hardcoded strings.

## 2026-02-04 - SQL Injection in Custom Expressions
**Vulnerability:** Found `CustomExpression` using direct string interpolation for values in `buildFilter` (e.g. `'$column = \'$value\''`). This allowed SQL injection.
**Learning:** `CustomExpression` in Drift allows raw SQL. It does NOT automatically sanitize or bind variables if they are just strings inside the constructor. Developers often assume "Expression" implies safety, but `CustomExpression` is an escape hatch.
**Prevention:** Always use Drift's expression extensions (like `.equals()`, `.isBiggerThan()`) or explicitly wrap values in `Variable(value)` when building custom expressions. Never interpolate strings into SQL fragments.
