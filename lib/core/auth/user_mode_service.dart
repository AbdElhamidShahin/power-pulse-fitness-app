import 'package:shared_preferences/shared_preferences.dart';

enum UserMode { none, guest, authenticated }

abstract class UserModeService {
  static const _kMode = 'user_mode';
  static const _kModeGuest = 'guest';
  static const _kModeAuth = 'authenticated';

  static Future<UserMode> getMode(SharedPreferences prefs) async {
    final raw = prefs.getString(_kMode);
    if (raw == _kModeGuest) return UserMode.guest;
    if (raw == _kModeAuth) return UserMode.authenticated;
    return UserMode.none;
  }

  static Future<void> setGuest(SharedPreferences prefs) =>
      prefs.setString(_kMode, _kModeGuest);

  static Future<void> setAuthenticated(SharedPreferences prefs) =>
      prefs.setString(_kMode, _kModeAuth);

  static Future<void> setGuestAfterLogout(SharedPreferences prefs) =>
      prefs.setString(_kMode, _kModeGuest);

  static Future<void> clearMode(SharedPreferences prefs) =>
      prefs.remove(_kMode);
}
