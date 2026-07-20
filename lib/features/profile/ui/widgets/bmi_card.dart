import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../data/models/user_profile_entity.dart';

class BmiCard extends StatelessWidget {
  const BmiCard({super.key, required this.profile});

  final UserProfile profile;

  Color get _bmiColor => switch (profile.bmi) {
    < 18.5 => AppColors.info,
    < 25.0 => AppColors.success,
    < 30.0 => AppColors.warning,
    _      => AppColors.danger,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceL),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('مؤشر كتلة الجسم (BMI)',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppConstants.spaceXL),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                profile.bmi.toStringAsFixed(1),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: _bmiColor,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: AppConstants.spaceM),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _bmiColor.withValues(alpha: 0.15),
                    borderRadius:
                    BorderRadius.circular(AppConstants.radiusPill),
                    border: Border.all(
                        color: _bmiColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    profile.bmiCategory,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _bmiColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceL),
          // BMI scale bar
          _BmiScaleBar(bmi: profile.bmi),
          const SizedBox(height: AppConstants.spaceL),
          // Quick stats row
          Row(
            children: [
              _QuickStat(
                  label: 'الطول',
                  value: '${profile.heightCm.toInt()}',
                  unit: 'سم'),
              _Divider(),
              _QuickStat(
                  label: 'الوزن',
                  value: profile.weightKg.toStringAsFixed(1),
                  unit: 'كج'),
              _Divider(),
              _QuickStat(
                  label: 'العمر',
                  value: '${profile.age}',
                  unit: 'سنة'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BmiScaleBar extends StatelessWidget {
  const _BmiScaleBar({required this.bmi});
  final double bmi;

  double get _position => ((bmi - 10) / 30).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 10,
          child: Stack(
            children: [
              // Gradient track
              ClipRRect(
                borderRadius:
                BorderRadius.circular(AppConstants.radiusPill),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.info,
                        AppColors.success,
                        AppColors.warning,
                        AppColors.danger,
                      ],
                    ),
                  ),
                ),
              ),
              // Indicator
              Positioned(
                left: null,
                right: null,
                child: LayoutBuilder(
                  builder: (_, constraints) => Positioned(
                    left: (constraints.maxWidth * _position) - 5,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black26, width: 1),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spaceXS),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('10', style: TextStyle(fontFamily: 'Cairo', fontSize: 9, color: AppColors.textMuted)),
            Text('18.5', style: TextStyle(fontFamily: 'Cairo', fontSize: 9, color: AppColors.textMuted)),
            Text('25', style: TextStyle(fontFamily: 'Cairo', fontSize: 9, color: AppColors.textMuted)),
            Text('30', style: TextStyle(fontFamily: 'Cairo', fontSize: 9, color: AppColors.textMuted)),
            Text('40', style: TextStyle(fontFamily: 'Cairo', fontSize: 9, color: AppColors.textMuted)),
          ],
        ),
      ],
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat(
      {required this.label, required this.value, required this.unit});
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary)),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(unit, style: AppTextStyles.bodySmall),
              ),
            ],
          ),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 0.5,
    height: 36,
    color: AppColors.borderSubtle,
    margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceS),
  );
}
