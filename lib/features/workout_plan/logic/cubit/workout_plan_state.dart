import '../../data/models/workout_plan_entity.dart';

sealed class WorkoutPlanState {
  const WorkoutPlanState();
}

final class WorkoutPlanInitial extends WorkoutPlanState {
  const WorkoutPlanInitial();
}

final class WorkoutPlanLoading extends WorkoutPlanState {
  const WorkoutPlanLoading();
}
final class WorkoutPlanLoaded extends WorkoutPlanState {
  const WorkoutPlanLoaded(this.plan);
  final WorkoutPlan plan;
}

final class WorkoutPlanEditing extends WorkoutPlanState {
  const WorkoutPlanEditing(this.draft);
  final WorkoutPlan draft;
}
final class WorkoutPlanEmpty extends WorkoutPlanState {
  const WorkoutPlanEmpty();
}

final class WorkoutPlanError extends WorkoutPlanState {
  const WorkoutPlanError(this.message);
  final String message;
}
