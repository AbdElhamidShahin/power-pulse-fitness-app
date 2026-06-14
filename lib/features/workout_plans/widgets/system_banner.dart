import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// SystemBanner — descriptive header for each workout system screen.
/// Shared across PushPullLegs, FiveDaySplit, YourExersize.
class SystemBanner extends StatelessWidget {
  const SystemBanner({
    super.key,
    required this.label,
    required this.description,
    required this.color,
  });

  final String label, description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.marginMobile, 0,
        AppSpacing.marginMobile, 4,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              label,
              style: AppTextStyles.labelCaps
                  .copyWith(color: color, letterSpacing: 1.5),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),
    );
  }
}
