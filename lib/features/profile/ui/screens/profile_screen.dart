import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/auth/user_mode_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/pp_button.dart';
import '../widgets/notification_settings_section.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../data/models/user_profile_entity.dart';
import '../../logic/cubit/profile_cubit.dart';
import '../../logic/cubit/profile_state.dart';
import '../../logic/cubit/settings_cubit.dart';
import '../../logic/cubit/settings_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_items.dart';


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
        backgroundColor: context.colors.bgDeep,
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) => switch (state) {
            ProfileInitial() || ProfileLoading() => const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
            ProfileError(:final message) => Center(child: Text(message)),
            ProfileLoaded(:final profile) => _ProfileContent(profile: profile),
          },
        ),
    );
  }
}

class _ProfileContent extends StatefulWidget {
  const _ProfileContent({required this.profile});
  final UserProfile profile;

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final settings = context.watch<AppSettingsCubit>().state;

    return CustomScrollView(
      slivers: [
        // ─── Header ──────────────────────────────────────────
        SliverToBoxAdapter(
          child: ProfileHeader(profile: profile),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 16.h)),

        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileSectionTitle(title: context.l10n.personalData),
                Container(
                  decoration: BoxDecoration(
                    color: context.colors.bgSurface,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    children: [
                      ProfileInfoRow(
                        icon: Icons.person_rounded,
                        iconColor: AppColors.profileIconPurple,
                        label: context.l10n.nameLabel,
                        value: profile.name,
                        onTap: () => context.push('/profile/edit'),
                      ),
                      const ProfileDivider(),
                      ProfileInfoRow(
                        icon: Icons.cake_rounded,
                        iconColor: AppColors.profileIconOrange,
                        label: context.l10n.ageLabel,
                        value: context.l10n.valueYears.replaceFirst('{value}', '${profile.age}'),
                        onTap: () => context.push('/profile/edit'),
                      ),
                      const ProfileDivider(),
                      ProfileInfoRow(
                        icon: Icons.edit_rounded,
                        iconColor: context.colors.textMuted,
                        label: context.l10n.height,
                        value: context.l10n.valueCm.replaceFirst('{value}', '${profile.heightCm.toInt()}'),
                        onTap: () => context.push('/profile/edit'),
                      ),
                      const ProfileDivider(),
                      ProfileInfoRow(
                        icon: Icons.balance_rounded,
                        iconColor: AppColors.warning,
                        label: context.l10n.weight,
                        value: context.l10n.valueKg.replaceFirst('{value}', '${profile.weightKg.toInt()}'),
                        onTap: () => context.push('/profile/edit'),
                      ),
                      const ProfileDivider(),
                      ProfileInfoRow(
                        icon: Icons.track_changes_rounded,
                        iconColor: AppColors.profileIconPink,
                        label: context.l10n.goal,
                        value: profile.goal.labelAr,
                        onTap: () => context.push('/profile/edit'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 16.h)),

        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileSectionTitle(title: context.l10n.settingsLabel),
                Container(
                  decoration: BoxDecoration(
                    color: context.colors.bgSurface,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    children: [
                      ProfileToggleRow(
                        icon: Icons.notifications_rounded,
                        iconColor: AppColors.warning,
                        label: context.l10n.notificationsLabel,
                        value: settings.notificationsEnabled,
                        onChanged: (val) =>
                            context.read<AppSettingsCubit>().toggleNotifications(val),
                      ),
                      const ProfileDivider(),
                      ProfileToggleRow(
                        icon: Icons.nightlight_round,
                        iconColor: AppColors.profileIconIndigo,
                        label: context.l10n.darkModeLabel,
                        value: settings.isDarkMode,
                        onChanged: (val) =>
                            context.read<AppSettingsCubit>().toggleDarkMode(val),
                      ),
                      const ProfileDivider(),
                      _LanguagePickerRow(settings: settings),
                      const ProfileDivider(),
                      ProfileToggleRow(
                        icon: Icons.square_foot_rounded,
                        iconColor: AppColors.profileIconTeal,
                        label: context.l10n.unitsLabel,
                        value: settings.isMetricUnits,
                        onChanged: (val) =>
                            context.read<AppSettingsCubit>().toggleMetricUnits(val),
                      ),
                      const ProfileDivider(),
                      ProfileInfoRow(
                        icon: Icons.lock_rounded,
                        iconColor: AppColors.warning,
                        label: context.l10n.privacyLabel,
                        value: '',
                        onTap: () => _showPrivacySheet(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 20.h)),

        // ─── إعدادات الإشعارات التفصيلية ────────────────────────
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: const SliverToBoxAdapter(
            child: NotificationSettingsSection(),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 20.h)),

        // ─── زر تسجيل الدخول للضيف ──────────────────────────────
        FutureBuilder<bool>(
          future: _isGuest(),
          builder: (context, snap) {
            if (snap.data != true) return const SliverToBoxAdapter(child: SizedBox.shrink());
            return SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: AppColors.accentDim,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppColors.accent.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.cloud_upload_outlined,
                          color: AppColors.profileIconGreen, size: 22),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          context.l10n.guestModeDesc,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12.sp,
                            color: AppColors.profileIconDark,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      TextButton(
                        onPressed: () => context.push(AppRouter.login),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 6.h),
                          backgroundColor: AppColors.accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          context.l10n.login,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.profileIconDeep,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // ─── تسجيل الخروج ──────────────────────────────────────
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverToBoxAdapter(
            child: InkWell(
              onTap: () => _confirmLogout(context),
              borderRadius: BorderRadius.circular(14.r),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.dangerSurface,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.style_rounded,
                        color: AppColors.danger, size: 18.r),
                    SizedBox(width: 6.w),
                    Text(
                      context.l10n.logoutLabel,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 32.h)),
      ],
    );
  }

  Future<bool> _isGuest() async {
    final isSupabaseAuth = Supabase.instance.client.auth.currentUser != null;
    if (isSupabaseAuth) return false;
    final prefs = await SharedPreferences.getInstance();
    final mode = await UserModeService.getMode(prefs);
    return mode == UserMode.guest;
  }

  void _showPrivacySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Text(context.l10n.privacyAndData,
                style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 18,
                    fontWeight: FontWeight.w900, color: context.colors.textPrimary)),
            const SizedBox(height: 16),
            _PrivacyItem(
              icon: Icons.phone_android_rounded,
              title: context.l10n.dataStoredLocally,
              desc: context.l10n.dataStoredDesc,
            ),
            const SizedBox(height: 12),
            _PrivacyItem(
              icon: Icons.block_rounded,
              title: context.l10n.noAds,
              desc: context.l10n.noAdsDesc,
            ),
            const SizedBox(height: 12),
            _PrivacyItem(
              icon: Icons.delete_forever_rounded,
              title: context.l10n.deleteData,
              desc: context.l10n.deleteDataDesc,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.logout,
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        content: Text(context.l10n.logoutConfirmContent,
            style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel,
                style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AppSettingsCubit>().logout();
              // After logout → switch to guest mode → go to home
              // (user can still use the app as a guest; can sign in again from profile)
              if (context.mounted) context.go(AppRouter.home);
            },
            child: Text(context.l10n.logout,
                style: const TextStyle(
                    fontFamily: 'Cairo', color: AppColors.danger,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
class _PrivacyItem extends StatelessWidget {
  const _PrivacyItem({
    required this.icon,
    required this.title,
    required this.desc,
  });
  final IconData icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppColors.accentDim,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.accent, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  )),
              const SizedBox(height: 2),
              Text(desc,
                  style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 12,
                    color: context.colors.textMuted,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}


// ─── Language Picker Row ─────────────────────────────────────────────────
class _LanguagePickerRow extends StatelessWidget {
  const _LanguagePickerRow({required this.settings});
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final isAr = settings.isArabic;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Icon(Icons.language_rounded,
              color: AppColors.profileIconBlue, size: 20.r),
          SizedBox(width: 12.w),
          Text(
            context.l10n.language,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          const Spacer(),
          // Toggle بين العربي والإنجليزي
          GestureDetector(
            onTap: () {
              final newLocale = isAr ? 'en' : 'ar';
              context.read<AppSettingsCubit>().setLocale(newLocale);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.accent.withOpacity(0.4)),
              ),
              child: Text(
                isAr ? 'AR | EN' : 'EN | AR',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ─── Guest Profile View ──────────────────────────────────────
class _GuestProfileView extends StatelessWidget {
  const _GuestProfileView({required this.onLogin});
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.space3XL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.bgElevated,
              ),
              child: Icon(
                Icons.person_outline_rounded,
                size: 40.r,
                color: context.colors.textMuted,
              ),
            ),
            SizedBox(height: AppConstants.spaceXL.h),
            Text(
              context.l10n.guestModeTitle,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: context.colors.textPrimary,
              ),
            ),
            SizedBox(height: AppConstants.spaceS.h),
            Text(
              context.l10n.guestModeSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14.sp,
                color: context.colors.textMuted,
              ),
            ),
            SizedBox(height: AppConstants.spaceXXL.h),
            PPButton(
              label: context.l10n.login,
              onPressed: onLogin,
            ),
          ],
        ),
      ),
    );
  }
}
