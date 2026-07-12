import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../logic/cubit/profile_cubit.dart';
import '../../logic/cubit/profile_state.dart';
import '../widgets/bmi_card.dart';
import '../widgets/daily_targets_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) => switch (state) {
            ProfileInitial() ||
            ProfileLoading()                  => const _LoadingView(),
            ProfileError(:final message)      => _ErrorView(message: message),
            ProfileLoaded(:final profile)     => _LoadedView(profile: profile),
          },
        ),
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.profile});
  final profile;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ─── Header ────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.screenPaddingH,
              AppConstants.spaceL,
              AppConstants.screenPaddingH,
              AppConstants.spaceXXL,
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: AppConstants.avatarXL,
                  height: AppConstants.avatarXL,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.bgElevated,
                    border: Border.all(
                        color: AppColors.accent, width: 2),
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: AppColors.textMuted, size: 40),
                ),
                const SizedBox(width: AppConstants.spaceL),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.name,
                          style: Theme.of(context).textTheme.headlineLarge),
                      const SizedBox(height: AppConstants.spaceXS),
                      Text(
                        profile.activityLevel.labelAr,
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: AppConstants.spaceS),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accentDim,
                          borderRadius: BorderRadius.circular(
                              AppConstants.radiusPill),
                          border:
                              Border.all(color: AppColors.borderAccent),
                        ),
                        child: Text(
                          profile.goal.labelAr,
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.accent),
                        ),
                      ),
                    ],
                  ),
                ),
                // Edit button
                GestureDetector(
                  onTap: () => context.push('/profile/edit'),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.bgElevated,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusM),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Icon(Icons.edit_rounded,
                        color: AppColors.textMuted,
                        size: AppConstants.iconS),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ─── BMI Card ──────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.screenPaddingH),
          sliver: SliverToBoxAdapter(child: BmiCard(profile: profile)),
        ),

        const SliverToBoxAdapter(
            child: SizedBox(height: AppConstants.spaceL)),

        // ─── Daily Targets ─────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.screenPaddingH),
          sliver: SliverToBoxAdapter(
              child: DailyTargetsCard(profile: profile)),
        ),

        const SliverToBoxAdapter(
            child: SizedBox(height: AppConstants.spaceL)),

        // ─── Settings List ─────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.screenPaddingH),
          sliver: SliverToBoxAdapter(
            child: _SettingsList(),
          ),
        ),

        const SliverToBoxAdapter(
            child: SizedBox(height: AppConstants.space4XL)),
      ],
    );
  }
}

class _SettingsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          _SettingsRow(
            icon: Icons.edit_rounded,
            label: 'تعديل الملف الشخصي',
            onTap: () => context.push('/profile/edit'),
          ),
          const Divider(height: 0.5, color: AppColors.borderSubtle),
          _SettingsRow(
            icon: Icons.info_outline_rounded,
            label: 'عن التطبيق',
            onTap: () {},
          ),
          const Divider(height: 0.5, color: AppColors.borderSubtle),
          _SettingsRow(
            icon: Icons.star_outline_rounded,
            iconColor: AppColors.warning,
            label: 'قيّم التطبيق',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceL,
          vertical: AppConstants.spaceM,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: iconColor ?? AppColors.textMuted,
                size: AppConstants.iconM),
            const SizedBox(width: AppConstants.spaceM),
            Expanded(
              child: Text(label, style: AppTextStyles.titleMedium),
            ),
            const Icon(Icons.arrow_back_ios_rounded,
                color: AppColors.textMuted, size: AppConstants.iconXS),
          ],
        ),
      ),
    );
  }
}

// ─── Loading / Error ─────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => const Center(
      child: CircularProgressIndicator(color: AppColors.accent));
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.danger, size: 48),
          const SizedBox(height: AppConstants.spaceM),
          Text(message, style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppConstants.spaceL),
          GestureDetector(
            onTap: () => context.read<ProfileCubit>().load(),
            child: Text(AppStrings.tryAgain,
                style: AppTextStyles.accentLabel),
          ),
        ]),
      );
}
