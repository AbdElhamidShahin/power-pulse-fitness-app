import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../logic/onboarding_cubit.dart';
import '../../logic/onboarding_state.dart' ;

class LevelPicker extends StatelessWidget {
  const LevelPicker({super.key});

  static const _icons = [
    Icons.directions_walk_rounded,
    Icons.directions_run_rounded,
    Icons.electric_bolt_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final cubit    = context.read<OnboardingCubit>();
        final selected = cubit.currentLevel;
        return Row(
          children: List.generate(OnboardingCubit.levels.length, (i) {
            final level    = OnboardingCubit.levels[i];
            final isActive = selected == level;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    left: i < OnboardingCubit.levels.length - 1
                        ? AppSpacing.xs
                        : 0),
                child: GestureDetector(
                  onTap: () => cubit.selectLevel(level),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary.withOpacity(0.15)
                          : AppColors.surface,
                      borderRadius:
                      BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.cardBorder,
                        width: isActive ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_icons[i],
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 24),
                        const SizedBox(height: 6),
                        Text(level,
                            style: AppTextStyles.labelCaps.copyWith(
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontSize: 12,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).reversed.toList(),
        );
      },
    );
  }
}