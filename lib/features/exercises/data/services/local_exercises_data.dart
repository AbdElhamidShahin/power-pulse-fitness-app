import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/exercise_entity.dart';
import '../models/exercise_model.dart';

abstract interface class ExerciseLocalService {
  bool get isCached;

  List<Exercise> getAllExercises();

  Future<void> saveExercises(List<Exercise> exercises);

  Future<void> clearCache();
}

final class ExerciseLocalServiceImpl implements ExerciseLocalService {
  ExerciseLocalServiceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const String _exercisesKey = 'cached_exercises_v3';
  static const String _cachedAtKey = 'cached_exercises_at_v3';

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
    final list = exercises
        .map((e) => {
              'id': e.id,
              'name_en': e.name,
              'name_ar': e.nameAr,
              'category': e.bodyPart,
              'category_ar': e.bodyPartAr,
              'body_part': e.bodyPart,
              'body_part_ar': e.bodyPartAr,
              'target': e.target,
              'target_ar': e.targetAr,
              'equipment': e.equipment,
              'equipment_ar': e.equipmentAr,
              'gif_url': _extractRelativeGif(e.gifUrl),
              'secondary_muscles': e.secondaryMuscles,
              'secondary_muscles_ar': e.secondaryMusclesAr,
              'instruction_steps': {
                'en': e.instructions,
                'ar': e.instructionsAr,
              },
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

  DateTime? get cachedAt {
    final raw = _prefs.getString(_cachedAtKey);
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  String _extractRelativeGif(String fullUrl) {
    const marker = 'exercises-dataset@main/';
    final idx = fullUrl.indexOf(marker);
    if (idx != -1) return fullUrl.substring(idx + marker.length);
    return fullUrl;
  }
}
