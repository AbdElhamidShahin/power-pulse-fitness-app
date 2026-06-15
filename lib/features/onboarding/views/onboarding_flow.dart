import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:task/features/onboarding/views/widget/goal_picker.dart';
import 'package:task/features/onboarding/views/widget/level_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/ui/components/pp_button.dart';
import '../../../core/services/user_profile_service.dart';
import '../data/repositories/onboarding_repo.dart';
import '../logic/onboarding_cubit.dart';
import '../logic/onboarding_state.dart';
import '../../exercises/views/gim_view.dart';

class OnboardingFlow extends StatelessWidget {
  const OnboardingFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(
        OnboardingRepositoryImpl(GetIt.instance<UserProfileService>()),
      ),
      child: const _OnboardingScreen(),
    );
  }
}

class _OnboardingScreen extends StatelessWidget {
  const _OnboardingScreen();

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        switch (state) {
          case OnboardingDone():
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const GimView()),
            );
          case OnboardingError(:final message):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message, textDirection: TextDirection.rtl),
                backgroundColor: AppColors.error,
              ),
            );
          default:
            break;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: AppSpacing.lg),

                // ── Logo / brand ──────────────────────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border:
                          Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.fitness_center_rounded,
                        color: AppColors.primary, size: 32),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('مرحباً بك', style: AppTextStyles.labelMuted),
                const SizedBox(height: 6),
                Text('Power Pulse', style: AppTextStyles.headlineHero),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'سنخصص برنامجك بناءً على مستواك وهدفك',
                  style: AppTextStyles.bodyMuted,
                  textAlign: TextAlign.end,
                ),

                const SizedBox(height: AppSpacing.lg + AppSpacing.sm),

                // ── Level picker ──────────────────────────────────────
                Text('ما هو مستواك الحالي؟', style: AppTextStyles.headingSmall),
                const SizedBox(height: AppSpacing.sm),
                const LevelPicker(),

                const SizedBox(height: AppSpacing.lg),

                // ── Goal picker ───────────────────────────────────────
                Text('ما هو هدفك الرئيسي؟', style: AppTextStyles.headingSmall),
                const SizedBox(height: AppSpacing.sm),
                const GoalPicker(),

                const SizedBox(height: AppSpacing.lg + AppSpacing.md),

                // ── CTA ───────────────────────────────────────────────
                BlocBuilder<OnboardingCubit, OnboardingState>(
                  builder: (context, state) {
                    final loading = state is OnboardingSaving;
                    return PpButton(
                      label: 'ابدأ رحلتك',
                      icon: Icons.arrow_back_rounded,
                      isLoading: loading,
                      onPressed: loading
                          ? null
                          : () => context.read<OnboardingCubit>().finish(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
