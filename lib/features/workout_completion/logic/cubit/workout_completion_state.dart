sealed class WorkoutCompletionState {
  const WorkoutCompletionState();
}

final class WorkoutCompletionInitial extends WorkoutCompletionState {
  const WorkoutCompletionInitial();
}

final class WorkoutCompletionSaving extends WorkoutCompletionState {
  const WorkoutCompletionSaving();
}

final class WorkoutCompletionSaved extends WorkoutCompletionState {
  const WorkoutCompletionSaved();
}

final class WorkoutCompletionError extends WorkoutCompletionState {
  const WorkoutCompletionError(this.message);
  final String message;
}
