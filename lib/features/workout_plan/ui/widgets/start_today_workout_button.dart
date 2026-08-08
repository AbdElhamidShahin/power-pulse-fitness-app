import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/pp_button.dart';
import '../../../exercises/data/models/exercise_entity.dart';
import '../../../exercises/logic/cubit/exercises_cubit.dart';
import '../../data/models/workout_plan_entity.dart';
import '../../logic/cubit/workout_plan_cubit.dart';
import '../../logic/cubit/workout_plan_state.dart';

class StartTodayWorkoutButton extends StatelessWidget {
  const StartTodayWorkoutButton({required this.draft});
  final WorkoutPlan draft;

  @override
  Widget build(BuildContext context) {
    final today = draft.dayFor(DateTime.now());
    final hasWorkout =
        today != null && !today.isRest && today.exercises.isNotEmpty;

    if (!hasWorkout) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.push(AppRouter.workoutLogger),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.accentDim,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(color: AppColors.accent, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded,
                color: AppColors.accent, size: 22),
            const SizedBox(width: 8),
            Text(
              'ابدأ تمرين اليوم',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.accent),
            ),
            if (today != null && today.name.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                '— ${today.name}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.accent.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
