## 2026-01-30 - Hardcoded Infrastructure Credentials
**Vulnerability:** Found hardcoded credentials (password and API key) in `lib/config/infrastructure_config.dart`.
**Learning:** Unused or "development only" configuration files are a common source of secret leaks because they are often overlooked during code reviews. Even if code is unused, its presence in the repository exposes the secrets.
**Prevention:** Use environment variables for ALL credentials, including local development configurations. Scan "utility" or "config" folders specifically for hardcoded strings.

## 2026-02-05 - Insecure Random Number Generation
**Vulnerability:** Used `Random()` for generating authentication salts in `SubsonicClient`. `Random()` is not cryptographically secure and can be predictable.
**Learning:** Using `Random()` for anything related to security (auth tokens, salts, keys) weakens the security mechanism. Developers often default to `Random()` without considering the security implications.
**Prevention:** Always use `Random.secure()` for security-critical random values. Lint rules or code review checklists should flag `Random()` usage in auth/crypto related code.
