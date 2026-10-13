# Power Pulse — pre-release changes and remaining checks

## Changes made in this pass

- Bumped the app version in `pubspec.yaml` to `1.0.0+23` and changed Gradle to source `versionCode` from Flutter's version metadata, avoiding a hard-coded mismatch.
- Split CI validation from release deployment. Pull requests run dependency resolution, analysis, and tests without accessing release secrets.
- On pushes to `main`, CI now builds both a signed Google Play App Bundle (`.aab`) and a tester APK, and uploads them as workflow artifacts. Firebase distribution is skipped if its two secrets are not configured.
- Removed the app's explicit exact-alarm permission and stopped requesting exact-alarm access. These reminders can use inexact scheduling when exact alarms are unavailable, avoiding a restricted permission that routine reminders generally do not need.
- Improved notification permission error handling so a failed permission prompt does not prevent the app from attempting to schedule configured reminders.
- Replaced the starter README with release/build instructions and a pre-publish checklist.

## Must be confirmed in Play Console before upload

1. Confirm the old published app's package name is exactly `com.powerteam.powerpulse`. The old Play Store URL/package name was not supplied during this pass, so this comparison cannot be verified from the project archive alone.
2. Confirm the latest published `versionCode`. This project is set to 23; increase `pubspec.yaml`'s build number (`+N`) if Play Console already has 23 or higher.
3. Confirm the configured upload keystore matches the upload certificate accepted by Play App Signing. Keystore/password files are intentionally not included in source control.
4. Confirm GitHub Actions secrets exist for signing and Supabase. Firebase distribution secrets are optional in this workflow.
5. Confirm Supabase production URLs, OAuth redirect URLs, RLS policies, Play Console Data safety declarations, privacy policy, and store listing.

## Validation limitation

Flutter/Dart are not installed in the environment used for this edit, so `flutter pub get`, `dart format`, `flutter analyze`, `flutter test`, and `flutter build appbundle --release` were not run. The changes are source edits only and must be validated locally or in GitHub Actions before release.

## Required local checks

```powershell
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build appbundle --release --dart-define-from-file=dart_defines.json
```

Install and test the signed release on the Internal testing track before rolling it out to production.
