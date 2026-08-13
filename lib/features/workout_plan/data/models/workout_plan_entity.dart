
final class PlanExercise {
  const PlanExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.bodyPart,
    this.gifUrl = '',
    this.defaultSets = 3,
    this.defaultReps = 10,
  });

  final String exerciseId;
  final String exerciseName;
  final String bodyPart;
  final String gifUrl;
  final int defaultSets;
  final int defaultReps;

  PlanExercise copyWith({int? defaultSets, int? defaultReps}) => PlanExercise(
    exerciseId: exerciseId,
    exerciseName: exerciseName,
    bodyPart: bodyPart,
    gifUrl: gifUrl,
    defaultSets: defaultSets ?? this.defaultSets,
    defaultReps: defaultReps ?? this.defaultReps,
  );

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'exerciseName': exerciseName,
    'bodyPart': bodyPart,
    'gifUrl': gifUrl,
    'defaultSets': defaultSets,
    'defaultReps': defaultReps,
  };

  factory PlanExercise.fromJson(Map<String, dynamic> j) => PlanExercise(
    exerciseId: j['exerciseId'] as String,
    exerciseName: j['exerciseName'] as String,
    bodyPart: j['bodyPart'] as String,
    gifUrl: j['gifUrl'] as String? ?? '',
    defaultSets: j['defaultSets'] as int? ?? 3,
    defaultReps: j['defaultReps'] as int? ?? 10,
  );
}

final class PlanDay {
  const PlanDay({
    required this.weekday,
    required this.isRest,
    this.name = '',
    this.exercises = const [],
  });

  final int weekday;
  final bool isRest;
  final String name;
  final List<PlanExercise> exercises;

  bool get hasExercises => !isRest && exercises.isNotEmpty;

  int get estimatedMinutes => exercises.length * 12;

  PlanDay copyWith({
    bool? isRest,
    String? name,
    List<PlanExercise>? exercises,
  }) =>
      PlanDay(
        weekday: weekday,
        isRest: isRest ?? this.isRest,
        name: name ?? this.name,
        exercises: exercises ?? this.exercises,
      );

  Map<String, dynamic> toJson() => {
    'weekday': weekday,
    'isRest': isRest,
    'name': name,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };

  factory PlanDay.fromJson(Map<String, dynamic> j) => PlanDay(
    weekday: j['weekday'] as int,
    isRest: j['isRest'] as bool? ?? false,
    name: j['name'] as String? ?? '',
    exercises: (j['exercises'] as List<dynamic>? ?? [])
        .map((e) => PlanExercise.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

final class WorkoutPlan {
  const WorkoutPlan({
    required this.id,
    required this.days,
    required this.createdAt,
  });

  final String id;
  final List<PlanDay> days;
  final DateTime createdAt;

  PlanDay dayFor(DateTime date) {
    final wd = date.weekday;
    return days.firstWhere(
          (d) => d.weekday == wd,
      orElse: () => PlanDay(weekday: wd, isRest: true),
    );
  }

  int get activeDaysCount => days.where((d) => d.hasExercises).length;

  WorkoutPlan copyWith({List<PlanDay>? days}) => WorkoutPlan(
    id: id,
    days: days ?? this.days,
    createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'days': days.map((d) => d.toJson()).toList(),
  };

  factory WorkoutPlan.fromJson(Map<String, dynamic> j) => WorkoutPlan(
    id: j['id'] as String,
    createdAt: DateTime.parse(j['createdAt'] as String),
    days: (j['days'] as List<dynamic>)
        .map((d) => PlanDay.fromJson(d as Map<String, dynamic>))
        .toList(),
  );

  static WorkoutPlan empty() => WorkoutPlan(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    createdAt: DateTime.now(),
    days: List.generate(
      7,
          (i) => PlanDay(weekday: i + 1, isRest: true),
    ),
  );
}

const weekdayNamesAr = ['الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
