import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// Stats Row — بطاقتين: السعرات + وقت النشاط
/// Design v2: بطاقة بيضاء + بطاقة داكنة جنب بعض
class StatsRow extends StatelessWidget {
  const StatsRow({
    super.key,
    required this.caloriesBurned,
    required this.activeMinutes,
  });

  final int caloriesBurned;
  final int activeMinutes;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ─── السعرات — بطاقة بيضاء ────────────────────────
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spaceL),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(AppConstants.radiusXL),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('السعرات المحروقة',
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
                const SizedBox(height: 4),
                Text(
                  caloriesBurned.toString(),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    height: 1.0,
                  ),
                ),
                Text('سعرة اليوم', style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
              ],
            ),
          ),
        ),

        const SizedBox(width: AppConstants.spaceM),

        // ─── وقت النشاط — بطاقة داكنة ────────────────────
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spaceL),
            decoration: BoxDecoration(
              color: AppColors.bgDark,
              borderRadius: BorderRadius.circular(AppConstants.radiusXL),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('وقت النشاط',
                    style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 10, color: AppColors.textMuted)),
                const SizedBox(height: 4),
                Text(
                  activeMinutes.toString(),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.accent,
                    height: 1.0,
                  ),
                ),
                Text('دقيقة اليوم',
                    style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
