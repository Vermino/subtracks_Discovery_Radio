## 2026-01-30 - Hardcoded Infrastructure Credentials
**Vulnerability:** Found hardcoded credentials (password and API key) in `lib/config/infrastructure_config.dart`.
**Learning:** Unused or "development only" configuration files are a common source of secret leaks because they are often overlooked during code reviews. Even if code is unused, its presence in the repository exposes the secrets.
**Prevention:** Use environment variables for ALL credentials, including local development configurations. Scan "utility" or "config" folders specifically for hardcoded strings.

## 2026-01-30 - SQL Injection in Dynamic Filter Builder
**Vulnerability:** The `buildFilter` function in `lib/database/database.dart` constructed SQL queries using string interpolation (`'$column = \'$value\''`). This allowed SQL injection via the `value` parameter in filter objects.
**Learning:** Using `CustomExpression` in Drift/SQL libraries is dangerous when combined with string interpolation. It bypasses the built-in protection mechanisms (parameter binding). Even when using an ORM/query builder, "raw" expression features must be scrutinized.
**Prevention:** Always use the library's fluent API (e.g., `CustomExpression(col).equals(val)`) which automatically handles variable binding. If raw SQL is absolutely necessary, use placeholders (`?`) and pass values as a separate arguments list (Variable bindings).
