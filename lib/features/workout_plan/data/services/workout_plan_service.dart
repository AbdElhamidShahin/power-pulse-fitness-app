import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/workout_plan_entity.dart';

abstract interface class WorkoutPlanService {
  Future<WorkoutPlan?> getPlan();
  Future<void> savePlan(WorkoutPlan plan);
  Future<void> deletePlan();
}

final class WorkoutPlanServiceImpl implements WorkoutPlanService {
  WorkoutPlanServiceImpl(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'workout_plan';

  @override
  Future<WorkoutPlan?> getPlan() async {
    try {
      final raw = _prefs.getString(_key);
      if (raw == null) return null;
      return WorkoutPlan.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      throw const CacheException(message: 'خطأ في قراءة خطة التمرين');
    }
  }

  @override
  Future<void> savePlan(WorkoutPlan plan) async {
    try {
      await _prefs.setString(_key, jsonEncode(plan.toJson()));
    } catch (_) {
      throw const CacheException(message: 'خطأ في حفظ خطة التمرين');
    }
  }

  @override
  Future<void> deletePlan() async {
    await _prefs.remove(_key);
  }
}
