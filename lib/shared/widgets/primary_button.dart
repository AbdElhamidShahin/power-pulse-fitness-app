import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Reusable primary action button.
///
/// Previously `class sizedBox` in lib/view/Helper/helper.dart — renamed to
/// PrimaryButton with a conventional class name.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.width,
    required this.height,
    this.onPressed,
  });

  final String text;
  final double width;
  final double height;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.buttonBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextButton(
          onPressed: onPressed,
          child: Text(
            text,
            textDirection: TextDirection.rtl,
            style: AppTextStyles.buttonLabel,
          ),
        ),
      ),
    );
  }
}
