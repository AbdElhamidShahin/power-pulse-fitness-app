import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:power_pulse/core/domain/api_result.dart';
import '../../../progress/data/models/progress_entity.dart';
import '../../../progress/logic/usecases/progress_usecases.dart';
import '../../data/models/workout_session_entity.dart';
import '../usecases/workout_logger_usecases.dart';
import 'workout_logger_state.dart';

final class WorkoutLoggerCubit extends Cubit<WorkoutLoggerState> {
  WorkoutLoggerCubit({
    required GetActiveSessionUseCase getActiveSession,
    required SaveSessionUseCase saveSession,
    required DeleteSessionUseCase deleteSession,
    required LogWorkoutUseCase logWorkout,
  })  : _getActive  = getActiveSession,
        _save       = saveSession,
        _delete     = deleteSession,
        _logWorkout = logWorkout,
        super(const WorkoutLoggerInitial());

  final GetActiveSessionUseCase _getActive;
  final SaveSessionUseCase      _save;
  final DeleteSessionUseCase    _delete;
  final LogWorkoutUseCase       _logWorkout;

  // ─── Load ──────────────────────────────────────────────────
  Future<void> load() async {
    emit(const WorkoutLoggerLoading());
    final result = await _getActive();
    result.fold(
      onFailure: (_) => emit(const WorkoutLoggerIdle()),
      onSuccess: (session) => emit(
        session != null ? WorkoutLoggerActive(session) : const WorkoutLoggerIdle(),
      ),
    );
  }

  // ─── Start ─────────────────────────────────────────────────
  Future<void> startSession(String name) async {
    final session = WorkoutSession(
      id:        DateTime.now().millisecondsSinceEpoch.toString(),
      name:      name,
      startTime: DateTime.now(),
      exercises: const [],
    );
    await _save(session);
    emit(WorkoutLoggerActive(session));
  }

  // ─── Add / Remove Exercise ─────────────────────────────────
  void addExercise(SessionExercise exercise) {
    final current = _active;
    if (current == null) return;
    _updateActive(current.copyWith(
        exercises: [...current.exercises, exercise]));
  }

  void removeExercise(String exerciseId) {
    final current = _active;
    if (current == null) return;
    _updateActive(current.copyWith(
      exercises: current.exercises
          .where((e) => e.exerciseId != exerciseId)
          .toList(),
    ));
  }

  // ─── Update / Add / Remove Set ─────────────────────────────
  void updateSet({
    required String exerciseId,
    required int setIndex,
    int? reps,
    double? weight,
    bool? isCompleted,
  }) {
    final current = _active;
    if (current == null) return;

    final exercises = current.exercises.map((ex) {
      if (ex.exerciseId != exerciseId) return ex;
      final sets = [...ex.sets];
      if (setIndex < sets.length) {
        sets[setIndex] = sets[setIndex].copyWith(
          reps: reps,
          weight: weight,
          isCompleted: isCompleted,
        );
      }
      return ex.copyWith(sets: sets);
    }).toList();

    _updateActive(current.copyWith(exercises: exercises));
  }

  void addSet(String exerciseId) {
    final current = _active;
    if (current == null) return;
    final exercises = current.exercises.map((ex) {
      if (ex.exerciseId != exerciseId) return ex;
      return ex.copyWith(sets: [
        ...ex.sets,
        ExerciseSet(setNumber: ex.sets.length + 1),
      ]);
    }).toList();
    _updateActive(current.copyWith(exercises: exercises));
  }

  void removeSet(String exerciseId, int setIndex) {
    final current = _active;
    if (current == null) return;
    final exercises = current.exercises.map((ex) {
      if (ex.exerciseId != exerciseId) return ex;
      final sets = [...ex.sets]..removeAt(setIndex);
      final renumbered = sets.asMap().entries
          .map((e) => ExerciseSet(
              setNumber:   e.key + 1,
              reps:        e.value.reps,
              weight:      e.value.weight,
              isCompleted: e.value.isCompleted))
          .toList();
      return ex.copyWith(sets: renumbered);
    }).toList();
    _updateActive(current.copyWith(exercises: exercises));
  }

  // ─── Finish ────────────────────────────────────────────────
  Future<void> finishSession() async {
    final current = _active;
    if (current == null) return;

    final finished = current.copyWith(
      endTime:        DateTime.now(),
      caloriesBurned: current.durationMinutes * 5.0,
    );

    await _save(finished);

    // سجّل في Progress feature
    await _logWorkout(WorkoutLog(
      id:              finished.id,
      name:            finished.name,
      date:            finished.startTime,
      durationMinutes: finished.durationMinutes,
      caloriesBurned:  finished.caloriesBurned,
      exerciseCount:   finished.exercises.length,
    ));

    emit(WorkoutLoggerFinished(finished));
  }

  // ─── Cancel / Reset ────────────────────────────────────────
  Future<void> cancelSession() async {
    final current = _active;
    if (current != null) await _delete(current.id);
    emit(const WorkoutLoggerIdle());
  }

  void reset() => emit(const WorkoutLoggerIdle());

  // ─── Helpers ───────────────────────────────────────────────
  WorkoutSession? get _active =>
      state is WorkoutLoggerActive ? (state as WorkoutLoggerActive).session : null;

  Future<void> _updateActive(WorkoutSession session) async {
    await _save(session);
    emit(WorkoutLoggerActive(session));
  }
}
