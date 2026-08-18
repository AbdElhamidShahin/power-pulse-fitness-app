import 'package:firebase_auth/firebase_auth.dart';
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

  static const _kDark          = 'settings_dark_mode';
  static const _kMetric        = 'settings_metric_units';
  static const _kNotifications = 'settings_notifications';

  void _load() {
    emit(AppSettings(
      isDarkMode:           _prefs.getBool(_kDark)          ?? false,
      isMetricUnits:        _prefs.getBool(_kMetric)        ?? true,
      notificationsEnabled: _prefs.getBool(_kNotifications) ?? true,
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
  //
  // This is the top-level master switch. When turned off it cancels ALL
  // scheduled notifications. When turned on it re-applies the granular
  // per-type preferences stored by NotificationSettingsSection so the user
  // doesn't need to re-enable each type manually.
  //
  // Granular keys (owned by NotificationSettingsSection):
  static const _kNotifWorkout = 'notif_workout';
  static const _kNotifSteps   = 'notif_steps';
  static const _kNotifWater   = 'notif_water';

  Future<void> toggleNotifications(bool val) async {
    await _prefs.setBool(_kNotifications, val);
    emit(state.copyWith(notificationsEnabled: val));

    final ns = NotificationService.instance;

    if (!val) {
      // Master OFF → cancel everything regardless of granular settings.
      await ns.cancelAll();
      return;
    }

    // Master ON → re-schedule each type that the user had enabled.
    // Defaults match NotificationSettingsSection initial values.
    final workoutEnabled = _prefs.getBool(_kNotifWorkout) ?? true;
    final stepsEnabled   = _prefs.getBool(_kNotifSteps)   ?? true;
    final waterEnabled   = _prefs.getBool(_kNotifWater)   ?? false;

    if (workoutEnabled) {
      await ns.scheduleWorkoutMorningReminder();
      await ns.scheduleWorkoutEveningReminder();
    }
    if (stepsEnabled) {
      await ns.scheduleStepsReminder();
    }
    if (waterEnabled) {
      await ns.scheduleWaterReminders();
    }
  }

  // ─── Logout — Flow 6 ──────────────────────────────────────
  //
  // 1. Signs out from Firebase Auth.
  // 2. Clears ALL local user-specific data so the next guest or
  //    authenticated user cannot see the previous user's data.
  // 3. Device-specific settings (dark mode, units, notifications) are kept.
  // 4. Cloud (Firestore) data is NOT touched — it remains for future restores.
  Future<void> logout() async {
    // Snapshot device settings before clearing so we can restore them.
    final dark          = state.isDarkMode;
    final metric        = state.isMetricUnits;
    final notifications = state.notificationsEnabled;

    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      // Firebase sign-out failure is non-fatal — continue clearing local data.
      // This can happen offline; the session token will expire naturally.
    }

    // Switch to guest mode. Firestore data is untouched and preserved
    // for the next login from this or another device.
    await UserModeService.setGuestAfterLogout(_prefs);

    // Clear ALL local user data (profile, workouts, progress, nutrition, etc.)
    // Device settings are excluded inside clearLocalUserData.
    await GuestMigrationService.clearLocalUserData(_prefs);

    // Restore device-specific settings (not user data).
    await _prefs.setBool(_kDark, dark);
    await _prefs.setBool(_kMetric, metric);
    await _prefs.setBool(_kNotifications, notifications);

    emit(AppSettings(
      isDarkMode:           dark,
      isMetricUnits:        metric,
      notificationsEnabled: notifications,
    ));
  }

  // ─── Helpers for UI ───────────────────────────────────────
  ThemeMode get themeMode =>
      state.isDarkMode ? ThemeMode.dark : ThemeMode.light;

  String weightUnit(double kg) =>
      state.isMetricUnits ? '${kg.toInt()} كجم' : '${(kg * 2.205).toInt()} رطل';

  String heightUnit(double cm) =>
      state.isMetricUnits ? '${cm.toInt()} سم' : '${(cm / 2.54).toStringAsFixed(1)} بوصة';
}
