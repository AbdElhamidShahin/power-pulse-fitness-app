import 'dart:io' show Platform;

import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// PedometerService — يتعامل مع عداد الخطوات الـ native.
///
/// الـ sensor (TYPE_STEP_COUNTER) بيدّي **إجمالي** الخطوات من آخر ريستارت
/// للموبايل، فبنحسب خطوات النهارده بإننا نطرح "نقطة بداية اليوم".
///
/// BUGFIXES:
///  • الصلاحية (ACTIVITY_RECOGNITION) كانت مش بتتطلب أصلاً في runtime،
///    فالعداد كان بيفضل "غير متاح" على أندرويد 10+.
///  • يوم جديد: نقطة البداية = آخر إجمالي اتسجّل امبارح (مش أول event النهاردة).
///  • ريستارت الموبايل: الـ sensor بيرجع يعدّ من صفر → بنعوّض عشان الخطوات
///    متتصفّرش.
///  • كل يوم بيتحفظ في `steps_YYYY-MM-DD` عشان صفحة التقدم تعرض السجل.
class PedometerService {
  PedometerService(this._prefs);
  final SharedPreferences _prefs;

  static const _keyBaseSteps = 'pedometer_base_steps';
  static const _keyBaseDate = 'pedometer_base_date';
  static const _keyDailySteps = 'pedometer_daily_steps';
  static const _keyLastTotal = 'pedometer_last_total';
  static const _keyGoalNotified = 'pedometer_goal_notified_date';

  // ─── Permission ──────────────────────────────────────────────

  Permission get _permission =>
      Platform.isIOS ? Permission.sensors : Permission.activityRecognition;

  Future<PermissionStatus> permissionStatus() => _permission.status;

  /// بيطلب الصلاحية لو لسه ما اتمنحتش.
  Future<PermissionStatus> ensurePermission() async {
    final current = await _permission.status;
    if (current.isGranted || current.isPermanentlyDenied) return current;
    return _permission.request();
  }

  Future<bool> openSettings() => openAppSettings();

  // ─── Stream ──────────────────────────────────────────────────

  /// stream خطوات اليوم فقط
  Stream<int> get dailyStepsStream =>
      Pedometer.stepCountStream.asyncMap(_process);

  Future<int> _process(StepCount event) async {
    final total = event.steps;
    final today = dayKey(DateTime.now());
    final savedDate = _prefs.getString(_keyBaseDate);
    final lastTotal = _prefs.getInt(_keyLastTotal);
    var base = _prefs.getInt(_keyBaseSteps) ?? total;

    if (savedDate != today) {
      // يوم جديد
      base = (savedDate != null && lastTotal != null && total >= lastTotal)
          ? lastTotal
          : total;
      await _prefs.setInt(_keyBaseSteps, base);
      await _prefs.setString(_keyBaseDate, today);
    } else if (lastTotal != null && total < lastTotal) {
      // الموبايل اتعمله ريستارت والـ sensor رجع من صفر
      final alreadyToday = _prefs.getInt(_keyDailySteps) ?? 0;
      base = total - alreadyToday;
      await _prefs.setInt(_keyBaseSteps, base);
    }

    final daily = (total - base).clamp(0, 999999);
    await _prefs.setInt(_keyDailySteps, daily);
    await _prefs.setInt(_keyLastTotal, total);
    await _prefs.setInt(_historyKey(today), daily);
    return daily;
  }

  // ─── Read ────────────────────────────────────────────────────

  /// الخطوات المحفوظة النهارده (للعرض بدون stream)
  int get savedDailySteps {
    if (_prefs.getString(_keyBaseDate) != dayKey(DateTime.now())) return 0;
    return _prefs.getInt(_keyDailySteps) ?? 0;
  }

  /// خطوات يوم معيّن (لصفحة التقدم)
  int stepsForDay(DateTime d) {
    final key = dayKey(d);
    if (key == dayKey(DateTime.now())) return savedDailySteps;
    return _prefs.getInt(_historyKey(key)) ?? 0;
  }

  // ─── Goal notification (مرة واحدة في اليوم) ──────────────────

  Future<bool> consumeGoalNotification(int steps, int goal) async {
    if (steps < goal) return false;
    final today = dayKey(DateTime.now());
    if (_prefs.getString(_keyGoalNotified) == today) return false;
    await _prefs.setString(_keyGoalNotified, today);
    return true;
  }

  // ─── Keys ────────────────────────────────────────────────────

  static String dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _historyKey(String dayKey) => 'steps_$dayKey';
}
