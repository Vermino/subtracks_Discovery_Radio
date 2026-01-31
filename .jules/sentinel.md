## 2026-01-30 - Hardcoded Infrastructure Credentials
**Vulnerability:** Found hardcoded credentials (password and API key) in `lib/config/infrastructure_config.dart`.
**Learning:** Unused or "development only" configuration files are a common source of secret leaks because they are often overlooked during code reviews. Even if code is unused, its presence in the repository exposes the secrets.
**Prevention:** Use environment variables for ALL credentials, including local development configurations. Scan "utility" or "config" folders specifically for hardcoded strings.

## 2026-02-01 - SQL Injection in Custom Query Builders
**Vulnerability:** Found SQL injection in `buildFilter` where user input was interpolated directly into `CustomExpression` SQL strings (e.g., `'$column = \'$value\''`).
**Learning:** Using `CustomExpression` in Drift allows raw SQL injection if variables are not explicitly bound using `?` placeholders or if Drift's expression builder extensions (like `.equals()`) are not used. The `FilterWith` model exposed this vulnerability via dynamic filter construction.
**Prevention:** Always use Drift's expression builder methods (e.g., `expr.equals(val)`) which automatically handle parameter binding. If `CustomExpression` is necessary, ensure all user input is passed via `Variable` objects and bound to placeholders.
