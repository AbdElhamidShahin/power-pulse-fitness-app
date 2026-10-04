import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_theme_colors.dart';
import '../../data/models/food_entity.dart';

class FoodSearchCard extends StatelessWidget {
  const FoodSearchCard({
    super.key,
    required this.item,
    required this.onAdd,
  });

  final FoodItem item;
  final VoidCallback onAdd;

  // Emoji icon based on food category
  String get _emoji {
    final id = item.id;
    if (id.startsWith('cn_')) return '🥫';
    if (id.startsWith('mt_')) return '🥩';
    if (id.startsWith('dy_')) return '🥛';
    if (id.startsWith('gr_')) return '🌾';
    if (id.startsWith('vg_')) return '🥬';
    if (id.startsWith('sw_')) return '🍬';
    if (item.nameAr.contains('سمك') || item.nameAr.contains('سمكة')) return '🐟';
    if (item.nameAr.contains('فراخ') || item.nameAr.contains('دجاج')) return '🍗';
    if (item.nameAr.contains('أرز') || item.nameAr.contains('رز')) return '🍚';
    if (item.nameAr.contains('خبز') || item.nameAr.contains('عيش')) return '🍞';
    return '🍽️';
  }

  @override
  Widget build(BuildContext context) {
    final displayName = item.displayName;
    final hasArabicName = item.nameAr.trim().isNotEmpty;
    final subName = hasArabicName && item.name.isNotEmpty && item.name != displayName
        ? item.name
        : item.brand;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onAdd,
        borderRadius: BorderRadius.circular(AppConstants.radiusL.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: context.colors.bgSurface,
            borderRadius: BorderRadius.circular(AppConstants.radiusL.r),
            border: Border.all(color: context.colors.borderSubtle),
          ),
          child: Row(
            children: [
              // ─── Food Emoji ──────────────────────────────
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM.r),
                ),
                child: Center(
                  child: Text(_emoji, style: TextStyle(fontSize: 22.sp)),
                ),
              ),
              SizedBox(width: 12.w),

              // ─── Names & Macros ──────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Arabic name (primary)
                    Text(
                      displayName,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: context.colors.textPrimary,
                        fontSize: 14.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subName != null && subName.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subName,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: context.colors.textMuted,
                          fontSize: 10.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: 6.h),

                    // ─── Macros ──────────────────────────────
                    Row(
                      children: [
                        _MacroChip(
                          '${item.calories.toInt()} سعر',
                          AppColors.warning,
                        ),
                        SizedBox(width: 5.w),
                        _MacroChip(
                          'بروتين ${item.protein.toStringAsFixed(1)}',
                          AppColors.info,
                        ),
                        SizedBox(width: 5.w),
                        _MacroChip(
                          '${item.servingSize.toInt()}${item.servingUnit}',
                          context.colors.textMuted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ─── Add Button ──────────────────────────────
              SizedBox(width: 8.w),
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM.r),
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: AppColors.textOnAccent,
                  size: 18.r,
                ),
              ),
            ],
          ),
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
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppConstants.radiusXS.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 9.sp,
          fontWeight: FontWeight.w600,
          color: color == context.colors.textMuted ? color : color,
        ),
      ),
    );
  }
}
