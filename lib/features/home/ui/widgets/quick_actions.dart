import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// Quick Access Grid — Design v2
/// 2×2 grid: التغذية / تقدمي / حسابي / التمارين
class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('الوصول السريع',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppConstants.spaceM),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppConstants.spaceM,
          crossAxisSpacing: AppConstants.spaceM,
          childAspectRatio: 1.4,
          children: const [
            _QuickCard(
              icon: Icons.restaurant_rounded,
              label: 'التغذية',
              sublabel: 'تتبع وجباتك',
              bg: AppColors.cardNutritionBg,
              iconColor: AppColors.success,
              route: '/nutrition',
            ),
            _QuickCard(
              icon: Icons.bar_chart_rounded,
              label: 'تقدمي',
              sublabel: 'إحصائياتك',
              bg: AppColors.cardProgressBg,
              iconColor: AppColors.info,
              route: '/progress',
            ),
            _QuickCard(
              icon: Icons.person_rounded,
              label: 'حسابي',
              sublabel: 'بياناتك الشخصية',
              bg: AppColors.cardProfileBg,
              iconColor: AppColors.warning,
              route: '/profile',
            ),
            _QuickCard(
              icon: Icons.fitness_center_rounded,
              label: 'التمارين',
              sublabel: 'استعرض المكتبة',
              bg: AppColors.cardWorkoutBg,
              iconColor: AppColors.danger,
              route: '/exercises',
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.bg,
    required this.iconColor,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final Color bg;
  final Color iconColor;
  final String route;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceM),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: AppConstants.iconL),
            const SizedBox(height: AppConstants.spaceS),
            Text(label,
                style: AppTextStyles.headlineSmall
                    .copyWith(fontSize: 14),
                maxLines: 1),
            Text(sublabel,
                style: AppTextStyles.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
