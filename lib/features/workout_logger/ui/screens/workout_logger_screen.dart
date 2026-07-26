import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/pp_button.dart';
import '../../data/models/workout_session_entity.dart';
import '../../logic/cubit/workout_logger_cubit.dart';
import '../../logic/cubit/workout_logger_state.dart';
import '../widgets/active_workout_header.dart';
import '../widgets/add_exercise_sheet.dart';
import '../widgets/exercise_logger_card.dart';
import '../widgets/workout_logger_idle_view.dart';
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
    context.read<WorkoutLoggerCubit>().load();
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
        WorkoutLoggerLoading() =>
          const _LoadingView(),
        WorkoutLoggerIdle() => const WorkoutLoggerIdleView(),
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

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            ActiveWorkoutHeader(
                session: session, onCancel: cubit.cancelSession),
            const Divider(color: AppColors.borderSubtle, height: 1),
            Expanded(
              child: session.exercises.isEmpty
                  ? _EmptyExercises(
                      onAdd: () => _showAddExercise(context, cubit))
                  : ListView.builder(
                      padding:
                          const EdgeInsets.all(AppConstants.screenPaddingH),
                      itemCount: session.exercises.length,
                      itemBuilder: (_, i) {
                        final ex = session.exercises[i];
                        return ExerciseLoggerCard(
                          exercise: ex,
                          onUpdateSet: (
                                  {required exerciseId,
                                  required setIndex,
                                  reps,
                                  weight,
                                  isCompleted}) =>
                              cubit.updateSet(
                            exerciseId: exerciseId,
                            setIndex: setIndex,
                            reps: reps,
                            weight: weight,
                            isCompleted: isCompleted,
                          ),
                          onAddSet: () => cubit.addSet(ex.exerciseId),
                          onRemoveSet: (idx) =>
                              cubit.removeSet(ex.exerciseId, idx),
                          onRemoveExercise: () =>
                              cubit.removeExercise(ex.exerciseId),
                        );
                      },
                    ),
            ),
            _BottomBar(
              session: session,
              onAddExercise: () => _showAddExercise(context, cubit),
              onFinish: cubit.finishSession,
            ),
          ],
        ),
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
        onExercisePicked: cubit.addExercise,
        onSearch: cubit.searchLibrary,
        onBrowse: cubit.browseExercises,
      ),
    );
  }
}

// ─── Bottom Bar ────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.session,
    required this.onAddExercise,
    required this.onFinish,
  });
  final WorkoutSession session;
  final VoidCallback onAddExercise;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.screenPaddingH,
        AppConstants.spaceL,
        AppConstants.screenPaddingH,
        AppConstants.spaceXL,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onAddExercise,
              child: Container(
                height: AppConstants.buttonHeightMedium,
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  border: Border.all(color: AppColors.borderMedium),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded,
                        color: AppColors.textMuted, size: 20),
                    const SizedBox(width: AppConstants.spaceS),
                    Text(
                      'إضافة تمرين',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spaceM),
          Expanded(
            child: PPButton(
              label: 'إنهاء التمرين ✅',
              width: double.infinity,
              onPressed: onFinish,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────
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

// ─── Helpers UI ───────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(_) => const Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Center(child: CircularProgressIndicator(color: AppColors.accent)));
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;
  @override
  Widget build(_) => Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Center(child: Text(message, style: AppTextStyles.bodyMedium)));
}
