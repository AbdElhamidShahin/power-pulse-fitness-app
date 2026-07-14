import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/exercise_entity.dart';
import '../models/exercise_model.dart';

/// ExerciseLocalService — Cache Layer
/// يخزن الداتا في SharedPreferences
/// الداتا تنزل مرة واحدة بس وتفضل محفوظة
abstract interface class ExerciseLocalService {
  /// هل الداتا محفوظة عندنا؟
  bool get isCached;

  /// جيب كل التمارين من الـ cache
  List<Exercise> getAllExercises();

  /// احفظ الداتا في الـ cache
  Future<void> saveExercises(List<Exercise> exercises);

  /// امسح الـ cache (للـ refresh لو احتجنا)
  Future<void> clearCache();
}

final class ExerciseLocalServiceImpl implements ExerciseLocalService {
  ExerciseLocalServiceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const String _exercisesKey   = 'cached_exercises_v1';
  static const String _cachedAtKey    = 'cached_exercises_at_v1';

  @override
  bool get isCached => _prefs.containsKey(_exercisesKey);

  @override
  List<Exercise> getAllExercises() {
    final raw = _prefs.getString(_exercisesKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return ExerciseModel.toEntityList(list);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveExercises(List<Exercise> exercises) async {
    // نحول الـ entities لـ JSON قبل التخزين
    final list = exercises
        .map((e) => {
      'id':                e.id,
      'name':              e.name,
      'category':          e.bodyPart,
      'body_part':         e.bodyPart,
      'target':            e.target,
      'equipment':         e.equipment,
      'gif_url':           _extractRelativeGif(e.gifUrl),
      'secondary_muscles': e.secondaryMuscles,
      'instruction_steps': {'en': e.instructions},
    })
        .toList();

    await _prefs.setString(_exercisesKey, jsonEncode(list));
    await _prefs.setString(_cachedAtKey, DateTime.now().toIso8601String());
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(_exercisesKey);
    await _prefs.remove(_cachedAtKey);
  }

  /// تاريخ آخر تحميل (للـ debug)
  DateTime? get cachedAt {
    final raw = _prefs.getString(_cachedAtKey);
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  // ─── Private ───────────────────────────────────────────────
  /// لما نحفظ نرجع الـ path النسبي بس بدون الـ CDN base
  String _extractRelativeGif(String fullUrl) {
    const marker = 'exercises-dataset@main/';
    final idx = fullUrl.indexOf(marker);
    if (idx != -1) return fullUrl.substring(idx + marker.length);
    return fullUrl;
  }
}
