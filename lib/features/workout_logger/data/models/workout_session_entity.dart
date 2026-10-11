/// Workout Logger Entities — Pure Dart, Zero Flutter

final class ExerciseSet {
  const ExerciseSet({
    required this.setNumber,
    this.reps,
    this.weight,
    this.durationSeconds,
    this.isCompleted = false,
  });

  final int setNumber;
  final int? reps;
  final double? weight;
  final int? durationSeconds;
  final bool isCompleted;

  ExerciseSet copyWith({int? reps, double? weight, int? durationSeconds, bool? isCompleted}) {
    return ExerciseSet(
      setNumber: setNumber,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'setNumber': setNumber, 'reps': reps, 'weight': weight,
    'durationSeconds': durationSeconds, 'isCompleted': isCompleted,
  };

  factory ExerciseSet.fromJson(Map<String, dynamic> json) => ExerciseSet(
    setNumber: json['setNumber'] as int,
    reps: json['reps'] as int?,
    weight: (json['weight'] as num?)?.toDouble(),
    durationSeconds: json['durationSeconds'] as int?,
    isCompleted: json['isCompleted'] as bool? ?? false,
  );
}

final class SessionExercise {
  const SessionExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.bodyPart,
    required this.sets,
    this.notes,
    this.gifPath,
    this.isDone = false,
  });

  final String exerciseId;
  final String exerciseName;
  final String bodyPart;
  final List<ExerciseSet> sets;
  final String? notes;
  final String? gifPath;
  final bool isDone;

  int get completedSets => sets.where((s) => s.isCompleted).length;
  bool get isFullyDone  => isDone || (sets.isNotEmpty && completedSets == sets.length);
  double get totalVolume => sets
      .where((s) => s.isCompleted && s.weight != null && s.reps != null)
      .fold(0.0, (sum, s) => sum + (s.weight! * s.reps!));

  SessionExercise copyWith({List<ExerciseSet>? sets, String? notes, bool? isDone}) =>
      SessionExercise(
        exerciseId: exerciseId, exerciseName: exerciseName,
        bodyPart: bodyPart, gifPath: gifPath,
        sets: sets ?? this.sets, notes: notes ?? this.notes,
        isDone: isDone ?? this.isDone,
      );

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId, 'exerciseName': exerciseName,
    'bodyPart': bodyPart, 'gifPath': gifPath, 'notes': notes,
    'isDone': isDone,
    'sets': sets.map((s) => s.toJson()).toList(),
  };

  factory SessionExercise.fromJson(Map<String, dynamic> json) => SessionExercise(
    exerciseId: json['exerciseId'] as String,
    exerciseName: json['exerciseName'] as String,
    bodyPart: json['bodyPart'] as String,
    gifPath: json['gifPath'] as String?,
    notes: json['notes'] as String?,
    sets: (json['sets'] as List<dynamic>)
        .map((e) => ExerciseSet.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

final class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.name,
    required this.startTime,
    this.endTime,
    required this.exercises,
    this.notes,
    this.caloriesBurned = 0,
  });

  final String id;
  final String name;
  final DateTime startTime;
  final DateTime? endTime;
  final List<SessionExercise> exercises;
  final String? notes;
  final double caloriesBurned;

  Duration get duration        => (endTime ?? DateTime.now()).difference(startTime);
  int    get durationMinutes   => duration.inMinutes;
  int    get totalSets         => exercises.fold(0, (s, e) => s + e.sets.length);
  int    get completedSets     => exercises.fold(0, (s, e) => s + e.completedSets);
  bool   get isActive          => endTime == null;
  double get totalVolume       => exercises.fold(0.0, (s, e) => s + e.totalVolume);

  WorkoutSession copyWith({
    String? name, DateTime? endTime,
    List<SessionExercise>? exercises, String? notes, double? caloriesBurned,
  }) => WorkoutSession(
    id: id, startTime: startTime,
    name: name ?? this.name,
    endTime: endTime ?? this.endTime,
    exercises: exercises ?? this.exercises,
    notes: notes ?? this.notes,
    caloriesBurned: caloriesBurned ?? this.caloriesBurned,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'notes': notes, 'caloriesBurned': caloriesBurned,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
    id: json['id'] as String,
    name: json['name'] as String,
    startTime: DateTime.parse(json['startTime'] as String),
    endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
    exercises: (json['exercises'] as List<dynamic>)
        .map((e) => SessionExercise.fromJson(e as Map<String, dynamic>))
        .toList(),
    notes: json['notes'] as String?,
    caloriesBurned: (json['caloriesBurned'] as num?)?.toDouble() ?? 0,
  );
}
