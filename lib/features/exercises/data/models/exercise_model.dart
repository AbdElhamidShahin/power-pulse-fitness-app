import '../../../../core/network/api_endpoints.dart';
import 'exercise_entity.dart';

/// ExerciseModel — Data Layer
/// Parses JSON from power-pulse-exercises dataset
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
    // الـ gif_url في الداتا path نسبي زي: "videos/0001-xxx.gif"
    // نحوله لرابط CDN كامل
    final rawGif = json['gif_url']?.toString() ?? '';
    final gifUrl = rawGif.isNotEmpty
        ? '${ApiEndpoints.mediaCdnBase}/$rawGif'
        : '';

    // الـ instructions موجودة كـ object { "en": "...", "ar": "..." }
    // أو كـ List في instruction_steps
    final instructionsRaw = json['instruction_steps'];
    List<String> steps = [];
    if (instructionsRaw is Map) {
      final enSteps = instructionsRaw['en'];
      if (enSteps is List) {
        steps = enSteps.map((e) => e.toString()).toList();
      }
    } else if (instructionsRaw is List) {
      steps = instructionsRaw.map((e) => e.toString()).toList();
    }

    return ExerciseModel(
      id:        json['id']?.toString()         ?? '',
      name:      json['name']?.toString()       ?? '',
      // الداتا الجديدة بتستخدم "category" أو "body_part"
      bodyPart:  json['category']?.toString()   ??
          json['body_part']?.toString()  ?? '',
      target:    json['target']?.toString()     ?? '',
      equipment: json['equipment']?.toString()  ?? '',
      gifUrl:    gifUrl,
      secondaryMuscles: (json['secondary_muscles'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      instructions: steps,
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
