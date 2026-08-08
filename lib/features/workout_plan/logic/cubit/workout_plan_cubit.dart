import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:power_pulse/core/domain/api_result.dart';
import '../../data/models/workout_plan_entity.dart';
import '../usecases/workout_plan_usecases.dart';
import 'workout_plan_state.dart';

final class WorkoutPlanCubit extends Cubit<WorkoutPlanState> {
  WorkoutPlanCubit({
    required GetWorkoutPlanUseCase getPlan,
    required SaveWorkoutPlanUseCase savePlan,
    required DeleteWorkoutPlanUseCase deletePlan,
  })  : _getPlan    = getPlan,
        _savePlan   = savePlan,
        _deletePlan = deletePlan,
        super(const WorkoutPlanInitial());

  final GetWorkoutPlanUseCase    _getPlan;
  final SaveWorkoutPlanUseCase   _savePlan;
  final DeleteWorkoutPlanUseCase _deletePlan;

  Future<void> load() async {
    emit(const WorkoutPlanLoading());
    final result = await _getPlan();
    result.fold(
      onFailure: (f) => emit(WorkoutPlanError(f.message)),
      onSuccess: (plan) => plan != null
          ? emit(WorkoutPlanLoaded(plan))
          : emit(const WorkoutPlanEmpty()),
    );
  }

  void startEditing() {
    final draft = state is WorkoutPlanLoaded
        ? (state as WorkoutPlanLoaded).plan
        : WorkoutPlan.empty();
    emit(WorkoutPlanEditing(draft));
  }

  void toggleDayRest(int weekday) {
    final draft = _draft;
    if (draft == null) return;
    final days = draft.days.map((d) {
      if (d.weekday != weekday) return d;
      return d.copyWith(isRest: !d.isRest, exercises: d.isRest ? [] : d.exercises);
    }).toList();
    emit(WorkoutPlanEditing(draft.copyWith(days: days)));
  }

  void setDayName(int weekday, String name) {
    final draft = _draft;
    if (draft == null) return;
    final days = draft.days.map((d) {
      if (d.weekday != weekday) return d;
      return d.copyWith(name: name);
    }).toList();
    emit(WorkoutPlanEditing(draft.copyWith(days: days)));
  }

  void addExerciseToDay(int weekday, PlanExercise exercise) {
    final draft = _draft;
    if (draft == null) return;
    final days = draft.days.map((d) {
      if (d.weekday != weekday) return d;
      return d.copyWith(exercises: [...d.exercises, exercise]);
    }).toList();
    emit(WorkoutPlanEditing(draft.copyWith(days: days)));
  }

  void removeExerciseFromDay(int weekday, String exerciseId) {
    final draft = _draft;
    if (draft == null) return;
    final days = draft.days.map((d) {
      if (d.weekday != weekday) return d;
      return d.copyWith(
        exercises: d.exercises.where((e) => e.exerciseId != exerciseId).toList(),
      );
    }).toList();
    emit(WorkoutPlanEditing(draft.copyWith(days: days)));
  }

  void updateExerciseDefaults(int weekday, String exerciseId, {int? sets, int? reps}) {
    final draft = _draft;
    if (draft == null) return;
    final days = draft.days.map((d) {
      if (d.weekday != weekday) return d;
      final exs = d.exercises.map((e) {
        if (e.exerciseId != exerciseId) return e;
        return e.copyWith(defaultSets: sets, defaultReps: reps);
      }).toList();
      return d.copyWith(exercises: exs);
    }).toList();
    emit(WorkoutPlanEditing(draft.copyWith(days: days)));
  }

  Future<void> saveDraft() async {
    final draft = _draft;
    if (draft == null) return;
    final result = await _savePlan(draft);
    result.fold(
      onFailure: (f) => emit(WorkoutPlanError(f.message)),
      onSuccess: (_) => emit(WorkoutPlanLoaded(draft)),
    );
  }

  Future<void> deletePlan() async {
    await _deletePlan();
    emit(const WorkoutPlanEmpty());
  }

  WorkoutPlan? get _draft =>
      state is WorkoutPlanEditing ? (state as WorkoutPlanEditing).draft : null;

  WorkoutPlan? get currentPlan =>
      state is WorkoutPlanLoaded ? (state as WorkoutPlanLoaded).plan : null;
}
