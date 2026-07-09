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
    this.secondaryMuscles = const [],
    this.instructions = const [],
  });

  final String id;
  final String name;
  final String bodyPart;   // chest, back, legs, etc.
  final String target;     // muscle targeted
  final String equipment;  // barbell, dumbbell, etc.
  final String gifUrl;
  final List<String> secondaryMuscles;
  final List<String> instructions;

  @override
  bool operator ==(Object other) =>
      other is Exercise && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Exercise(id: $id, name: $name)';
}
