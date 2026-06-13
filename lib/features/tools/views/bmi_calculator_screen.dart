import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/ui/components/pp_app_bar.dart';
import '../widgets/bmi_widget.dart';

class BmiCalculatorScreen extends StatelessWidget {
  const BmiCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PpBackBar(title: 'مؤشر كتلة الجسم'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile, vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('مؤشر كتلة الجسم', style: AppTextStyles.headlineLgMobile),
            const SizedBox(height: 4),
            Text('Body Mass Index — BMI', style: AppTextStyles.labelMuted),
            const SizedBox(height: AppSpacing.sm),
            _BmiRangesBar(),
            const SizedBox(height: AppSpacing.sm),
            BmiWidget(),
          ],
        ),
      ),
    );
  }
}

class _BmiRangesBar extends StatelessWidget {
  static const _ranges = [
    ('نقص وزن', AppColors.bmiUnderweight),
    ('صحي', AppColors.bmiNormal),
    ('زيادة', AppColors.bmiOverweight),
    ('سمنة', AppColors.bmiObese),
    ('مفرط', AppColors.bmiMorbidObese),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('نطاقات المؤشر', style: AppTextStyles.labelMuted),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: _ranges.map((r) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: r.$2.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(color: r.$2.withOpacity(0.35)),
                ),
                child: Text(r.$1, style: AppTextStyles.labelCaps.copyWith(color: r.$2, fontSize: 8.5), textAlign: TextAlign.center),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
