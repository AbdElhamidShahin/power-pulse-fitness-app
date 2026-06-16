import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../data/repo/workout_completion_repository.dart';
import 'workout_completion_state.dart';

class WorkoutCompletionCubit extends Cubit<WorkoutCompletionState> {
  WorkoutCompletionCubit(this._repository)
      : super(const WorkoutCompletionInitial());

  final WorkoutCompletionRepository _repository;

  Future<void> recordCompletion() async {
    if (state is WorkoutCompletionSaving) return;
    emit(const WorkoutCompletionSaving());

    final result = await _repository.recordCompletion();

    switch (result) {
      case ApiSuccess():
        emit(const WorkoutCompletionSaved());
      case ApiFailure(:final failure):
        emit(WorkoutCompletionError(failure.message));
    }
  }
}
