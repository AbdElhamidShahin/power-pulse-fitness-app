import '../../../../shared/models/exercise.dart';

sealed class ExerciseState {
  const ExerciseState();
}

final class ExerciseLoading extends ExerciseState {
  const ExerciseLoading();
}

final class ExerciseLoaded extends ExerciseState {
  const ExerciseLoaded(this.exercises);
  final List<Exercise> exercises;
}

final class ExerciseError extends ExerciseState {
  const ExerciseError(this.message);
  final String message;
}
