import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/ui/components/pp_card.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) => PpCard(
    borderColor: AppColors.primary.withOpacity(0.2),
    padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
    child: Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المستوى', style: AppTextStyles.labelMuted),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.12),
                borderRadius:
                BorderRadius.circular(AppSpacing.radiusFull),
                border: Border.all(
                    color: AppColors.success.withOpacity(0.3)),
              ),
              child: Text(
                'متوسط',
                style: AppTextStyles.labelCaps
                    .copyWith(color: AppColors.success),
              ),
            ),
          ],
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceHigh,
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.4), width: 2),
              ),
              child: const Icon(Icons.person_outline_rounded,
                  color: AppColors.outline, size: 28),
            ),
            const SizedBox(height: 6),
            Text('المستخدم', style: AppTextStyles.headingSmall),
            Text('Power Pulse User', style: AppTextStyles.labelMuted),
          ],
        ),
      ],
    ),
  );
}