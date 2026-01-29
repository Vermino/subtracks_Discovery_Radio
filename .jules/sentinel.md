## 2024-12-06 - Strengthened Subsonic Authentication Salt
**Vulnerability:** The Subsonic client implementation used a weak random number generator (`Random()`) and a short (4-character) salt for MD5 token generation. This made the authentication token more predictable and susceptible to brute-force attacks if the salt was guessed.
**Learning:** `dart:math`'s `Random()` is not cryptographically secure. Authentication tokens and other security-sensitive values must always use `Random.secure()`.
**Prevention:** Always use `Random.secure()` for generating salts, nonces, or any cryptographic material. Enforce a minimum length for salts (e.g., 16+ characters) to ensure sufficient entropy.
