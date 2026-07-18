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
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('عرض الكل',
                style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600)),
            Text('الوصول السريع',
                style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
        const SizedBox(height: AppConstants.spaceM),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppConstants.spaceM,
          mainAxisSpacing: AppConstants.spaceM,
          childAspectRatio: 1.4,
          children: [
            _ActionCard(
              emoji: '🥗',
              label: 'التغذية',
              sublabel: 'تتبع وجباتك',
              bgColor: const Color(0xFFE8F5E9),
              onTap: () => context.go('/nutrition'),
            ),
            _ActionCard(
              emoji: '📈',
              label: 'تقدمي',
              sublabel: 'إحصائياتك',
              bgColor: const Color(0xFFE3F2FD),
              onTap: () => context.go('/progress'),
            ),
            _ActionCard(
              emoji: '👤',
              label: 'حسابي',
              sublabel: 'بياناتك الشخصية',
              bgColor: const Color(0xFFFFF3E0),
              onTap: () => context.go('/profile'),
            ),
            _ActionCard(
              emoji: '🏋️',
              label: 'التمارين',
              sublabel: 'استعرض المكتبة',
              bgColor: const Color(0xFFFCE4EC),
              onTap: () => context.go('/exercises'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.emoji,
    required this.label,
    required this.sublabel,
    required this.bgColor,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final String sublabel;
  final Color bgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceM),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: AppConstants.spaceXS),
            Text(label,
                style: AppTextStyles.titleMedium
                    .copyWith(color: AppColors.textPrimary),
                textAlign: TextAlign.right),
            Text(sublabel,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right),
          ],
        ),
      ),
    );
  }
}
