## 2026-01-30 - Hardcoded Infrastructure Credentials
**Vulnerability:** Found hardcoded credentials (password and API key) in `lib/config/infrastructure_config.dart`.
**Learning:** Unused or "development only" configuration files are a common source of secret leaks because they are often overlooked during code reviews. Even if code is unused, its presence in the repository exposes the secrets.
**Prevention:** Use environment variables for ALL credentials, including local development configurations. Scan "utility" or "config" folders specifically for hardcoded strings.

## 2026-02-14 - Weak Random Number Generation in Subsonic Authentication
**Vulnerability:** The `SubsonicClient` used `Random()` (insecure) to generate the salt for authentication tokens. This makes the salt predictable, weakening the MD5-based authentication scheme.
**Learning:** `Random()` in Dart is not cryptographically secure. Always use `Random.secure()` for generating secrets, salts, tokens, or keys.
**Prevention:** Audit all uses of `Random()` and replace with `Random.secure()` where security is involved. Use lint rules or static analysis to flag `Random()` usage in security-critical contexts.
