## 2026-01-28 - Localization Workaround
**Learning:** The project lacks `gen-l10n` tool in the environment. Adding new strings requires manual addition to `lib/l10n/app_localizations.dart` as concrete getters with default values to avoid breaking abstract class implementations in other languages.
**Action:** Add new keys to `.arb` for future, but implement default English getters in `AppLocalizations` abstract class.
