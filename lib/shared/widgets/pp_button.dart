import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';

enum PPButtonVariant { primary, outline, ghost }
enum PPButtonSize { large, medium, small }

/// الزرار الأساسي في Power Pulse
class PPButton extends StatelessWidget {
  const PPButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PPButtonVariant.primary,
    this.size = PPButtonSize.large,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final PPButtonVariant variant;
  final PPButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final double? width;

  double get _height => switch (size) {
        PPButtonSize.large  => AppConstants.buttonHeightLarge,
        PPButtonSize.medium => AppConstants.buttonHeightMedium,
        PPButtonSize.small  => AppConstants.buttonHeightSmall,
      };

  @override
  Widget build(BuildContext context) {
    final bool disabled = isDisabled || isLoading;

    return SizedBox(
      height: _height,
      width: width ?? double.infinity,
      child: switch (variant) {
        PPButtonVariant.primary => _PrimaryButton(
            label: label, onPressed: disabled ? null : onPressed,
            icon: icon, isLoading: isLoading, size: size,
          ),
        PPButtonVariant.outline => _OutlineButton(
            label: label, onPressed: disabled ? null : onPressed,
            icon: icon, isLoading: isLoading, size: size,
          ),
        PPButtonVariant.ghost => _GhostButton(
            label: label, onPressed: disabled ? null : onPressed,
            icon: icon, size: size,
          ),
      },
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label, required this.onPressed,
    required this.isLoading, required this.size, this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final PPButtonSize size;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed == null ? AppColors.bgElevated : AppColors.accent,
        foregroundColor: onPressed == null ? AppColors.textMuted : AppColors.textOnAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        elevation: 0,
        padding: EdgeInsets.zero,
      ),
      child: isLoading
          ? const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textOnAccent),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: AppConstants.iconS),
                  const SizedBox(width: AppConstants.spaceS),
                ],
                Text(label, style: AppTextStyles.labelLarge.copyWith(
                  color: onPressed == null ? AppColors.textMuted : AppColors.textOnAccent,
                )),
              ],
            ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.label, required this.onPressed,
    required this.isLoading, required this.size, this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final PPButtonSize size;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accent,
        side: BorderSide(
          color: onPressed == null ? AppColors.borderSubtle : AppColors.accent,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        padding: EdgeInsets.zero,
      ),
      child: isLoading
          ? const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: AppConstants.iconS),
                  const SizedBox(width: AppConstants.spaceS),
                ],
                Text(label, style: AppTextStyles.labelLarge.copyWith(color: AppColors.accent)),
              ],
            ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.label, required this.onPressed,
    required this.size, this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final PPButtonSize size;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        padding: EdgeInsets.zero,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppConstants.iconS),
            const SizedBox(width: AppConstants.spaceS),
          ],
          Text(label, style: AppTextStyles.labelLarge.copyWith(color: AppColors.accent)),
        ],
      ),
    );
  }
}
