import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_text_styles.dart';

// Full-width primary button for dark auth screens (login, signup, onboarding).
// Shows a spinner when [loading] is true and dims when [disabled].
class DarkPrimaryButton extends StatelessWidget {
  const DarkPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading  = false,
    this.disabled = false,
    this.accent   = const Color(0xFFA8E063),
  });

  final String        label;
  final VoidCallback? onTap;
  final bool          loading;
  final bool          disabled;
  final Color         accent;

  @override
  Widget build(BuildContext context) {
    final active = !disabled && !loading && onTap != null;
    return GestureDetector(
      onTap: active ? onTap : null,
      child: AnimatedContainer(
        duration: AppConstants.durationFast,
        width:    double.infinity,
        height:   AppConstants.buttonHeightLarge,
        decoration: BoxDecoration(
          color: active ? accent : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(
            color: active ? Colors.transparent : const Color(0xFF2E2E2E),
          ),
        ),
        child: Center(
          child: loading
              ? SizedBox(
                  width: 20.r, height: 20.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: active ? const Color(0xFF0F0F0F) : const Color(0xFF666666),
                  ),
                )
              : Text(
                  label,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: 15.sp,
                    color: active ? const Color(0xFF0F0F0F) : const Color(0xFF666666),
                  ),
                ),
        ),
      ),
    );
  }
}
