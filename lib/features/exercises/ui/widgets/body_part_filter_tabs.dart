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

  static String _label(String part) => switch (part.toLowerCase()) {
    'all'        => 'الكل',
    'chest'      => 'صدر',
    'back'       => 'ظهر',
    'legs'       => 'أرجل',
    'shoulders'  => 'أكتاف',
    'upper arms' => 'بايسبس/ترايسبس',
    'lower arms' => 'ساعد',
    'upper legs' => 'أرجل علوي',
    'lower legs' => 'أرجل سفلي',
    'core'       => 'كور',
    'waist'      => 'بطن',
    'cardio'     => 'كارديو',
    'neck'       => 'رقبة',
    _            => part,
  };

  static IconData _icon(String part) => switch (part.toLowerCase()) {
    'all'        => Icons.grid_view_rounded,
    'chest'      => Icons.fitness_center_rounded,
    'back'       => Icons.accessibility_new_rounded,
    'shoulders'  => Icons.sports_gymnastics_rounded,
    'upper arms' => Icons.sports_handball_rounded,
    'lower arms' => Icons.back_hand_rounded,
    'upper legs' => Icons.directions_walk_rounded,
    'lower legs' => Icons.directions_run_rounded,
    'waist'      => Icons.rotate_right_rounded,
    'cardio'     => Icons.favorite_rounded,
    _            => Icons.circle_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.screenPaddingH),
        itemCount: bodyParts.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: AppConstants.spaceS),
        itemBuilder: (_, i) {
          final part = bodyParts[i];
          final isSelected = part == selected;
          return GestureDetector(
            onTap: () => onSelect(part),
            child: AnimatedContainer(
              duration: AppConstants.durationFast,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceL,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : AppColors.bgElevated,
                borderRadius:
                BorderRadius.circular(AppConstants.radiusPill),
                border: Border.all(
                  color: isSelected
                      ? AppColors.accent
                      : AppColors.borderSubtle,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _icon(part),
                    size: 14,
                    color: isSelected
                        ? AppColors.textOnAccent
                        : AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _label(part),
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected
                          ? AppColors.textOnAccent
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
