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
    this.currentStreak = 0,
  });

  final int weeklyWorkouts;
  final int todayMinutes;
  final bool hasWorkedOutToday;
  final int currentStreak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Streak
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department_rounded,
            iconColor: AppColors.warning,
            value: currentStreak.toString(),
            label: 'يوم متتالي',
            unit: '🔥',
            bgColor: AppColors.warningDim,
          ),
        ),
        const SizedBox(width: AppConstants.spaceM),
        // Weekly workouts
        Expanded(
          child: _StatCard(
            icon: Icons.fitness_center_rounded,
            iconColor: AppColors.accent,
            value: weeklyWorkouts.toString(),
            label: 'تمرين أسبوعي',
            bgColor: AppColors.accentDim,
          ),
        ),
        const SizedBox(width: AppConstants.spaceM),
        // Today minutes
        Expanded(
          child: _StatCard(
            icon: Icons.timer_rounded,
            iconColor: hasWorkedOutToday
                ? AppColors.success
                : AppColors.textMuted,
            value: hasWorkedOutToday ? todayMinutes.toString() : '--',
            label: 'دقيقة اليوم',
            bgColor: hasWorkedOutToday
                ? AppColors.successDim
                : AppColors.bgElevated,
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
    required this.bgColor,
    this.unit,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Color bgColor;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceM,
        vertical: AppConstants.spaceL,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
            ),
            child: Icon(icon, color: iconColor, size: AppConstants.iconS),
          ),
          const SizedBox(height: AppConstants.spaceM),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1.0,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(unit!, style: const TextStyle(fontSize: 14)),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppConstants.spaceXS),
          Text(label, style: AppTextStyles.bodySmall,
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
