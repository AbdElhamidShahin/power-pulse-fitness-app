import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/pp_button.dart';
import '../../data/models/workout_session_entity.dart';

class WorkoutSummarySheet extends StatelessWidget {
  const WorkoutSummarySheet({super.key, required this.session});
  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spaceXXL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events_rounded,
              color: AppColors.accent, size: 56),
          const SizedBox(height: AppConstants.spaceL),
          Text('أحسنت! 💪',
              style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: AppConstants.spaceS),
          Text('انتهى تمرين "${session.name}"',
              style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppConstants.spaceXXL),

          // ─── Stats ───────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SummaryItem(
                  value: '${session.durationMinutes}',
                  unit: 'دقيقة',
                  icon: Icons.timer_rounded,
                  color: AppColors.accent),
              _SummaryItem(
                  value: session.exercises.length.toString(),
                  unit: 'تمرين',
                  icon: Icons.fitness_center_rounded,
                  color: AppColors.info),
              _SummaryItem(
                  value: session.completedSets.toString(),
                  unit: 'مجموعة',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.success),
              _SummaryItem(
                  value: session.caloriesBurned.toInt().toString(),
                  unit: 'سعرة',
                  icon: Icons.local_fire_department_rounded,
                  color: AppColors.warning),
            ],
          ),
          const SizedBox(height: AppConstants.spaceXXL),

          // ─── Exercise completion list ─────────────────────
          ...session.exercises.map((ex) {
            final done = ex.isFullyDone;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spaceS),
              child: Row(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: done ? AppColors.successDim : AppColors.bgElevated,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      done ? Icons.check_rounded : Icons.remove_rounded,
                      size: 16,
                      color: done ? AppColors.success : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceM),
                  Expanded(
                    child: Text(ex.exerciseName,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: done
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        )),
                  ),
                  Text(
                    '${ex.completedSets}/${ex.sets.length} سيت',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: AppConstants.spaceXXL),
          PPButton(
            label: 'ممتاز! 🎉',
            width: double.infinity,
            onPressed: () {
              Navigator.pop(context);    // نقفل الـ sheet
              context.go(AppRouter.home); // نرجع للـ Home عشان يتحدث
            },
          ),
          const SizedBox(height: AppConstants.spaceL),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: AppConstants.spaceXS),
        Text(value,
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary)),
        Text(unit, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
