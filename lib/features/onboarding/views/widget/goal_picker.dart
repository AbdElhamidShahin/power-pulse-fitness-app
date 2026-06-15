import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../logic/onboarding_cubit.dart';
import '../../logic/onboarding_state.dart';

class GoalPicker extends StatelessWidget {
  const GoalPicker({super.key});

  static const _icons = [
    Icons.fitness_center_rounded,
    Icons.trending_down_rounded,
    Icons.favorite_rounded,
    Icons.balance_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final cubit    = context.read<OnboardingCubit>();
        final selected = cubit.currentGoal;
        return Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          alignment: WrapAlignment.end,
          children: List.generate(OnboardingCubit.goals.length, (i) {
            final goal     = OnboardingCubit.goals[i];
            final isActive = selected == goal;
            return GestureDetector(
              onTap: () => cubit.selectGoal(goal),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withOpacity(0.15)
                      : AppColors.surface,
                  borderRadius:
                  BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.cardBorder,
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(goal,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w400,
                        )),
                    const SizedBox(width: 6),
                    Icon(_icons[i],
                        size: 16,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textSecondary),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}