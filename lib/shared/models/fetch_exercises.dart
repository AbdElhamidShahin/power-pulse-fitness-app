import 'dart:convert';

import 'package:flutter/services.dart';
import 'exercise.dart';

Future<Map<String, List<Exercise>>> fetchExercisesFromJson() async {
  try {
    final String response =
        await rootBundle.loadString('assets/exercises.json');
    final data = json.decode(response) as Map<String, dynamic>;
    Map<String, List<Exercise>> exercisesMap = data.map((key, value) {
      List<Exercise> exercises = (value as List<dynamic>)
          .map((json) => Exercise.fromJson(json))
          .toList();
      return MapEntry(key, exercises);
    });
    return exercisesMap;
  } catch (e) {
    throw e;
  }
}
