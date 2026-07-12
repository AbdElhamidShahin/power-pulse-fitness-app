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
        Text('وصول سريع',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppConstants.spaceM),
        Row(
          children: [
            _ActionCard(
              icon: Icons.fitness_center_rounded,
              label: 'التمارين',
              color: AppColors.accent,
              onTap: () => context.go('/exercises'),
            ),
            const SizedBox(width: AppConstants.spaceM),
            _ActionCard(
              icon: Icons.restaurant_rounded,
              label: 'التغذية',
              color: AppColors.info,
              onTap: () => context.go('/nutrition'),
            ),
            const SizedBox(width: AppConstants.spaceM),
            _ActionCard(
              icon: Icons.bar_chart_rounded,
              label: 'تقدمي',
              color: AppColors.warning,
              onTap: () => context.go('/progress'),
            ),
            const SizedBox(width: AppConstants.spaceM),
            _ActionCard(
              icon: Icons.person_rounded,
              label: 'حسابي',
              color: AppColors.success,
              onTap: () => context.go('/profile'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
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
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.spaceL,
            horizontal: AppConstants.spaceS,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: AppConstants.iconL),
              const SizedBox(height: AppConstants.spaceS),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(color: color),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
