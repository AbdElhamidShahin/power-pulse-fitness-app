# task

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Running Power Pulse

Supabase credentials are **not** stored in source. They are injected at build time.

```bash
cp dart_defines.example.json dart_defines.json   # then fill in real values (git-ignored)
flutter run --dart-define-from-file=dart_defines.json
flutter build apk --dart-define-from-file=dart_defines.json
```

CI needs the GitHub secrets `SUPABASE_URL` and `SUPABASE_ANON_KEY`.

### Google Sign-In (OAuth) redirect

Redirect URL: `com.powerteam.powerpulse://login-callback`

It must be identical in all of these places:
- `AppConstants.oauthRedirectUrl`
- `android/app/src/main/AndroidManifest.xml` (intent-filter)
- `ios/Runner/Info.plist` (`CFBundleURLSchemes`)
- Supabase Dashboard → Authentication → URL Configuration → Redirect URLs
