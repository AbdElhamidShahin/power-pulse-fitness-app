import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';


class NumberInputField extends StatelessWidget {
  const NumberInputField({
    super.key,
    required this.title,
    required this.hintText,
    this.onChanged,
    this.suffix,
    this.controller,
    this.validator,
  });

  final String title, hintText;
  final String? suffix;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title, style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.base),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          validator: validator,
          textAlign: TextAlign.end,
          textDirection: TextDirection.rtl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
          style: AppTextStyles.bodyLg,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.bodyMuted,
            suffixText: suffix,
            suffixStyle: AppTextStyles.labelMuted,
          ),
        ),
      ],
    );
  }
}
