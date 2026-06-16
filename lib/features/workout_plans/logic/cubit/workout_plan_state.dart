import '../../../../core/models/exercise.dart';

/// Workout plan (custom system) states — sealed class (CLAUDE.md §B.2).
sealed class WorkoutPlanState {
  const WorkoutPlanState();
}

final class WorkoutPlanInitial extends WorkoutPlanState {
  const WorkoutPlanInitial();
}

final class WorkoutPlanLoaded extends WorkoutPlanState {
  const WorkoutPlanLoaded({
    required this.days,
    required this.selectedDay,
  });

  /// Map of day name → list of exercises.
  final Map<String, List<Exercise>> days;
  final String selectedDay;
}

final class WorkoutPlanError extends WorkoutPlanState {
  const WorkoutPlanError(this.message);
  final String message;
}
