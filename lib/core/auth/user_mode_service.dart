import 'package:shared_preferences/shared_preferences.dart';

/// Tracks whether the user has chosen Guest mode, signed in, or hasn't chosen yet.
enum UserMode { none, guest, authenticated }

abstract class UserModeService {
  static const _kMode = 'user_mode';
  static const _kModeGuest = 'guest';
  static const _kModeAuth = 'authenticated';

  // نسخة في الذاكرة من الـ mode — بتتحدّث مع كل قراءة/كتابة.
  // الـ Router بيقراها synchronously (من غير أي I/O) في كل navigation.
  static UserMode _cachedMode = UserMode.none;

  /// آخر mode معروف (in-memory). آمن للاستدعاء من الـ router redirect.
  static UserMode get cachedMode => _cachedMode;

  static Future<UserMode> getMode(SharedPreferences prefs) async {
    final raw = prefs.getString(_kMode);
    if (raw == _kModeGuest) {
      _cachedMode = UserMode.guest;
    } else if (raw == _kModeAuth) {
      _cachedMode = UserMode.authenticated;
    } else {
      _cachedMode = UserMode.none;
    }
    return _cachedMode;
  }

  static Future<void> setGuest(SharedPreferences prefs) async {
    await prefs.setString(_kMode, _kModeGuest);
    _cachedMode = UserMode.guest;
  }

  static Future<void> setAuthenticated(SharedPreferences prefs) async {
    await prefs.setString(_kMode, _kModeAuth);
    _cachedMode = UserMode.authenticated;
  }

  /// After logout we go back to guest — preserves guest experience.
  static Future<void> setGuestAfterLogout(SharedPreferences prefs) async {
    await prefs.setString(_kMode, _kModeGuest);
    _cachedMode = UserMode.guest;
  }

  /// Full reset — used only if we want the entry screen again.
  static Future<void> clearMode(SharedPreferences prefs) async {
    await prefs.remove(_kMode);
    _cachedMode = UserMode.none;
  }
}
