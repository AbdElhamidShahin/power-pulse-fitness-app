import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        padding: EdgeInsets.all(AppConstants.spaceM.r),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppConstants.radiusL.r),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColors.bgElevated,
                borderRadius: BorderRadius.circular(AppConstants.radiusM.r),
              ),
              child: Icon(
                Icons.restaurant_rounded,
                color: AppColors.textMuted,
                size: AppConstants.iconM.r,
              ),
            ),
            SizedBox(width: AppConstants.spaceM.w),
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
                    SizedBox(height: 2.h),
                    Text(food.brand!, style: AppTextStyles.bodySmall),
                  ],
                  SizedBox(height: AppConstants.spaceXS.h),
                  Row(
                    children: [
                      _MacroChip(
                        '${food.calories.toInt()} سعرة',
                        AppColors.accent,
                      ),
                      SizedBox(width: AppConstants.spaceXS.w),
                      _MacroChip(
                        'ب ${food.protein.toInt()}g',
                        AppColors.info,
                      ),
                      SizedBox(width: AppConstants.spaceXS.w),
                      _MacroChip(
                        'ك ${food.carbs.toInt()}g',
                        AppColors.warning,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.accent,
              size: AppConstants.iconM.r,
            ),
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
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppConstants.radiusXS.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}