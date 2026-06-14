import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import 'progress_ring.dart';

/// Bento-style stat card with progress ring
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.progress,
    required this.colors,
    this.iconColor,
  });

  final IconData icon;
  final String value, label;
  final double progress;
  final List<Color> colors;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProgressRing(
            progress: progress,
            size: 72,
            strokeWidth: 6,
            colors: colors,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: iconColor ?? AppColors.primary, size: 16),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.labelCaps.copyWith(fontSize: 10, color: AppColors.textPrimary)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: AppTextStyles.labelMuted, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
