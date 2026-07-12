import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class QuickStatsRow extends StatelessWidget {
  const QuickStatsRow({
    super.key,
    required this.weeklyWorkouts,
    required this.todayMinutes,
    required this.hasWorkedOutToday,
  });

  final int weeklyWorkouts;
  final int todayMinutes;
  final bool hasWorkedOutToday;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.fitness_center_rounded,
            iconColor: AppColors.accent,
            value: weeklyWorkouts.toString(),
            label: 'تمارين هذا الأسبوع',
          ),
        ),
        const SizedBox(width: AppConstants.spaceM),
        Expanded(
          child: _StatCard(
            icon: Icons.timer_rounded,
            iconColor: hasWorkedOutToday ? AppColors.success : AppColors.textMuted,
            value: hasWorkedOutToday ? '${todayMinutes}د' : '--',
            label: 'تمرين اليوم',
            sub: hasWorkedOutToday ? 'رائع! 🔥' : 'لم تتمرن بعد',
            subColor: hasWorkedOutToday ? AppColors.success : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.sub,
    this.subColor,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String? sub;
  final Color? subColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceL),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
            ),
            child: Icon(icon, color: iconColor, size: AppConstants.iconS),
          ),
          const SizedBox(height: AppConstants.spaceM),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              height: 1.0,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXS),
          Text(label, style: AppTextStyles.bodySmall),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(
              sub!,
              style: AppTextStyles.labelSmall
                  .copyWith(color: subColor ?? AppColors.accent),
            ),
          ],
        ],
      ),
    );
  }
}
