import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/ui/components/pp_button.dart';
import '../data/repo/workout_completion_repository.dart';
import '../logic/cubit/workout_completion_cubit.dart';
import '../logic/cubit/workout_completion_state.dart';

class WorkoutCompletionScreen extends StatelessWidget {
  const WorkoutCompletionScreen({
    super.key,
    required this.muscleGroup,
    required this.exerciseCount,
    required this.durationMinutes,
    this.systemName = '',
  });

  final String muscleGroup;
  final int exerciseCount;
  final int durationMinutes;
  final String systemName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WorkoutCompletionCubit(
        WorkoutCompletionRepositoryImpl(GetIt.instance<UserProfileService>()),
      )..recordCompletion(),
      child: _CompletionBody(
        muscleGroup: muscleGroup,
        exerciseCount: exerciseCount,
        durationMinutes: durationMinutes,
        systemName: systemName,
      ),
    );
  }
}

class _CompletionBody extends StatelessWidget {
  const _CompletionBody({
    required this.muscleGroup,
    required this.exerciseCount,
    required this.durationMinutes,
    required this.systemName,
  });

  final String muscleGroup, systemName;
  final int exerciseCount, durationMinutes;

  @override
  Widget build(BuildContext context) {
    return BlocListener<WorkoutCompletionCubit, WorkoutCompletionState>(
      listener: (context, state) {
        if (state is WorkoutCompletionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, textDirection: TextDirection.rtl),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Medal icon ─────────────────────────────────────────
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.success.withOpacity(0.35), width: 2),
                  ),
                  child: const Icon(Icons.emoji_events_rounded,
                      color: AppColors.success, size: 52),
                ),
                const SizedBox(height: AppSpacing.md),

                Text('أحسنت!',
                    style: AppTextStyles.headlineHero,
                    textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.xs),

                Text(
                  'أكملت $exerciseCount تمارين ($muscleGroup)',
                  style: AppTextStyles.bodyMuted,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatChip(
                      icon: Icons.timer_outlined,
                      label: '$durationMinutes د',
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _StatChip(
                      icon: Icons.fitness_center_rounded,
                      label: '$exerciseCount تمارين',
                      color: AppColors.success,
                    ),
                    if (systemName.isNotEmpty) ...[
                      const SizedBox(width: AppSpacing.xs),
                      _StatChip(
                        icon: Icons.category_rounded,
                        label: systemName,
                        color: AppColors.warning,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                BlocBuilder<WorkoutCompletionCubit, WorkoutCompletionState>(
                  builder: (context, state) => PpButton(
                    label: 'تم',
                    icon: Icons.check_rounded,
                    isLoading: state is WorkoutCompletionSaving,
                    onPressed: state is WorkoutCompletionSaving
                        ? null
                        : () =>
                            Navigator.of(context).popUntil((r) => r.isFirst),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(label,
              style:
                  AppTextStyles.labelCaps.copyWith(color: color, fontSize: 11)),
        ]),
      );
}
