import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/auth/guest_migration_service.dart';
import '../../../../core/auth/user_mode_service.dart';
import '../../../../core/notifications/notification_service.dart';
import 'settings_state.dart';

class AppSettingsCubit extends Cubit<AppSettings> {
  AppSettingsCubit(this._prefs) : super(const AppSettings()) {
    _load();
  }

  final SharedPreferences _prefs;

  static const _kDark = 'settings_dark_mode';
  static const _kMetric = 'settings_metric_units';
  static const _kNotifications = 'settings_notifications';
  static const _kLocale = 'settings_locale';

  void _load() {
    emit(AppSettings(
      isDarkMode: _prefs.getBool(_kDark) ?? false,
      isMetricUnits: _prefs.getBool(_kMetric) ?? true,
      notificationsEnabled: _prefs.getBool(_kNotifications) ?? true,
      locale: _prefs.getString(_kLocale) ?? 'ar',
    ));
  }

  // ─── Dark Mode ────────────────────────────────────────────
  Future<void> toggleDarkMode(bool val) async {
    await _prefs.setBool(_kDark, val);
    emit(state.copyWith(isDarkMode: val));
  }

  // ─── Metric Units ──────────────────────────────────────────
  Future<void> toggleMetricUnits(bool val) async {
    await _prefs.setBool(_kMetric, val);
    emit(state.copyWith(isMetricUnits: val));
  }

  // ─── Notifications ─────────────────────────────────────────
  Future<void> toggleNotifications(bool val) async {
    await _prefs.setBool(_kNotifications, val);
    emit(state.copyWith(notificationsEnabled: val));
    // BUGFIX: السويتش ده كان بيتحفظ بس ومش بيعمل أي حاجة فعلياً
    if (val) await NotificationService.instance.requestPermissions();
    await NotificationService.instance.syncFromPrefs(_prefs);
  }

  // ─── Language ──────────────────────────────────────────────
  Future<void> setLocale(String locale) async {
    await _prefs.setString(_kLocale, locale);
    emit(state.copyWith(locale: locale));
  }

  // ─── Logout ────────────────────────────────────────────────
  Future<void> logout() async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser?.id;

    // Sync before sign-out; if sync fails, preserve local data and let the UI
    // report the error. A successful logout must return to account selection,
    // not silently enter a guest session using a partially cleared profile.
    if (uid != null) {
      await GuestMigrationService.pushLocalToCloud(
        prefs: _prefs,
        supabase: client,
        uid: uid,
      );
      await client.auth.signOut();
      await GuestMigrationService.clearLocalUserData(_prefs);
    }
    await UserModeService.clearMode(_prefs);

    emit(AppSettings(
      isDarkMode: state.isDarkMode,
      isMetricUnits: state.isMetricUnits,
      notificationsEnabled: state.notificationsEnabled,
      locale: state.locale,
    ));
  }

  ThemeMode get themeMode =>
      state.isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Locale get currentLocale => Locale(state.locale);

  String weightUnit(double kg) =>
      state.isMetricUnits ? '${kg.toInt()} كجم' : '${(kg * 2.205).toInt()} رطل';

  String heightUnit(double cm) => state.isMetricUnits
      ? '${cm.toInt()} سم'
      : '${(cm / 2.54).toStringAsFixed(1)} بوصة';
}
