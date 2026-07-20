import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/pp_badge.dart';
import '../../data/models/exercise_entity.dart';

/// ExerciseCard — ✅ RTL مطابق للصورة
/// صورة يسار | نص يمين | سهم ← يسار
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
    final displayName      = exercise.nameAr.isNotEmpty ? exercise.nameAr : exercise.name;
    final displayEquipment = exercise.equipmentAr.isNotEmpty ? exercise.equipmentAr : exercise.equipment;
    final displayBodyPart  = exercise.bodyPartAr.isNotEmpty ? exercise.bodyPartAr : exercise.bodyPart;
    final displayTarget    = exercise.targetAr.isNotEmpty ? exercise.targetAr : exercise.target;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceM),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          // ✅ بدون border — مطابق الصورة (بطاقات نظيفة)
        ),
        child: Row(
          children: [

            // ✅ سهم يسار (في RTL يكون ← يشير للتفاصيل)
            const Icon(
              Icons.arrow_forward_ios_rounded,  // ✅ ← اتجاه RTL
              color: AppColors.textMuted,
              size: 14,
            ),
            const SizedBox(width: AppConstants.spaceS),

            // ✅ المعلومات في المنتصف — نص يمين
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end, // ✅ start = يمين في RTL
                children: [
                  Text(
                    displayName,
                    style: AppTextStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.spaceXS),
                  Text(
                    displayEquipment,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.spaceS),
                  // ✅ الـ badges من اليمين
                  Wrap(
                    spacing: AppConstants.spaceXS,
                    children: [
                      MuscleGroupBadge(
                        muscle: displayBodyPart,
                        size: PPBadgeSize.small,
                      ),
                      PPBadge(
                        label: displayTarget,
                        color: AppColors.textMuted,
                        size: PPBadgeSize.small,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppConstants.spaceM),

            // ✅ الصورة يسار (في RTL يظهر على اليسار)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              child: SizedBox(
                width: AppConstants.exerciseThumb,
                height: AppConstants.exerciseThumb,
                child: CachedNetworkImage(
                  imageUrl: exercise.gifUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppColors.bgElevated,
                    child: const Icon(Icons.fitness_center,
                        color: AppColors.textMuted, size: 24),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.bgElevated,
                    child: const Icon(Icons.fitness_center,
                        color: AppColors.textMuted, size: 24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
