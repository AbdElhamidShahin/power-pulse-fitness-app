import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../data/repo/exercise_repository.dart';
import 'exercise_state.dart';

class ExerciseCubit extends Cubit<ExerciseState> {
  ExerciseCubit(this._repository) : super(const ExerciseLoading());

  final ExerciseRepository _repository;

  Future<void> load(String pageId, {int limit = 20}) async {
    emit(const ExerciseLoading());

    final result = await _repository.getExercises(pageId);

    switch (result) {
      case ApiSuccess(:final data):
        final limited = limit > 0 ? data.take(limit).toList() : data;
        emit(ExerciseLoaded(limited));
      case ApiFailure(:final failure):
        emit(ExerciseError(failure.message));
    }
  }
}
