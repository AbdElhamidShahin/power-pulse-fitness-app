import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/progress_entity.dart';

abstract interface class ProgressLocalService {
  Future<List<WeightEntry>> getWeightEntries({int limitDays});
  Future<void> addWeightEntry(WeightEntry entry);
  Future<void> deleteWeightEntry(String id);
  Future<List<WorkoutLog>> getWorkoutLogs({int limitDays});
  Future<void> logWorkout(WorkoutLog log);
}

final class ProgressLocalServiceImpl implements ProgressLocalService {
  ProgressLocalServiceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const _weightKey  = 'weight_entries';
  static const _workoutKey = 'workout_logs';

  // ─── Weight ─────────────────────────────────────────────────
  @override
  Future<List<WeightEntry>> getWeightEntries({int limitDays = 90}) async {
    try {
      final raw = _prefs.getString(_weightKey);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      final cutoff = DateTime.now().subtract(Duration(days: limitDays));
      return list
          .map((e) => _weightFromJson(e as Map<String, dynamic>))
          .where((e) => e.date.isAfter(cutoff))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    } catch (e) {
      throw CacheException(message: 'خطأ في قراءة بيانات الوزن: ${e.runtimeType}');
    }
  }

  @override
  Future<void> addWeightEntry(WeightEntry entry) async {
    try {
      final all = await _allWeightEntries();
      all.add(entry);
      await _prefs.setString(
          _weightKey, jsonEncode(all.map(_weightToJson).toList()));
    } catch (e) {
      throw CacheException(message: 'خطأ في حفظ الوزن: ${e.runtimeType}');
    }
  }

  @override
  Future<void> deleteWeightEntry(String id) async {
    try {
      final all = await _allWeightEntries();
      all.removeWhere((e) => e.id == id);
      await _prefs.setString(
          _weightKey, jsonEncode(all.map(_weightToJson).toList()));
    } catch (e) {
      throw CacheException(message: 'خطأ في حذف الوزن: ${e.runtimeType}');
    }
  }

  Future<List<WeightEntry>> _allWeightEntries() async {
    final raw = _prefs.getString(_weightKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => _weightFromJson(e as Map<String, dynamic>)).toList();
  }

  // ─── Workouts ────────────────────────────────────────────────
  @override
  Future<List<WorkoutLog>> getWorkoutLogs({int limitDays = 90}) async {
    try {
      final raw = _prefs.getString(_workoutKey);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      final cutoff = DateTime.now().subtract(Duration(days: limitDays));
      return list
          .map((e) => _workoutFromJson(e as Map<String, dynamic>))
          .where((e) => e.date.isAfter(cutoff))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      throw CacheException(message: 'خطأ في قراءة سجل التمارين: ${e.runtimeType}');
    }
  }

  @override
  Future<void> logWorkout(WorkoutLog log) async {
    try {
      final raw = _prefs.getString(_workoutKey);
      final list = raw != null ? jsonDecode(raw) as List<dynamic> : [];
      final all = list
          .map((e) => _workoutFromJson(e as Map<String, dynamic>))
          .toList();
      all.add(log);
      await _prefs.setString(
          _workoutKey, jsonEncode(all.map(_workoutToJson).toList()));
    } catch (e) {
      throw CacheException(message: 'خطأ في حفظ التمرين: ${e.runtimeType}');
    }
  }

  // ─── JSON ────────────────────────────────────────────────────
  Map<String, dynamic> _weightToJson(WeightEntry e) => {
        'id': e.id, 'weight': e.weight,
        'date': e.date.toIso8601String(), 'note': e.note,
      };

  WeightEntry _weightFromJson(Map<String, dynamic> j) => WeightEntry(
        id:     j['id'] as String,
        weight: (j['weight'] as num).toDouble(),
        date:   DateTime.parse(j['date'] as String),
        note:   j['note'] as String?,
      );

  Map<String, dynamic> _workoutToJson(WorkoutLog e) => {
        'id': e.id, 'name': e.name,
        'date': e.date.toIso8601String(),
        'durationMinutes': e.durationMinutes,
        'caloriesBurned': e.caloriesBurned,
        'exerciseCount': e.exerciseCount,
      };

  WorkoutLog _workoutFromJson(Map<String, dynamic> j) => WorkoutLog(
        id:              j['id'] as String,
        name:            j['name'] as String,
        date:            DateTime.parse(j['date'] as String),
        durationMinutes: j['durationMinutes'] as int,
        caloriesBurned:  (j['caloriesBurned'] as num).toDouble(),
        exerciseCount:   j['exerciseCount'] as int? ?? 0,
      );
}
