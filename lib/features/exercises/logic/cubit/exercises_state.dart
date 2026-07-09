import '../../data/models/exercise_entity.dart';

/// ExercisesState — sealed class, Dart 3+
/// Zero Flutter imports — const constructors
sealed class ExercisesState {
  const ExercisesState();
}

final class ExercisesInitial extends ExercisesState {
  const ExercisesInitial();
}

final class ExercisesLoading extends ExercisesState {
  const ExercisesLoading();
}

final class ExercisesLoaded extends ExercisesState {
  const ExercisesLoaded({
    required this.exercises,
    required this.bodyParts,
    required this.selectedBodyPart,
    this.hasMore = true,
  });

  final List<Exercise> exercises;
  final List<String> bodyParts;
  final String selectedBodyPart;
  final bool hasMore;

  ExercisesLoaded copyWith({
    List<Exercise>? exercises,
    List<String>? bodyParts,
    String? selectedBodyPart,
    bool? hasMore,
  }) =>
      ExercisesLoaded(
        exercises:        exercises        ?? this.exercises,
        bodyParts:        bodyParts        ?? this.bodyParts,
        selectedBodyPart: selectedBodyPart ?? this.selectedBodyPart,
        hasMore:          hasMore          ?? this.hasMore,
      );
}

final class ExercisesError extends ExercisesState {
  const ExercisesError(this.message);
  final String message;
}

// ─── Search State ─────────────────────────────────────────
sealed class ExerciseSearchState {
  const ExerciseSearchState();
}

final class ExerciseSearchIdle extends ExerciseSearchState {
  const ExerciseSearchIdle();
}

final class ExerciseSearchLoading extends ExerciseSearchState {
  const ExerciseSearchLoading();
}

final class ExerciseSearchLoaded extends ExerciseSearchState {
  const ExerciseSearchLoaded(this.results);
  final List<Exercise> results;
}

final class ExerciseSearchError extends ExerciseSearchState {
  const ExerciseSearchError(this.message);
  final String message;
}

// ─── Detail State ─────────────────────────────────────────
sealed class ExerciseDetailState {
  const ExerciseDetailState();
}

final class ExerciseDetailInitial extends ExerciseDetailState {
  const ExerciseDetailInitial();
}

final class ExerciseDetailLoading extends ExerciseDetailState {
  const ExerciseDetailLoading();
}

final class ExerciseDetailLoaded extends ExerciseDetailState {
  const ExerciseDetailLoaded(this.exercise);
  final Exercise exercise;
}

final class ExerciseDetailError extends ExerciseDetailState {
  const ExerciseDetailError(this.message);
  final String message;
}
