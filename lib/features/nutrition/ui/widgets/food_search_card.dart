import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../data/models/food_entity.dart';

class FoodSearchCard extends StatelessWidget {
  const FoodSearchCard({
    super.key,
    required this.food,
    required this.onTap,
  });

  final FoodItem food;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.bgElevated,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: const Icon(Icons.restaurant_rounded,
                  color: AppColors.textMuted, size: AppConstants.iconM),
            ),
            const SizedBox(width: AppConstants.spaceM),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: AppTextStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (food.brand != null) ...[
                    const SizedBox(height: 2),
                    Text(food.brand!, style: AppTextStyles.bodySmall),
                  ],
                  const SizedBox(height: AppConstants.spaceXS),
                  // Macros
                  Row(
                    children: [
                      _MacroChip('${food.calories.toInt()} سعرة',
                          AppColors.accent),
                      const SizedBox(width: AppConstants.spaceXS),
                      _MacroChip('ب ${food.protein.toInt()}g',
                          AppColors.info),
                      const SizedBox(width: AppConstants.spaceXS),
                      _MacroChip('ك ${food.carbs.toInt()}g',
                          AppColors.warning),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(Icons.add_circle_outline_rounded,
                color: AppColors.accent, size: AppConstants.iconM),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppConstants.radiusXS),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}
