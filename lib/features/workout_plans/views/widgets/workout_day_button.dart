import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../exercise_screen.dart';


class WorkoutDayButton extends StatelessWidget {
  const WorkoutDayButton({
    super.key,
    required this.titlee,
    required this.type,
    this.systemName = '',
    this.muscleGroup = '',
  });

  final String titlee;
  final String type;
  final String systemName;
  final String muscleGroup;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.marginMobile, vertical: 6),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExerciseScreen(
              currentDay:  type,
              systemName:  systemName,
              muscleGroup: muscleGroup.isNotEmpty ? muscleGroup : titlee,
            ),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: AppSpacing.sm + 2),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.fitness_center_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(titlee,
                        style: AppTextStyles.headingSmall,
                        textAlign: TextAlign.end),
                    const SizedBox(height: 3),
                    Text('اضغط لبدء التمرين',
                        style: AppTextStyles.labelMuted),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.outline, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
