import 'package:flutter/material.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/theme/app_theme_colors.dart';

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
    'all'        => context.l10n.all,
    'chest'      => context.l10n.muscleChest,
    'back'       => context.l10n.muscleBack,
    'legs'       => context.l10n.muscleLegs,
    'shoulders'  => context.l10n.muscleShoulder,
    'upper arms' => context.l10n.muscleArms,
    'lower arms' => context.l10n.forearms,
    'upper legs' => context.l10n.upperLegs,
    'lower legs' => context.l10n.calves,
    'core'       => context.l10n.muscleCore,
    'waist'      => context.l10n.waist,
    'cardio'     => context.l10n.muscleCardio,
    'neck'       => context.l10n.neck,
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
                color: isSelected ? AppColors.accent : context.colors.bgElevated,
                borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                border: Border.all(
                  color: isSelected ? AppColors.accent : context.colors.borderSubtle,
                ),
              ),
              child: Text(
                _label(part),
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? AppColors.textOnAccent : context.colors.textMuted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
