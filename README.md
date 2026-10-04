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

## Production Auth setup

Power Pulse uses Supabase Auth for email/password and Google sign-in. The Flutter app intentionally does **not** contain SMTP credentials.

Before releasing/updating the Google Play build:

1. Configure a **Custom SMTP** provider in Supabase Dashboard → Authentication → Emails → SMTP Settings.
2. Configure Google in Supabase Dashboard → Authentication → Providers → Google and add the Android/Google OAuth credentials required by your project.
3. Add this redirect URL to Supabase Authentication → URL Configuration:
   `com.powerteam.powerpulse://login-callback`
4. Add this password-recovery redirect URL:
   `com.powerteam.powerpulse://reset-password`
5. Ensure the Android manifest registers the same `com.powerteam.powerpulse://login-callback` scheme/host.

The default Supabase email provider is not suitable for production; custom SMTP is required for normal production email delivery and higher configurable email limits.
