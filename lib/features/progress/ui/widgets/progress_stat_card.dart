import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/ui_constants.dart';

class ProgressStatCard extends StatelessWidget {
  const ProgressStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.iconColor,
    this.suffix,
    this.sub,
    this.subColor,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color? iconColor;
  final String? suffix;
  final String? sub;
  final Color? subColor;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.accent;
    return Container(
      padding: const EdgeInsets.all(UiConstants.spaceL),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(UiConstants.radiusL),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(UiConstants.radiusS),
            ),
            child: Icon(icon, color: color, size: UiConstants.iconS),
          ),
          const SizedBox(height: UiConstants.spaceM),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
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
              if (suffix != null) ...[
                const SizedBox(width: 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(suffix!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textMuted)),
                ),
              ],
            ],
          ),
          const SizedBox(height: UiConstants.spaceXS),
          Text(label, style: AppTextStyles.bodySmall),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(
              sub!,
              style: AppTextStyles.labelSmall.copyWith(
                color: subColor ?? AppColors.accent,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
