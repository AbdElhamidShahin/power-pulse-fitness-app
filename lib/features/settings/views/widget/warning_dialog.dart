import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

void showWarningDialog(BuildContext context) => showDialog(
  context: context,
  builder: (_) => AlertDialog(
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
    ),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'تحذير',
          style:
          AppTextStyles.headlineMd.copyWith(color: AppColors.error),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.warning_amber_rounded,
            color: AppColors.error, size: 24),
      ],
    ),
    content: Text(
      'هذه التمارين لأغراض تثقيفية فقط. استشر طبيبك قبل البدء في أي برنامج رياضي.',
      style: AppTextStyles.bodyMd,
      textDirection: TextDirection.rtl,
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(
          'موافق',
          style: AppTextStyles.labelCaps.copyWith(
            color: AppColors.primary,
            fontSize: 14,
          ),
        ),
      ),
    ],
  ),
);