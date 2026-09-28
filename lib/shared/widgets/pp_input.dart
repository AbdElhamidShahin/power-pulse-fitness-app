import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';

/// Search Bar
class PPSearchBar extends StatelessWidget {
  const PPSearchBar({
    super.key,
    required this.hint,
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: readOnly ? onTap : null,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            const SizedBox(width: AppConstants.spaceL),
            const Icon(Icons.search_rounded, color: AppColors.textMuted, size: AppConstants.iconM),
            const SizedBox(width: AppConstants.spaceM),
            Expanded(
              child: readOnly
                  ? Text(hint, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted))
                  : TextField(
                      controller: controller,
                      onChanged: onChanged,
                      autofocus: autofocus,
                      style: AppTextStyles.bodyMedium,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        filled: false,
                      ),
                    ),
            ),
            const SizedBox(width: AppConstants.spaceL),
          ],
        ),
      ),
    );
  }
}

/// Input Field عام
class PPTextField extends StatelessWidget {
  const PPTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.onChanged,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines = 1,
    this.enabled = true,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int maxLines;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.labelMedium),
          const SizedBox(height: AppConstants.spaceS),
        ],
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          enabled: enabled,
          textDirection: TextDirection.rtl,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
          ),
        ),
      ],
    );
  }
}

/// Progress Bar مخصصة
class PPProgressBar extends StatelessWidget {
  const PPProgressBar({
    super.key,
    required this.value,
    this.color,
    this.height = 5.0,
    this.backgroundColor,
  });

  /// 0.0 → 1.0
  final double value;
  final Color? color;
  final double height;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusPill),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        color: color ?? AppColors.accent,
        backgroundColor: backgroundColor ?? AppColors.bgElevated,
      ),
    );
  }
}
