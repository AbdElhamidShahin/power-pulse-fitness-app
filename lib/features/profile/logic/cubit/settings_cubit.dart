import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/auth/user_mode_service.dart';
import 'settings_state.dart';

class AppSettingsCubit extends Cubit<AppSettings> {
  AppSettingsCubit(this._prefs) : super(const AppSettings()) {
    _load();
  }

  final SharedPreferences _prefs;

  static const _kDark = 'settings_dark_mode';
  static const _kMetric = 'settings_metric_units';
  static const _kNotifications = 'settings_notifications';

  void _load() {
    emit(AppSettings(
      isDarkMode: _prefs.getBool(_kDark) ?? false,
      isMetricUnits: _prefs.getBool(_kMetric) ?? true,
      notificationsEnabled: _prefs.getBool(_kNotifications) ?? true,
    ));
  }

  Future<void> toggleDarkMode(bool val) async {
    await _prefs.setBool(_kDark, val);
    emit(state.copyWith(isDarkMode: val));
  }

  Future<void> toggleMetricUnits(bool val) async {
    await _prefs.setBool(_kMetric, val);
    emit(state.copyWith(isMetricUnits: val));
  }

  Future<void> toggleNotifications(bool val) async {
    await _prefs.setBool(_kNotifications, val);
    emit(state.copyWith(notificationsEnabled: val));
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}

    await UserModeService.clearMode(_prefs);
    await _prefs.remove('user_profile');

    emit(const AppSettings());
  }

  ThemeMode get themeMode =>
      state.isDarkMode ? ThemeMode.dark : ThemeMode.light;

  String weightUnit(double kg) =>
      state.isMetricUnits ? '${kg.toInt()} كجم' : '${(kg * 2.205).toInt()} رطل';

  String heightUnit(double cm) => state.isMetricUnits
      ? '${cm.toInt()} سم'
      : '${(cm / 2.54).toStringAsFixed(1)} بوصة';
}
