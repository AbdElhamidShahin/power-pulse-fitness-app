import '../../../exercises/data/model/exercise.dart';

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

  final Map<String, List<Exercise>> days;
  final String selectedDay;
}

final class WorkoutPlanError extends WorkoutPlanState {
  const WorkoutPlanError(this.message);
  final String message;
}
