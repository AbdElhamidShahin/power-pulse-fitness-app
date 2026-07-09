import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../../core/constants/constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/pp_badge.dart';
import '../../data/models/exercise_entity.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onTap,
  });

  final Exercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(UiConstants.spaceM),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(UiConstants.radiusL),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            // ─── Thumbnail ──────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(UiConstants.radiusM),
              child: SizedBox(
                width: UiConstants.exerciseThumb,
                height: UiConstants.exerciseThumb,
                child: CachedNetworkImage(
                  imageUrl: exercise.gifUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppColors.bgElevated,
                    child: const Icon(
                      Icons.fitness_center,
                      color: AppColors.textMuted,
                      size: 24,
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.bgElevated,
                    child: const Icon(
                      Icons.fitness_center,
                      color: AppColors.textMuted,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: UiConstants.spaceM),

            // ─── Info ───────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: AppTextStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: UiConstants.spaceXS),
                  Text(
                    exercise.equipment,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: UiConstants.spaceS),
                  Row(
                    children: [
                      MuscleGroupBadge(
                        muscle: exercise.bodyPart,
                        size: PPBadgeSize.small,
                      ),
                      const SizedBox(width: UiConstants.spaceXS),
                      PPBadge(
                        label: exercise.target,
                        color: AppColors.textMuted,
                        size: PPBadgeSize.small,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: UiConstants.spaceS),
            const Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.textMuted,
              size: UiConstants.iconXS,
            ),
          ],
        ),
      ),
    );
  }
}
