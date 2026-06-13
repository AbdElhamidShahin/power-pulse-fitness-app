import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Legacy wrapper for backward compatibility.
/// New code should use PpButton from core/ui/components/pp_button.dart
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    this.width,
    this.height = AppSpacing.touchTarget,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String text;
  final double? width;
  final double height;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled ? const LinearGradient(colors: AppColors.actionGlow) : null,
          color: enabled ? null : AppColors.surfaceBright,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          boxShadow: enabled ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 18, offset: const Offset(0, 6))] : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            child: Center(
              child: isLoading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(AppColors.onPrimary)))
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[Icon(icon, color: AppColors.onPrimary, size: 20), const SizedBox(width: 8)],
                        Text(text, style: AppTextStyles.buttonLabel),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
