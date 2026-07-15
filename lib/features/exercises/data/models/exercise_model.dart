import '../../../../core/network/api_endpoints.dart';
import 'exercise_entity.dart';

/// ExerciseModel — Data Layer
/// Parses JSON from power-pulse-exercises Arabic dataset
final class ExerciseModel {
  const ExerciseModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.bodyPart,
    required this.bodyPartAr,
    required this.target,
    required this.targetAr,
    required this.equipment,
    required this.equipmentAr,
    required this.gifUrl,
    this.secondaryMuscles = const [],
    this.secondaryMusclesAr = const [],
    this.instructions = const [],
    this.instructionsAr = const [],
  });

  final String id;
  final String name;
  final String nameAr;
  final String bodyPart;
  final String bodyPartAr;
  final String target;
  final String targetAr;
  final String equipment;
  final String equipmentAr;
  final String gifUrl;
  final List<String> secondaryMuscles;
  final List<String> secondaryMusclesAr;
  final List<String> instructions;
  final List<String> instructionsAr;

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    // gif_url: path نسبي → CDN كامل
    final rawGif = json['gif_url']?.toString() ?? '';
    final gifUrl = rawGif.isNotEmpty
        ? '${ApiEndpoints.mediaCdnBase}/$rawGif'
        : '';

    // instruction_steps
    List<String> _parseSteps(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return raw.map((e) => e.toString()).toList();
      return [];
    }

    final stepsEn = _parseSteps(
      json['instruction_steps'] is Map
          ? (json['instruction_steps'] as Map)['en']
          : json['instruction_steps'],
    );
    final stepsAr = _parseSteps(
      json['instruction_steps'] is Map
          ? (json['instruction_steps'] as Map)['ar']
          : null,
    );

    return ExerciseModel(
      id:                  json['id']?.toString()            ?? '',
      name:                json['name_en']?.toString()       ??
          json['name']?.toString()          ?? '',
      nameAr:              json['name_ar']?.toString()       ?? '',
      bodyPart:            json['category']?.toString()      ?? json['body_part']?.toString() ?? '',
      bodyPartAr:          json['category_ar']?.toString()   ?? json['body_part_ar']?.toString() ?? '',
      target:              json['target']?.toString()        ?? '',
      targetAr:            json['target_ar']?.toString()     ?? '',
      equipment:           json['equipment']?.toString()     ?? '',
      equipmentAr:         json['equipment_ar']?.toString()  ?? '',
      gifUrl:              gifUrl,
      secondaryMuscles:    (json['secondary_muscles']    as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      secondaryMusclesAr:  (json['secondary_muscles_ar'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      instructions:        stepsEn,
      instructionsAr:      stepsAr,
    );
  }

  Exercise toEntity() => Exercise(
    id:                  id,
    name:                name,
    nameAr:              nameAr,
    bodyPart:            bodyPart,
    bodyPartAr:          bodyPartAr,
    target:              target,
    targetAr:            targetAr,
    equipment:           equipment,
    equipmentAr:         equipmentAr,
    gifUrl:              gifUrl,
    secondaryMuscles:    secondaryMuscles,
    secondaryMusclesAr:  secondaryMusclesAr,
    instructions:        instructions,
    instructionsAr:      instructionsAr,
  );

  static List<Exercise> toEntityList(List<dynamic> json) =>
      json.map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>).toEntity()).toList();
}
