import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:power_pulse/core/domain/api_result.dart';
import '../../../exercises/data/models/exercise_entity.dart';
import '../../../workout_plan/data/models/workout_plan_entity.dart';
import '../../data/models/workout_session_entity.dart';
import '../usecases/workout_logger_usecases.dart';
import 'workout_logger_state.dart';

/// WorkoutLoggerCubit — مسؤول عن إدارة الجلسة النشطة فقط.
///
/// Step 5 (P1 fix): أُزيلت الـ cross-feature dependencies:
///   - SearchExercisesUseCase  → انتقلت لـ AddExerciseSheet
///   - GetExercisesUseCase     → انتقلت لـ AddExerciseSheet
///   - LogWorkoutUseCase       → انتقل لـ workout_logger_screen (UI listener)
///
/// الـ Cubit دلوقتي بيعرف بس عن workout_logger feature.
final class WorkoutLoggerCubit extends Cubit<WorkoutLoggerState> {
  WorkoutLoggerCubit({
    required GetActiveSessionUseCase getActiveSession,
    required SaveSessionUseCase saveSession,
    required DeleteSessionUseCase deleteSession,
  })  : _getActive = getActiveSession,
        _save = saveSession,
        _delete = deleteSession,
        super(const WorkoutLoggerInitial());

  final GetActiveSessionUseCase _getActive;
  final SaveSessionUseCase _save;
  final DeleteSessionUseCase _delete;

  // Guard: prevents concurrent finishSession calls (double-tap → double LogWorkout)
  bool _isFinishing = false;

  // ─── Load ──────────────────────────────────────────────────
  Future<void> load() async {
    emit(const WorkoutLoggerLoading());
    emit(const WorkoutLoggerIdle());
  }

  // ─── Start ─────────────────────────────────────────────────
  Future<void> startSession(String name, {PlanDay? planDay}) async {
    final exercises = planDay != null
        ? planDay.exercises
            .map((pe) => SessionExercise(
                  exerciseId:
                      '\${pe.exerciseId}_\${DateTime.now().millisecondsSinceEpoch}',
                  exerciseName: pe.exerciseName,
                  bodyPart: pe.bodyPart,
                  gifPath: pe.gifUrl,
                  sets: List.generate(
                    pe.defaultSets,
                    (i) => ExerciseSet(setNumber: i + 1, reps: pe.defaultReps),
                  ),
                ))
            .toList()
        : <SessionExercise>[];

    final session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      startTime: DateTime.now(),
      exercises: exercises,
    );
    final result = await _save(session);
    if (isClosed) return;
    switch (result) {
      case Success():
        emit(WorkoutLoggerActive(session));
      case Failure(:final failure):
        emit(WorkoutLoggerError(failure.userMessage));
    }
  }

  // ─── Add / Remove Exercise ─────────────────────────────────
  void addExercise(SessionExercise exercise) {
    final current = _active;
    if (current == null) return;
    _updateActive(
        current.copyWith(exercises: [...current.exercises, exercise]));
  }

  void removeExercise(String exerciseId) {
    final current = _active;
    if (current == null) return;
    _updateActive(current.copyWith(
      exercises:
          current.exercises.where((e) => e.exerciseId != exerciseId).toList(),
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
      final renumbered = sets
          .asMap()
          .entries
          .map((e) => ExerciseSet(
              setNumber: e.key + 1,
              reps: e.value.reps,
              weight: e.value.weight,
              isCompleted: e.value.isCompleted))
          .toList();
      return ex.copyWith(sets: renumbered);
    }).toList();
    _updateActive(current.copyWith(exercises: exercises));
  }

  // ─── Mark Exercise Done ────────────────────────────────────
  Future<void> markExerciseDone(String exerciseId) async {
    final current = _active;
    if (current == null) return;
    final exercises = current.exercises.map((ex) {
      if (ex.exerciseId != exerciseId) return ex;
      final doneSets = ex.sets
          .map((s) => ExerciseSet(
                setNumber: s.setNumber,
                reps: s.reps,
                weight: s.weight,
                isCompleted: true,
              ))
          .toList();
      return ex.copyWith(sets: doneSets, isDone: true);
    }).toList();
    await _updateActive(current.copyWith(exercises: exercises));
  }

  // ─── Finish ────────────────────────────────────────────────
  /// ينهي الجلسة ويُصدر [WorkoutLoggerFinished].
  /// الـ UI (workout_logger_screen) مسؤول عن استدعاء LogWorkoutUseCase
  /// بعد ما يستقبل هذه الحالة — عشان نتجنب الـ cross-feature coupling.
  Future<void> finishSession() async {
    // Synchronous guard — prevents a concurrent second call (rapid double-tap)
    // from saving the session twice and firing LogWorkoutUseCase twice.
    if (_isFinishing) return;
    final current = _active;
    if (current == null) return;
    _isFinishing = true;

    final finished = current.copyWith(
      endTime: DateTime.now(),
      caloriesBurned: current.durationMinutes * 5.0,
    );

    final result = await _save(finished);
    _isFinishing = false;
    if (isClosed) return;
    switch (result) {
      case Success():
        emit(WorkoutLoggerFinished(finished));
      case Failure(:final failure):
        emit(WorkoutLoggerError(failure.userMessage));
    }
  }

  // ─── Cancel / Reset ────────────────────────────────────────
  Future<void> cancelSession() async {
    final current = _active;
    if (current != null) await _delete(current.id);
    if (!isClosed) emit(const WorkoutLoggerIdle());
  }

  void reset() => emit(const WorkoutLoggerIdle());

  // ─── Helpers ───────────────────────────────────────────────
  WorkoutSession? get _active => state is WorkoutLoggerActive
      ? (state as WorkoutLoggerActive).session
      : null;

  Future<void> _updateActive(WorkoutSession session) async {
    final result = await _save(session);
    // Mid-workout auto-save: always update the UI to reflect in-memory state.
    // A transient save failure is logged but does NOT abort the active workout —
    // the next successful save (set update, exercise add, or finishSession) will
    // persist the accumulated changes.
    if (result is Failure && kDebugMode) {
      debugPrint('[WorkoutLogger] mid-workout save failed: '
          '${(result as Failure).failure.userMessage}');
    }
    if (!isClosed) emit(WorkoutLoggerActive(session));
  }
}
