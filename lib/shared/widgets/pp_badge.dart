import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';

enum PPBadgeSize { small, medium }

class PPBadge extends StatelessWidget {
  const PPBadge({
    super.key,
    required this.label,
    this.color,
    this.size = PPBadgeSize.medium,
    this.icon,
  });

  final String label;
  final Color? color;
  final PPBadgeSize size;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.accent;
    final double fontSize = size == PPBadgeSize.small ? 9 : 11;
    final EdgeInsets padding = size == PPBadgeSize.small
        ? const EdgeInsets.symmetric(horizontal: 7, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 3);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppConstants.radiusPill),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 1, color: c),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}

class MuscleGroupBadge extends StatelessWidget {
  const MuscleGroupBadge({super.key, required this.muscle, this.size = PPBadgeSize.medium});

  final String muscle;
  final PPBadgeSize size;

  Color _color() => switch (muscle.toLowerCase()) {
        'chest'    || 'صدر'   => AppColors.muscleChest,
        'back'     || 'ظهر'   => AppColors.muscleBack,
        'legs'     || 'أرجل'  => AppColors.muscleLegs,
        'shoulder' || 'كتف'   => AppColors.muscleShoulder,
        'arms'     || 'أذرع'  => AppColors.muscleArms,
        'core'     || 'بطن'   => AppColors.muscleCore,
        'cardio'   || 'كارديو'=> AppColors.muscleCardio,
        _                      => AppColors.accent,
      };

  String _label() => switch (muscle.toLowerCase()) {
        'chest'     => AppStrings.muscleChest,
        'back'      => AppStrings.muscleBack,
        'legs'      => AppStrings.muscleLegs,
        'shoulder'  => AppStrings.muscleShoulder,
        'arms'      => AppStrings.muscleArms,
        'core'      => AppStrings.muscleCore,
        'cardio'    => AppStrings.muscleCardio,
        _           => muscle,
      };

  @override
  Widget build(BuildContext context) =>
      PPBadge(label: _label(), color: _color(), size: size);
}

class LevelBadge extends StatelessWidget {
  const LevelBadge({super.key, required this.level, this.size = PPBadgeSize.medium});

  final String level;
  final PPBadgeSize size;

  Color _color() => switch (level.toLowerCase()) {
        'beginner'     || 'مبتدئ'  => AppColors.levelBeginner,
        'intermediate' || 'متوسط'  => AppColors.levelIntermediate,
        'advanced'     || 'متقدم'  => AppColors.levelAdvanced,
        _                           => AppColors.textMuted,
      };

  String _label() => switch (level.toLowerCase()) {
        'beginner'     => AppStrings.levelBeginner,
        'intermediate' => AppStrings.levelIntermediate,
        'advanced'     => AppStrings.levelAdvanced,
        _              => level,
      };

  @override
  Widget build(BuildContext context) =>
      PPBadge(label: _label(), color: _color(), size: size);
}
