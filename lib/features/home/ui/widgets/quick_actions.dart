import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('الوصول السريع',
                style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
        const SizedBox(height: AppConstants.spaceM),
        // Row 1 — Exercises (big) + Nutrition (big)
        Row(
          children: [
            Expanded(
              child: _BigActionCard(
                icon: Icons.fitness_center_rounded,
                label: 'التمارين',
                sublabel: 'اكتشف تمارين جديدة',
                color: AppColors.accent,
                onTap: () => context.go('/exercises'),
              ),
            ),
            const SizedBox(width: AppConstants.spaceM),
            Expanded(
              child: _BigActionCard(
                icon: Icons.restaurant_rounded,
                label: 'التغذية',
                sublabel: 'تتبع وجباتك',
                color: AppColors.info,
                onTap: () => context.go('/nutrition'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spaceM),
        // Row 2 — Progress + Workout Logger (big CTA)
        Row(
          children: [
            Expanded(
              child: _SmallActionCard(
                icon: Icons.bar_chart_rounded,
                label: 'التقدم',
                color: AppColors.warning,
                onTap: () => context.go('/progress'),
              ),
            ),
            const SizedBox(width: AppConstants.spaceM),
            Expanded(
              child: _SmallActionCard(
                icon: Icons.add_circle_rounded,
                label: 'تسجيل تمرين',
                color: AppColors.success,
                onTap: () => context.go('/workout-logger'),
              ),
            ),
            const SizedBox(width: AppConstants.spaceM),
            Expanded(
              child: _SmallActionCard(
                icon: Icons.person_rounded,
                label: 'الملف',
                color: AppColors.muscleArms,
                onTap: () => context.go('/profile'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BigActionCard extends StatelessWidget {
  const _BigActionCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceL),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Icon(icon, color: color, size: AppConstants.iconL),
            ),
            const SizedBox(height: AppConstants.spaceM),
            Text(label,
                style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(sublabel, style: AppTextStyles.bodySmall, maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _SmallActionCard extends StatelessWidget {
  const _SmallActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spaceL,
          horizontal: AppConstants.spaceS,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: AppConstants.iconL),
            const SizedBox(height: AppConstants.spaceS),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(color: color),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
