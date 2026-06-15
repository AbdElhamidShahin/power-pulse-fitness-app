import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class PpNumberInput extends StatelessWidget {
  const PpNumberInput({
    super.key,
    required this.label,
    this.hint,
    this.suffix,
    this.onChanged,
    this.controller,
    this.validator,
  });

  final String label;
  final String? hint;
  final String? suffix;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          validator: validator,
          textAlign: TextAlign.end,
          textDirection: TextDirection.rtl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          style: AppTextStyles.bodyLg,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMuted,
            suffixText: suffix,
            suffixStyle: AppTextStyles.labelMuted,
          ),
        ),
      ],
    );
  }
}
