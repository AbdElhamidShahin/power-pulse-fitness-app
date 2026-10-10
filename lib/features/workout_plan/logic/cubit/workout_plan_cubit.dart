import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:power_pulse/core/domain/api_result.dart';
import '../../../../core/domain/app_failure.dart';
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

  // ─── BUGFIX: track whether save was explicitly triggered ──
  bool _isSaving = false;
  bool get isSaving => _isSaving;

  /// يحمّل الخطة مرة واحدة بس (لو لسه Initial). آمن للاستدعاء من أي شاشة.
  Future<void> ensureLoaded() async {
    if (state is WorkoutPlanInitial) await load();
  }

  /// يلغي أي تعديلات غير محفوظة (لما المستخدم يطلع من شاشة الخطة من غير حفظ)
  /// ويرجّع آخر نسخة محفوظة — عشان الرئيسية متعرضش مسودة مش محفوظة.
  Future<void> discardDraft() async {
    if (state is WorkoutPlanEditing) await load();
  }

  /// يضيف تمرين ليوم معيّن ويحفظ فوراً.
  ///
  /// BUGFIX: النسخة القديمة كانت بتنادي startEditing() و load() بالتوازي،
  /// فكانت أحياناً بتبدأ من خطة فاضية وتكتب فوق الخطة الموجودة.
  /// هنا بنستنى تحميل الخطة الحقيقية الأول وبعدين نضيف ونحفظ.
  Future<void> addExerciseAndSave(int weekday, PlanExercise exercise) async {
    final WorkoutPlan base;
    final s = state;
    if (s is WorkoutPlanLoaded) {
      base = s.plan;
    } else if (s is WorkoutPlanEditing) {
      base = s.draft;
    } else {
      final r = await _getPlan();
      base = r.dataOrNull ?? WorkoutPlan.empty();
    }

    final days = base.days.map((d) {
      if (d.weekday != weekday) return d;
      if (d.exercises.any((e) => e.exerciseId == exercise.exerciseId)) {
        return d; // موجود أصلاً
      }
      return d.copyWith(isRest: false, exercises: [...d.exercises, exercise]);
    }).toList();
    final updated = base.copyWith(days: days);

    _isSaving = true;
    final result = await _savePlan(updated);
    _isSaving = false;
    result.fold(
      onFailure: (f) => emit(WorkoutPlanError(f.userMessage)),
      onSuccess: (_) => emit(WorkoutPlanLoaded(updated)),
    );
  }

  Future<void> load() async {
    emit(const WorkoutPlanLoading());
    final result = await _getPlan();
    result.fold(
      onFailure: (f) => emit(WorkoutPlanError(f.userMessage)),
      onSuccess: (plan) => plan != null
          ? emit(WorkoutPlanLoaded(plan))
          : emit(const WorkoutPlanEmpty()),
    );
  }

  /// BUGFIX: بدل ما نفصل load و startEditing في مكانين،
  /// نعملهم في method واحدة عشان نتجنب race condition.
  Future<void> loadThenEdit() async {
    emit(const WorkoutPlanLoading());
    final result = await _getPlan();
    result.fold(
      onFailure: (_) {
        // لو فيه error، ابدأ بخطة فاضية
        emit(WorkoutPlanEditing(WorkoutPlan.empty()));
      },
      onSuccess: (plan) {
        emit(WorkoutPlanEditing(plan ?? WorkoutPlan.empty()));
      },
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

  /// BUGFIX: نستخدم _isSaving flag عشان الـ listener يعرف إيه اللي أدى لـ WorkoutPlanLoaded
  Future<void> saveDraft() async {
    final draft = _draft;
    if (draft == null) return;
    _isSaving = true;
    final result = await _savePlan(draft);
    result.fold(
      onFailure: (f) {
        _isSaving = false;
        emit(WorkoutPlanError(f.userMessage));
      },
      onSuccess: (_) {
        _isSaving = false;
        emit(WorkoutPlanLoaded(draft));
      },
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
