import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../data/models/user_profile_entity.dart';

class DailyTargetsCard extends StatelessWidget {
  const DailyTargetsCard({super.key, required this.profile});

  final UserProfile profile;

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
          Row(
            children: [
              Text('أهدافك اليومية',
                  style: Theme.of(context).textTheme.headlineSmall),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentDim,
                  borderRadius:
                  BorderRadius.circular(AppConstants.radiusPill),
                  border: Border.all(color: AppColors.borderAccent),
                ),
                child: Text(
                  profile.goal.labelAr,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceXL),
          _TargetRow(
            icon: Icons.local_fire_department_rounded,
            color: AppColors.accent,
            label: 'السعرات اليومية',
            value: '${profile.dailyCalorieGoal.toInt()}',
            unit: 'سعرة',
          ),
          const SizedBox(height: AppConstants.spaceM),
          _TargetRow(
            icon: Icons.egg_alt_rounded,
            color: AppColors.info,
            label: 'البروتين',
            value: '${profile.dailyProteinGoal.toInt()}',
            unit: 'g',
          ),
          const SizedBox(height: AppConstants.spaceM),
          _TargetRow(
            icon: Icons.bolt_rounded,
            color: AppColors.warning,
            label: 'معدل الحرق اليومي (TDEE)',
            value: '${profile.tdee.toInt()}',
            unit: 'سعرة',
          ),
        ],
      ),
    );
  }
}

class _TargetRow extends StatelessWidget {
  const _TargetRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.unit,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
          ),
          child: Icon(icon, color: color, size: AppConstants.iconS),
        ),
        const SizedBox(width: AppConstants.spaceM),
        Expanded(
          child: Text(label, style: AppTextStyles.bodyMedium),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 3),
            Padding(
              padding: const EdgeInsets.only(bottom: 1.5),
              child: Text(unit, style: AppTextStyles.bodySmall),
            ),
          ],
        ),
      ],
    );
  }
}
