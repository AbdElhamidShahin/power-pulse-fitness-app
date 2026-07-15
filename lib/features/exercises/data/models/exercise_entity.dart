/// Exercise Entity — Domain Layer
/// Pure Dart — Zero Flutter imports
final class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.target,
    required this.equipment,
    required this.gifUrl,
    this.nameAr = '',
    this.bodyPartAr = '',
    this.targetAr = '',
    this.equipmentAr = '',
    this.secondaryMuscles = const [],
    this.secondaryMusclesAr = const [],
    this.instructions = const [],
    this.instructionsAr = const [],
  });

  final String id;
  final String name;
  final String bodyPart;
  final String target;
  final String equipment;
  final String gifUrl;

  // ─── Arabic fields ──────────────────────────────────────
  final String nameAr;
  final String bodyPartAr;
  final String targetAr;
  final String equipmentAr;
  final List<String> secondaryMuscles;
  final List<String> secondaryMusclesAr;
  final List<String> instructions;
  final List<String> instructionsAr;

  @override
  bool operator ==(Object other) => other is Exercise && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Exercise(id: $id, name: $name)';
}
