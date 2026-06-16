import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/navigation_utils.dart';
import '../../features/exercises/data/model/exercise.dart';
import '../../features/exercises/views/exercise_detail_page.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({super.key, this.exercise, this.onAddPressed});
  final Exercise? exercise;
  final void Function(Exercise)? onAddPressed;

  @override
  Widget build(BuildContext context) {
    final ex = exercise;
    if (ex == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.marginMobile, vertical: 6),
      child: GestureDetector(
        onTap: () => Navigator.push(context,
            NavigationUtils.slideRightRoute(ExerciseDetailPage(exercise: ex))),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.cardBorder, width: 1),
          ),
          clipBehavior: Clip.hardEdge,
          child: Row(
            children: [
              // ── Text side (right in RTL) ─────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(ex.title,
                          style: AppTextStyles.headingSmall
                              .copyWith(color: AppColors.textPrimary),
                          textAlign: TextAlign.end,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 5),
                      Text(ex.details,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.end,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      if (onAddPressed != null) ...[
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => onAddPressed!(ex),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.primary.withOpacity(0.4)),
                              ),
                              child: const Icon(Icons.add_rounded,
                                  color: AppColors.primary, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              Hero(
                tag: 'exerciseImage_${ex.title}',
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(ex.image), fit: BoxFit.cover),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [AppColors.surface, Colors.transparent],
                            stops: const [0.0, 0.5],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
