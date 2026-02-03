## 2026-01-30 - Hardcoded Infrastructure Credentials
**Vulnerability:** Found hardcoded credentials (password and API key) in `lib/config/infrastructure_config.dart`.
**Learning:** Unused or "development only" configuration files are a common source of secret leaks because they are often overlooked during code reviews. Even if code is unused, its presence in the repository exposes the secrets.
**Prevention:** Use environment variables for ALL credentials, including local development configurations. Scan "utility" or "config" folders specifically for hardcoded strings.

## 2026-02-04 - Weak Random Number Generation in Auth
**Vulnerability:** `SubsonicClient` used `Random()` (insecure PRNG) for generating authentication salts.
**Learning:** Default `Random()` is often predictable and unsuitable for security contexts like authentication tokens or salts. Developers often default to it for convenience.
**Prevention:** Always use `Random.secure()` for any value involved in security/authentication.
