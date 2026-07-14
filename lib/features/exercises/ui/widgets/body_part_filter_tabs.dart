import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class BodyPartFilterTabs extends StatelessWidget {
  const BodyPartFilterTabs({
    super.key,
    required this.bodyParts,
    required this.selected,
    required this.onSelect,
  });

  final List<String> bodyParts;
  final String selected;
  final ValueChanged<String> onSelect;

  // Translate API English → Arabic
  static String _label(String part) => switch (part.toLowerCase()) {
    'all'        => 'الكل',
    'chest'      => 'صدر',
    'back'       => 'ظهر',
    'legs'       => 'أرجل',
    'shoulders'  => 'كتف',
    'upper arms' => 'أذرع',
    'lower arms' => 'سواعد',
    'upper legs' => 'فخذ',
    'lower legs' => 'ساق',
    'core'       => 'بطن',
    'waist'      => 'خصر',
    'cardio'     => 'كارديو',
    'neck'       => 'رقبة',
    _            => part,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPaddingH),
        itemCount: bodyParts.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppConstants.spaceS),
        itemBuilder: (_, i) {
          final part = bodyParts[i];
          final isSelected = part == selected;
          return GestureDetector(
            onTap: () => onSelect(part),
            child: AnimatedContainer(
              duration: AppConstants.durationFast,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceL,
                vertical: AppConstants.spaceS,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : AppColors.bgElevated,
                borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.borderSubtle,
                ),
              ),
              child: Text(
                _label(part),
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? AppColors.textOnAccent : AppColors.textMuted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
