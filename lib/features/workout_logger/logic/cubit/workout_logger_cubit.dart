import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:power_pulse/core/domain/api_result.dart';
import '../../../exercises/data/models/exercise_entity.dart';
import '../../../exercises/logic/usecases/exercise_usecases.dart';
import '../../../progress/data/models/progress_entity.dart';
import '../../../progress/logic/usecases/progress_usecases.dart';
import '../../../workout_plan/data/models/workout_plan_entity.dart';
import '../../data/models/workout_session_entity.dart';
import '../usecases/workout_logger_usecases.dart';
import 'workout_logger_state.dart';

final class WorkoutLoggerCubit extends Cubit<WorkoutLoggerState> {
  WorkoutLoggerCubit({
    required GetActiveSessionUseCase getActiveSession,
    required SaveSessionUseCase saveSession,
    required DeleteSessionUseCase deleteSession,
    required LogWorkoutUseCase logWorkout,
    required SearchExercisesUseCase searchExercises,
    required GetExercisesUseCase getExercises,
  })  : _getActive = getActiveSession,
        _save = saveSession,
        _delete = deleteSession,
        _logWorkout = logWorkout,
        _searchExercises = searchExercises,
        _getExercises = getExercises,
        super(const WorkoutLoggerInitial());

  final GetActiveSessionUseCase _getActive;
  final SaveSessionUseCase _save;
  final DeleteSessionUseCase _delete;
  final LogWorkoutUseCase _logWorkout;
  final SearchExercisesUseCase _searchExercises;
  final GetExercisesUseCase _getExercises;

  // ─── Load ──────────────────────────────────────────────────
  // Checks for an interrupted session saved before the app was killed.
  // If found, emits WorkoutLoggerActive so the UI can offer resume/discard.
  // If nothing is found, emits WorkoutLoggerIdle (new session flow).
  Future<void> load() async {
    emit(const WorkoutLoggerLoading());
    final result = await _getActive();
    if (result.isSuccess && result.dataOrNull != null) {
      emit(WorkoutLoggerActive(result.dataOrNull!));
    } else {
      emit(const WorkoutLoggerIdle());
    }
  }

  // ─── Start ─────────────────────────────────────────────────
  Future<void> startSession(String name, {PlanDay? planDay}) async {
    // لو عندنا خطة — نحوّل تمارين اليوم لـ SessionExercise تلقائياً
    final exercises = planDay != null
        ? planDay.exercises
        .map((pe) => SessionExercise(
      exerciseId:
      '${pe.exerciseId}_${DateTime.now().millisecondsSinceEpoch}',
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
    await _save(session);
    emit(WorkoutLoggerActive(session));
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
  Future<void> finishSession() async {
    final current = _active;
    if (current == null) return;

    final finished = current.copyWith(
      endTime: DateTime.now(),
      caloriesBurned: current.durationMinutes * 5.0,
    );

    await _save(finished);

    // سجّل في Progress feature
    await _logWorkout(WorkoutLog(
      id: finished.id,
      name: finished.name,
      date: finished.startTime,
      durationMinutes: finished.durationMinutes,
      caloriesBurned: finished.caloriesBurned,
      exerciseCount: finished.exercises.length,
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

  // ─── Exercise Library ──────────────────────────────────────

  /// جلب كل التمارين للعرض في الـ sheet
  Future<List<Exercise>> browseExercises() async {
    final result = await _getExercises(limit: 300, offset: 0);
    return result.fold(
      onFailure: (_) => [],
      onSuccess: (list) => list,
    );
  }

  /// بحث في مكتبة التمارين
  Future<List<Exercise>> searchLibrary(String query) async {
    if (query.trim().isEmpty) return browseExercises();
    final result = await _searchExercises(query.trim());
    return result.fold(
      onFailure: (_) => [],
      onSuccess: (list) => list,
    );
  }

  // ─── Helpers ───────────────────────────────────────────────
  WorkoutSession? get _active => state is WorkoutLoggerActive
      ? (state as WorkoutLoggerActive).session
      : null;

  Future<void> _updateActive(WorkoutSession session) async {
    await _save(session);
    emit(WorkoutLoggerActive(session));
  }
}
