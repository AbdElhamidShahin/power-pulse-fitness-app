import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/pp_badge.dart';
import '../../data/models/exercise_entity.dart';
import '../../data/services/local_exercises_data.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onTap,
    this.onAddToWorkout,
  });

  final Exercise exercise;
  final VoidCallback onTap;
  final VoidCallback? onAddToWorkout;

  @override
  Widget build(BuildContext context) {
    final hasGif = exercise.gifUrl.isNotEmpty;
    final bodyPartAr =
        LocalExercisesData.bodyPartAr[exercise.bodyPart] ?? exercise.bodyPart;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceM),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            // ─── Thumbnail ─────────────────────────────────
// ─── Thumbnail ─────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              child: SizedBox(
                width: AppConstants.exerciseThumb,
                height: AppConstants.exerciseThumb,
                child: hasGif
                    ? CachedNetworkImage(
                        imageUrl: exercise.gifUrl,
                        fit: BoxFit.cover,
                        httpHeaders: const {
                          'User-Agent':
                              'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36',
                        },
                        placeholder: (_, __) => const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          debugPrint("Error loading image ($url): $error");
                          return _PlaceholderIcon(exercise.bodyPart);
                        },
                      )
                    : _PlaceholderIcon(exercise.bodyPart),
              ),
            ),
            const SizedBox(width: AppConstants.spaceM),

            // ─── Info ───────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: AppTextStyles.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.spaceXS),
                  Text(
                    exercise.equipment,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.spaceS),
                  Row(
                    children: [
                      _BodyPartChip(label: bodyPartAr),
                    ],
                  ),
                ],
              ),
            ),

            // ─── Actions ────────────────────────────────────
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onAddToWorkout != null) ...[
                  GestureDetector(
                    onTap: onAddToWorkout,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.accentDim,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: AppColors.accent, size: 18),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceS),
                ],
                const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: AppColors.textMuted,
                  size: AppConstants.iconXS,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderIcon extends StatelessWidget {
  const _PlaceholderIcon(this.bodyPart);
  final String bodyPart;

  IconData get _icon => switch (bodyPart.toLowerCase()) {
        'chest' => Icons.fitness_center_rounded,
        'back' => Icons.accessibility_new_rounded,
        'shoulders' => Icons.sports_gymnastics_rounded,
        'upper arms' => Icons.sports_handball_rounded,
        'upper legs' => Icons.directions_walk_rounded,
        'waist' => Icons.rotate_right_rounded,
        'cardio' => Icons.favorite_rounded,
        _ => Icons.fitness_center_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgElevated,
      child: Icon(_icon, color: AppColors.textMuted, size: 28),
    );
  }
}

class _BodyPartChip extends StatelessWidget {
  const _BodyPartChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accentDim,
        borderRadius: BorderRadius.circular(AppConstants.radiusPill),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent),
      ),
    );
  }
}
