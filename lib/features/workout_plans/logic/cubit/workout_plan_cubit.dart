import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/exercise.dart';
import '../../../../shared/providers/item_provider.dart';
import '../../data/repositories/workout_plan_repository.dart';
import 'workout_plan_state.dart';

/// Drives the custom workout plan (YourExersize) screen.
///
/// Depends only on [WorkoutPlanRepository]. (CLAUDE.md §B.1)
class WorkoutPlanCubit extends Cubit<WorkoutPlanState> {
  WorkoutPlanCubit(this._repository) : super(const WorkoutPlanInitial());

  final WorkoutPlanRepository _repository;

  static const defaultDays = [
    'السبت', 'الأحد', 'الاثنين', 'الثلاثاء',
    'الأربعاء', 'الخميس', 'الجمعة',
  ];

  void load(ItemProvider provider, {String? day}) {
    final result = _repository.getPlans(provider);
    switch (result) {
      case ApiSuccess(:final data):
        emit(WorkoutPlanLoaded(
          days: data,
          selectedDay: day ?? defaultDays.first,
        ));
      case ApiFailure(:final failure):
        emit(WorkoutPlanError(failure.message));
    }
  }

  void selectDay(ItemProvider provider, String day) {
    final result = _repository.getPlans(provider);
    switch (result) {
      case ApiSuccess(:final data):
        emit(WorkoutPlanLoaded(days: data, selectedDay: day));
      case ApiFailure(:final failure):
        emit(WorkoutPlanError(failure.message));
    }
  }

  void addExercise(ItemProvider provider, String day, Exercise exercise) {
    final result = _repository.addExercise(provider, day, exercise);
    switch (result) {
      case ApiSuccess():
        load(provider, day: _currentDay);
      case ApiFailure(:final failure):
        emit(WorkoutPlanError(failure.message));
    }
  }

  void removeExercise(ItemProvider provider, String day, Exercise exercise) {
    final result = _repository.removeExercise(provider, day, exercise);
    switch (result) {
      case ApiSuccess():
        load(provider, day: _currentDay);
      case ApiFailure(:final failure):
        emit(WorkoutPlanError(failure.message));
    }
  }

  String get _currentDay => switch (state) {
        WorkoutPlanLoaded(:final selectedDay) => selectedDay,
        _ => defaultDays.first,
      };
}
