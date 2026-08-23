import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PedometerService {
  PedometerService(this._prefs);
  final SharedPreferences _prefs;

  static const _keyBaseSteps   = 'pedometer_base_steps';
  static const _keyBaseDate    = 'pedometer_base_date';
  static const _keyDailySteps  = 'pedometer_daily_steps';

  Stream<int> get dailyStepsStream async* {
    await for (final event in Pedometer.stepCountStream) {
      final today = _todayKey();
      final savedDate = _prefs.getString(_keyBaseDate);

      if (savedDate != today) {
        await _prefs.setInt(_keyBaseSteps, event.steps);
        await _prefs.setString(_keyBaseDate, today);
        await _prefs.setInt(_keyDailySteps, 0);
        yield 0;
      } else {
        final base = _prefs.getInt(_keyBaseSteps) ?? event.steps;
        final daily = (event.steps - base).clamp(0, 999999);
        await _prefs.setInt(_keyDailySteps, daily);
        yield daily;
      }
    }
  }

  int get savedDailySteps => _prefs.getInt(_keyDailySteps) ?? 0;

  String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }
}
