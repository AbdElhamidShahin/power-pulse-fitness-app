import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../../shared/models/exercise.dart';

class ExerciseService {
  const ExerciseService();

  Future<Map<String, List<Exercise>>> loadAll() async {
    try {
      final raw = await rootBundle.loadString('assets/exercises.json');
      final data = json.decode(raw) as Map<String, dynamic>;
      return data.map((key, value) {
        final list = (value as List<dynamic>)
            .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
            .toList();
        return MapEntry(key, list);
      });
    } on FlutterError catch (e) {
      throw Exception('فشل تحميل ملف التمارين: ${e.message}');
    } catch (e) {
      throw Exception('خطأ غير متوقع: $e');
    }
  }
}
