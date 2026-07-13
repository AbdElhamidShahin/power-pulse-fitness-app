import '../models/exercise_entity.dart';

abstract class LocalExercisesData {
  static const List<String> bodyParts = [
    'chest',
    'back',
    'shoulders',
    'upper arms',
    'lower arms',
    'upper legs',
    'lower legs',
    'waist',
    'cardio',
  ];

  static const Map<String, String> bodyPartAr = {
    'chest': 'صدر',
    'back': 'ظهر',
    'shoulders': 'أكتاف',
    'upper arms': 'عضلات ذراع علوي',
    'lower arms': 'ساعد',
    'upper legs': 'أرجل علوي',
    'lower legs': 'أرجل سفلي',
    'waist': 'بطن',
    'cardio': 'كارديو',
  };

  static final List<Exercise> exercises = [];

  static Exercise _ex(
    String id,
    String name,
    String bodyPart,
    String equipment, {
    required String desc,
  }) =>
      Exercise(
        id: id,
        name: name,
        bodyPart: bodyPart,
        target: bodyPart,
        equipment: equipment,
        gifUrl: '',
        instructions: [desc],
        secondaryMuscles: const [],
      );

  static List<Exercise> byBodyPart(String bodyPart) =>
      exercises.where((e) => e.bodyPart == bodyPart).toList();

  static List<Exercise> search(String query) {
    final q = query.toLowerCase();
    return exercises
        .where((e) => e.name.contains(q) || e.bodyPart.contains(q))
        .toList();
  }

  static Exercise? byId(String id) => exercises
      .cast<Exercise?>()
      .firstWhere((e) => e?.id == id, orElse: () => null);
}
