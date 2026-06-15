import 'package:flutter/material.dart';

import '../../../../core/services/user_profile_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../repo/data/home_data.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({super.key, required this.data});
  final HomeData data;

  @override
  Widget build(BuildContext context) {
    final color = data.atRisk
        ? AppColors.warning
        : data.trainedToday
        ? AppColors.success
        : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPaddingLg,
          vertical: AppSpacing.cardPaddingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.atRisk)
                  Text('سلسلتك على المحك',
                      style: AppTextStyles.labelCaps.copyWith(
                          color: AppColors.warning,
                          fontSize: 10,
                          letterSpacing: 1.5))
                else
                  Text(
                    data.trainedToday ? 'تدربت اليوم' : 'السلسلة الحالية',
                    style: AppTextStyles.labelMuted,
                  ),
                const SizedBox(height: 4),
                Text(
                  UserProfileService.streakMessage(data.streak,
                      atRisk: data.atRisk),
                  style: AppTextStyles.headingSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${data.streak}',
                  style: AppTextStyles.displayHero.copyWith(color: color)),
              Text(UserProfileService.streakDayLabel(data.streak),
                  style: AppTextStyles.labelMuted),
            ],
          ),
        ],
      ),
    );
  }
}