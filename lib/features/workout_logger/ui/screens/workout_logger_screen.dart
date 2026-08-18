import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/pp_button.dart';
import '../../../workout_plan/data/models/workout_plan_entity.dart';
import '../../../workout_plan/logic/cubit/workout_plan_cubit.dart';
import '../../../workout_plan/logic/cubit/workout_plan_state.dart';
import '../../data/models/workout_session_entity.dart';
import '../../logic/cubit/workout_logger_cubit.dart';
import '../../logic/cubit/workout_logger_state.dart';
import '../widgets/active_workout_header.dart';
import '../widgets/add_exercise_sheet.dart';
import '../widgets/set_row_widget.dart';
import '../widgets/workout_summary_sheet.dart';

class WorkoutLoggerScreen extends StatefulWidget {
  const WorkoutLoggerScreen({super.key});

  @override
  State<WorkoutLoggerScreen> createState() => _WorkoutLoggerScreenState();
}

class _WorkoutLoggerScreenState extends State<WorkoutLoggerScreen> {
  @override
  void initState() {
    super.initState();
    // نبدأ الجلسة مباشرة مع تمارين اليوم من الخطة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startWithPlan();
    });
  }

  Future<void> _startWithPlan() async {
    final cubit = context.read<WorkoutLoggerCubit>();

    // Load — may restore an interrupted session saved before the app was killed.
    await cubit.load();
    if (!mounted) return;

    // If an interrupted session was restored, ask the user whether to resume
    // or discard it and start fresh.
    if (cubit.state is WorkoutLoggerActive) {
      final resume = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'استئناف التمرين؟',
            style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
          ),
          content: const Text(
            'لديك تمرين لم تكمله. هل تريد الاستمرار أم البدء من جديد؟',
            style: TextStyle(fontFamily: 'Cairo', color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'ابدأ من جديد',
                style: TextStyle(fontFamily: 'Cairo', color: Colors.redAccent),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'استئناف',
                style: TextStyle(fontFamily: 'Cairo', color: Color(0xFFBFFF00)),
              ),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (resume == false) {
        // Discard the saved session; then fall through to start a new one.
        await cubit.cancelSession();
        if (!mounted) return;
      } else {
        // Resume — session is already active, nothing more to do.
        return;
      }
    }

    // لو الحالة Idle — ابدأ جلسة جديدة بتمارين اليوم
    if (cubit.state is WorkoutLoggerIdle) {
      final planState = context.read<WorkoutPlanCubit>().state;
      WorkoutPlan? plan;
      if (planState is WorkoutPlanLoaded) plan = planState.plan;
      if (planState is WorkoutPlanEditing) plan = planState.draft;

      final todayPlan = plan?.dayFor(DateTime.now());
      final name =
          (todayPlan != null && !todayPlan.isRest && todayPlan.name.isNotEmpty)
              ? todayPlan.name
              : 'تمريني اليوم';

      await cubit.startSession(
        name,
        planDay: (todayPlan != null && !todayPlan.isRest) ? todayPlan : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutLoggerCubit, WorkoutLoggerState>(
      listener: (context, state) {
        if (state is WorkoutLoggerFinished) {
          _showSummarySheet(context, state.session);
        }
      },
      builder: (context, state) => switch (state) {
        WorkoutLoggerInitial() ||
        WorkoutLoggerLoading() ||
        WorkoutLoggerIdle() =>
          const _LoadingView(),
        WorkoutLoggerActive(session: final s) => _ActiveView(session: s),
        WorkoutLoggerFinished() => const _LoadingView(),
        WorkoutLoggerError(message: final m) => _ErrorView(message: m),
      },
    );
  }

  void _showSummarySheet(BuildContext context, WorkoutSession session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXXL)),
      ),
      builder: (_) => WorkoutSummarySheet(session: session),
    ).then((_) => context.read<WorkoutLoggerCubit>().reset());
  }
}

// ─── Active Session ────────────────────────────────────────────
class _ActiveView extends StatelessWidget {
  const _ActiveView({required this.session});
  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkoutLoggerCubit>();
    final done = session.exercises.where((e) => e.isFullyDone).length;
    final total = session.exercises.length;
    final progress = total == 0 ? 0.0 : done / total;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ───────────────────────────────────
            ActiveWorkoutHeader(
              session: session,
              onCancel: cubit.cancelSession,
            ),
            // ─── Progress Bar ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(AppConstants.screenPaddingH, 0,
                  AppConstants.screenPaddingH, AppConstants.spaceM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('التمارين',
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.textMuted)),
                      Text('$done / $total',
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.accent)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusPill),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.bgElevated,
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.accent),
                    ),
                  ),
                ],
              ),
            ),
            // ─── Exercise List ─────────────────────────────
            Expanded(
              child: session.exercises.isEmpty
                  ? _EmptyExercises(
                      onAdd: () => _showAddExercise(context, cubit))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                          AppConstants.screenPaddingH,
                          0,
                          AppConstants.screenPaddingH,
                          100),
                      itemCount: session.exercises.length,
                      itemBuilder: (_, i) {
                        final ex = session.exercises[i];
                        return _ExerciseTile(
                          exercise: ex,
                          onTap: () => _showExerciseDetail(context, cubit, ex),
                          onDone: () => cubit.markExerciseDone(ex.exerciseId),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: WorkoutBottomBar(
        session: session,
        onAddExercise: () => _showAddExercise(context, cubit),
        onFinish: cubit.finishSession,
      ),
    );
  }

  void _showAddExercise(BuildContext context, WorkoutLoggerCubit cubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXXL)),
      ),
      builder: (_) => AddExerciseSheet(
        cubit: cubit,
        onAdd: (exercise) {
          cubit.addExercise(exercise);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showExerciseDetail(
      BuildContext context, WorkoutLoggerCubit cubit, SessionExercise ex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXXL)),
      ),
      builder: (_) => _ExerciseDetailSheet(cubit: cubit, exercise: ex),
    );
  }
}

// ─── Exercise Tile ────────────────────────────────────────────────
class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({
    required this.exercise,
    required this.onTap,
    required this.onDone,
  });
  final SessionExercise exercise;
  final VoidCallback onTap;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final done = exercise.isFullyDone;
    return GestureDetector(
      onTap: done ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: AppConstants.spaceM),
        padding: const EdgeInsets.all(AppConstants.spaceM),
        decoration: BoxDecoration(
          color: done ? AppColors.accentDim : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          border: Border.all(
            color: done ? AppColors.accent : AppColors.borderSubtle,
            width: done ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            // صورة التمرين
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              child: SizedBox(
                width: 56,
                height: 56,
                child: exercise.gifPath != null && exercise.gifPath!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: exercise.gifPath!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppColors.bgElevated,
                          child: const Icon(Icons.fitness_center_rounded,
                              color: AppColors.textMuted, size: 24),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.bgElevated,
                          child: const Icon(Icons.fitness_center_rounded,
                              color: AppColors.textMuted, size: 24),
                        ),
                      )
                    : Container(
                        color: AppColors.bgElevated,
                        child: const Icon(Icons.fitness_center_rounded,
                            color: AppColors.textMuted, size: 24),
                      ),
              ),
            ),
            const SizedBox(width: AppConstants.spaceM),
            // اسم + تفاصيل
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.exerciseName,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(
                    done
                        ? '✓ مكتمل'
                        : '${exercise.sets.length} سيتات · اضغط للتفاصيل',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: done ? AppColors.accent : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            // زرار الحالة
            if (done)
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppColors.textOnAccent, size: 20),
              )
            else
              const Icon(Icons.chevron_left_rounded,
                  color: AppColors.textMuted, size: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Exercise Detail Sheet ────────────────────────────────────────
class _ExerciseDetailSheet extends StatefulWidget {
  const _ExerciseDetailSheet({
    required this.cubit,
    required this.exercise,
  });
  final WorkoutLoggerCubit cubit;
  final SessionExercise exercise;

  @override
  State<_ExerciseDetailSheet> createState() => _ExerciseDetailSheetState();
}

class _ExerciseDetailSheetState extends State<_ExerciseDetailSheet> {
  late SessionExercise _ex;

  @override
  void initState() {
    super.initState();
    _ex = widget.exercise;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scroll) => Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppConstants.spaceM),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderMedium,
              borderRadius: BorderRadius.circular(AppConstants.radiusPill),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(
                AppConstants.screenPaddingH,
                AppConstants.spaceM,
                AppConstants.screenPaddingH,
                AppConstants.spaceXXL,
              ),
              children: [
                // صورة GIF
                if (_ex.gifPath != null && _ex.gifPath!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    child: CachedNetworkImage(
                      imageUrl: _ex.gifPath!,
                      height: 200,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => Container(
                        height: 200,
                        color: AppColors.bgElevated,
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.accent),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        height: 120,
                        color: AppColors.bgElevated,
                        child: const Icon(Icons.fitness_center_rounded,
                            color: AppColors.textMuted, size: 48),
                      ),
                    ),
                  ),
                const SizedBox(height: AppConstants.spaceL),
                // اسم + bodyPart
                Text(_ex.exerciseName,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    )),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accentDim,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusPill),
                  ),
                  child: Text(_ex.bodyPart,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.accent)),
                ),
                const SizedBox(height: AppConstants.spaceXL),
                // Sets
                Text('المجموعات',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.textMuted)),
                const SizedBox(height: AppConstants.spaceS),
                ..._ex.sets.asMap().entries.map((entry) {
                  final i = entry.key;
                  final set = entry.value;
                  return SetRowWidget(
                    key: ValueKey('${_ex.exerciseId}_$i'),
                    exerciseSet: set,
                    exerciseId: _ex.exerciseId,
                    onUpdate: (
                        {required exerciseId,
                        required setIndex,
                        int? reps,
                        double? weight,
                        bool? isCompleted}) {
                      // نحدّث محلياً في الـ sheet
                      final newSets = List<ExerciseSet>.from(_ex.sets);
                      newSets[setIndex] = ExerciseSet(
                        setNumber: set.setNumber,
                        reps: reps ?? set.reps,
                        weight: weight ?? set.weight,
                        isCompleted: isCompleted ?? set.isCompleted,
                      );
                      setState(() {
                        _ex = _ex.copyWith(sets: newSets);
                      });
                      widget.cubit.updateSet(
                        exerciseId: exerciseId,
                        setIndex: setIndex,
                        reps: reps,
                        weight: weight,
                        isCompleted: isCompleted,
                      );
                    },
                    onRemove: () {
                      widget.cubit.removeSet(_ex.exerciseId, i);
                      if (_ex.sets.length > 1) {
                        setState(() {
                          final newSets = List<ExerciseSet>.from(_ex.sets)
                            ..removeAt(i);
                          _ex = _ex.copyWith(sets: newSets);
                        });
                      }
                    },
                  );
                }),
                // زرار إضافة مجموعة
                GestureDetector(
                  onTap: () {
                    widget.cubit.addSet(_ex.exerciseId);
                    setState(() {
                      _ex = _ex.copyWith(sets: [
                        ..._ex.sets,
                        ExerciseSet(
                          setNumber: _ex.sets.length + 1,
                          reps: _ex.sets.last.reps,
                        ),
                      ]);
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: AppConstants.spaceS),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.bgElevated,
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_rounded,
                            color: AppColors.textMuted, size: 16),
                        const SizedBox(width: 4),
                        Text('+ مجموعة',
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spaceXXL),
                // زرار "خلصت التمرين ده"
                ElevatedButton(
                  onPressed: () {
                    widget.cubit.markExerciseDone(_ex.exerciseId);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    minimumSize: const Size(
                        double.infinity, AppConstants.buttonHeightLarge),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    ),
                  ),
                  child: Text('✓ خلصت هذا التمرين',
                      style: AppTextStyles.labelLarge
                          .copyWith(color: AppColors.textOnAccent)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Loading ────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: AppColors.bgDeep,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
}

// ─── Error ──────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.bgDeep,
        body: Center(
          child: Text(message, style: AppTextStyles.bodyMedium),
        ),
      );
}

// ─── Empty Exercises ────────────────────────────────────────────
class _EmptyExercises extends StatelessWidget {
  const _EmptyExercises({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add_circle_outline_rounded,
              color: AppColors.textMuted, size: 56),
          const SizedBox(height: AppConstants.spaceL),
          Text('لا يوجد تمارين بعد',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppConstants.spaceS),
          Text('اضغط "إضافة تمرين" للبدء', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppConstants.spaceXXL),
          PPButton(
            label: '+ إضافة أول تمرين',
            size: PPButtonSize.medium,
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}
