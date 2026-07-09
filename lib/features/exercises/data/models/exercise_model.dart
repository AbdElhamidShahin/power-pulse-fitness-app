import 'exercise_entity.dart';

/// ExerciseModel — Data Layer
/// Parses JSON from ExerciseDB API
/// Maps to domain Exercise entity
final class ExerciseModel {
  const ExerciseModel({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.target,
    required this.equipment,
    required this.gifUrl,
    this.secondaryMuscles = const [],
    this.instructions = const [],
  });

  final String id;
  final String name;
  final String bodyPart;
  final String target;
  final String equipment;
  final String gifUrl;
  final List<String> secondaryMuscles;
  final List<String> instructions;

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id:        json['id']?.toString()        ?? '',
      name:      json['name']?.toString()      ?? '',
      bodyPart:  json['bodyPart']?.toString()  ?? '',
      target:    json['target']?.toString()    ?? '',
      equipment: json['equipment']?.toString() ?? '',
      gifUrl:    json['gifUrl']?.toString()    ?? '',
      secondaryMuscles: (json['secondaryMuscles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      instructions: (json['instructions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  /// Map to domain entity
  Exercise toEntity() => Exercise(
        id:               id,
        name:             name,
        bodyPart:         bodyPart,
        target:           target,
        equipment:        equipment,
        gifUrl:           gifUrl,
        secondaryMuscles: secondaryMuscles,
        instructions:     instructions,
      );

  static List<Exercise> toEntityList(List<dynamic> json) =>
      json
          .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
}
