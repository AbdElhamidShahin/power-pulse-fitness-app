# Power Pulse

Flutter fitness app with Supabase authentication/data, workout tracking, local notifications, and a pedometer feature.

## Local development

1. Install the Flutter SDK version used by CI (`3.32.5` currently).
2. Copy `dart_defines.example.json` to `dart_defines.json` and set the real project values locally. The local file is git-ignored.
3. Run:

```bash
flutter pub get
flutter analyze
flutter test
flutter run --dart-define-from-file=dart_defines.json
```

## Android release build

Configure `android/key.properties` and the matching upload keystore locally. Never commit the keystore, its passwords, or `dart_defines.json`.

```bash
flutter build appbundle --release --dart-define-from-file=dart_defines.json
```

The Google Play upload bundle is generated at `build/app/outputs/bundle/release/app-release.aab`.

### Before publishing an update

- Confirm `applicationId` in `android/app/build.gradle` exactly matches the existing Play Console app. Do not change it for a redesign.
- Confirm the upload certificate is accepted by Play App Signing.
- Confirm `versionCode` is higher than the latest version in Play Console. The value is sourced from `pubspec.yaml` (`version: x.y.z+N`).
- Test the signed release on an internal-testing track, including upgrade-over-existing-install, login, notifications, and step tracking.
- Review Play Console policy declarations and the pre-launch report before production rollout.

## CI/CD

Pull requests run dependency resolution, static analysis, and tests without requiring release secrets. Pushes to `main` run the signed release build and upload the AAB and APK as workflow artifacts; the APK is also sent to Firebase App Distribution.

Configure these GitHub Actions secrets for release builds:

- `KEYSTORE_BASE64`
- `KEY_STORE_PASSWORD`
- `KEY_PASSWORD`
- `KEY_ALIAS`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `FIREBASE_APP_ID`
- `FIREBASE_TOKEN`

## Supabase OAuth redirects

The Android redirect scheme is `com.powerteam.powerpulse`. Ensure the following are identical in the app, Android manifest, and Supabase Auth URL Configuration:

- `com.powerteam.powerpulse://login-callback`
- `com.powerteam.powerpulse://reset-password`

Configure Google OAuth credentials and production email delivery in Supabase before release. Never include service-role keys or SMTP credentials in a client app.
