import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../data/models/user_profile_entity.dart';
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
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) => switch (state) {
          ProfileInitial() || ProfileLoading() => const _LoadingView(),
          ProfileError(:final message) => _ErrorView(message: message),
          ProfileLoaded(:final profile) => _LoadedView(profile: profile),
        },
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ─── Header داكن زي التصميم الجديد ────────────────────
        SliverToBoxAdapter(
          child: Container(
            color: AppColors.bgDark,
            padding: const EdgeInsets.fromLTRB(
              AppConstants.screenPaddingH,
              52,
              AppConstants.screenPaddingH,
              AppConstants.spaceXXL,
            ),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      profile.name.isNotEmpty ? profile.name[0] : 'P',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spaceM),
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textOnDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.activityLevel.labelAr,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: const Color(0xFF888888)),
                ),
                const SizedBox(height: AppConstants.spaceL),
                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatItem(value: '47', label: 'تمرين'),
                    const SizedBox(width: AppConstants.space3XL),
                    _StatItem(
                      value: '${profile.weightKg.toInt()} كجم',
                      label: 'الوزن',
                    ),
                    const SizedBox(width: AppConstants.space3XL),
                    _StatItem(
                      value: profile.goal.labelAr,
                      label: 'الهدف',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ─── BMI Card ───────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.screenPaddingH,
            AppConstants.spaceL,
            AppConstants.screenPaddingH,
            0,
          ),
          sliver: SliverToBoxAdapter(child: BmiCard(profile: profile)),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppConstants.spaceL)),

        // ─── Daily Targets ─────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.screenPaddingH),
          sliver: SliverToBoxAdapter(child: DailyTargetsCard(profile: profile)),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppConstants.spaceL)),

        // ─── البيانات الشخصية ───────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.screenPaddingH),
          sliver: SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
              ),
              child: Column(
                children: [
                  _InfoRow(icon: '👤', label: 'الاسم', value: profile.name),
                  _Divider(),
                  _InfoRow(
                      icon: '🎂',
                      label: 'العمر',
                      value: '${profile.age} سنة'),
                  _Divider(),
                  _InfoRow(
                      icon: '📏',
                      label: 'الطول',
                      value: '${profile.heightCm.toInt()} سم'),
                  _Divider(),
                  _InfoRow(
                      icon: '⚖️',
                      label: 'الوزن',
                      value: '${profile.weightKg.toInt()} كجم'),
                  _Divider(),
                  _InfoRow(
                      icon: '🎯', label: 'الهدف', value: profile.goal.labelAr),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppConstants.spaceL)),

        // ─── الإعدادات ─────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.screenPaddingH),
          sliver: SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
              ),
              child: Column(
                children: [
                  _SettingRow(
                    icon: Icons.edit_rounded,
                    label: 'تعديل الملف الشخصي',
                    onTap: () => context.push('/profile/edit'),
                  ),
                  _Divider(),
                  _SettingRow(
                    icon: Icons.notifications_rounded,
                    label: 'الإشعارات',
                    toggle: true,
                    onTap: () {},
                  ),
                  _Divider(),
                  _SettingRow(
                    icon: Icons.star_outline_rounded,
                    label: 'قيّم التطبيق',
                    iconColor: AppColors.warning,
                    onTap: () {},
                  ),
                  _Divider(),
                  _SettingRow(
                    icon: Icons.info_outline_rounded,
                    label: 'عن التطبيق',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppConstants.spaceL)),

        // ─── تسجيل الخروج ──────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.screenPaddingH),
          sliver: SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(AppConstants.spaceL),
                decoration: BoxDecoration(
                  color: AppColors.dangerDim,
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout_rounded,
                        color: AppColors.danger, size: 20),
                    const SizedBox(width: AppConstants.spaceS),
                    Text(
                      'تسجيل الخروج',
                      style: AppTextStyles.labelLarge
                          .copyWith(color: AppColors.danger),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(
            child: SizedBox(height: AppConstants.space4XL)),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.accent,
            )),
        Text(label,
            style: AppTextStyles.bodySmall
                .copyWith(color: const Color(0xFF888888), fontSize: 10)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.label, required this.value});
  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceL, vertical: AppConstants.spaceM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.arrow_back_ios_rounded,
                  color: AppColors.textMuted, size: AppConstants.iconXS),
              const SizedBox(width: AppConstants.spaceS),
              Text(value,
                  style: AppTextStyles.titleSmall
                      .copyWith(color: AppColors.textPrimary)),
            ],
          ),
          Row(
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              const SizedBox(width: AppConstants.spaceS),
              Text(icon, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 0.5, color: AppColors.borderSubtle);
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.toggle,
    this.iconColor,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool? toggle;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceL, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            toggle != null
                ? Container(
              width: 40,
              height: 22,
              decoration: BoxDecoration(
                color: toggle! ? AppColors.accent : AppColors.bgElevated,
                borderRadius: BorderRadius.circular(11),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: toggle!
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.bgSurface,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            )
                : const Icon(Icons.arrow_back_ios_rounded,
                color: AppColors.textMuted, size: AppConstants.iconXS),
            Row(
              children: [
                Text(label, style: AppTextStyles.titleMedium),
                const SizedBox(width: AppConstants.spaceM),
                Icon(icon,
                    color: iconColor ?? AppColors.textMuted,
                    size: AppConstants.iconM),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Loading / Error ──────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(color: AppColors.accent));
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
        child: Text(AppStrings.tryAgain, style: AppTextStyles.accentLabel),
      ),
    ]),
  );
}
