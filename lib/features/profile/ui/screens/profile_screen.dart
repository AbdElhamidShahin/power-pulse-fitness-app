import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/auth/user_mode_service.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/notifications/notification_settings_section.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/user_profile_entity.dart';
import '../../logic/cubit/profile_cubit.dart';
import '../../logic/cubit/profile_state.dart';
import '../../logic/cubit/settings_cubit.dart';
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
    return Directionality(
      textDirection: TextDirection.rtl, // لضمان صحة الاتجاهات عربيًا
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F4),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) => switch (state) {
            ProfileInitial() || ProfileLoading() => const Center(
              child: CircularProgressIndicator(color: Color(0xFFA3E635)),
            ),
            ProfileError(:final message) => Center(child: Text(message)),
            ProfileLoaded(:final profile) => _ProfileContent(profile: profile),
          },
        ),
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
          child: ProfileHeader(profile: profile, workoutCount: 0, streakDays: 0),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 16.h)),

        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ProfileSectionTitle(title: AppStrings.profilePersonal),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    children: [
                      ProfileInfoRow(
                        icon: Icons.person_rounded,
                        iconColor: const Color(0xFF6B21A8),
                        label: 'الاسم',
                        value: profile.name,
                        onTap: () => context.push('/profile/edit'),
                      ),
                      const ProfileDivider(),
                      ProfileInfoRow(
                        icon: Icons.cake_rounded,
                        iconColor: const Color(0xFFF97316),
                        label: 'العمر',
                        value: '${profile.age} سنة',
                        onTap: () => context.push('/profile/edit'),
                      ),
                      const ProfileDivider(),
                      ProfileInfoRow(
                        icon: Icons.edit_rounded,
                        iconColor: const Color(0xFF9CA3AF),
                        label: 'الطول',
                        value: '${profile.heightCm.toInt()} سم',
                        onTap: () => context.push('/profile/edit'),
                      ),
                      const ProfileDivider(),
                      ProfileInfoRow(
                        icon: Icons.balance_rounded,
                        iconColor: const Color(0xFFEAB308),
                        label: 'الوزن',
                        value: '${profile.weightKg.toInt()} كجم',
                        onTap: () => context.push('/profile/edit'),
                      ),
                      const ProfileDivider(),
                      ProfileInfoRow(
                        icon: Icons.track_changes_rounded,
                        iconColor: const Color(0xFFEC4899),
                        label: 'الهدف',
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
                const ProfileSectionTitle(title: AppStrings.profileSettings),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    children: [
                      ProfileToggleRow(
                        icon: Icons.notifications_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        label: AppStrings.profileNotifs,
                        value: settings.notificationsEnabled,
                        onChanged: (val) =>
                            context.read<AppSettingsCubit>().toggleNotifications(val),
                      ),
                      const ProfileDivider(),
                      ProfileToggleRow(
                        icon: Icons.nightlight_round,
                        iconColor: const Color(0xFF6366F1),
                        label: 'الوضع الليلي',
                        value: settings.isDarkMode,
                        onChanged: (val) =>
                            context.read<AppSettingsCubit>().toggleDarkMode(val),
                      ),
                      const ProfileDivider(),
                      ProfileToggleRow(
                        icon: Icons.square_foot_rounded,
                        iconColor: const Color(0xFF10B981),
                        label: 'الوحدات (كجم/سم)',
                        value: settings.isMetricUnits,
                        onChanged: (val) =>
                            context.read<AppSettingsCubit>().toggleMetricUnits(val),
                      ),
                      const ProfileDivider(),
                      ProfileInfoRow(
                        icon: Icons.lock_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        label: 'الخصوصية',
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
                    color: const Color(0xFFECFCCC),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFFA3E635).withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_upload_outlined,
                          color: Color(0xFF65A30D), size: 22),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'أنت في وضع الضيف. أنشئ حسابًا لحفظ بياناتك على السحابة.',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12.sp,
                            color: const Color(0xFF3F6212),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      TextButton(
                        onPressed: () => context.push(AppRouter.login),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 6.h),
                          backgroundColor: const Color(0xFFA3E635),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'تسجيل الدخول',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A2E05),
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
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.style_rounded,
                        color: const Color(0xFFEF4444), size: 18.r),
                    SizedBox(width: 6.w),
                    Text(
                      AppStrings.profileLogout,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFEF4444),
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
    if (FirebaseAuth.instance.currentUser != null) return false;
    final prefs = await SharedPreferences.getInstance();
    final mode = await UserModeService.getMode(prefs);
    return mode == UserMode.guest;
  }

  void _showPrivacySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('الخصوصية والبيانات',
                style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 18,
                    fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            _PrivacyItem(
              icon: Icons.phone_android_rounded,
              title: 'البيانات محفوظة محلياً',
              desc: 'كل بياناتك محفوظة على جهازك فقط ولا تُرسل لأي خادم',
            ),
            const SizedBox(height: 12),
            _PrivacyItem(
              icon: Icons.block_rounded,
              title: 'لا إعلانات',
              desc: 'التطبيق خالي من الإعلانات وتتبع البيانات',
            ),
            const SizedBox(height: 12),
            _PrivacyItem(
              icon: Icons.delete_forever_rounded,
              title: 'حذف البيانات',
              desc: 'يمكنك حذف كل بياناتك من خلال تسجيل الخروج',
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
        title: const Text(AppStrings.profileLogout,
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        content: const Text('هل أنت متأكد؟ ستستمر بياناتك محفوظة على السحابة ويمكنك تسجيل الدخول مجددًا لاستعادتها.',
            style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel,
                style: TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AppSettingsCubit>().logout();
              // Clear the router cache so the next redirect re-evaluates auth state
              // (stale 'home' result would otherwise bypass the entry screen check).
              AppRouter.clearLocationCache();
              // After logout → switch to guest mode → go to home
              // (user can still use the app as a guest; can sign in again from profile)
              // After logout, take user to entry screen so they can choose to
              // log back in or continue as a new guest.
              if (context.mounted) context.go(AppRouter.entry);
            },
            child: const Text(AppStrings.profileLogout,
                style: TextStyle(
                    fontFamily: 'Cairo', color: Color(0xFFEF4444),
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
                  style: const TextStyle(
                    fontFamily: 'Cairo', fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
              const SizedBox(height: 2),
              Text(desc,
                  style: const TextStyle(
                    fontFamily: 'Cairo', fontSize: 12,
                    color: AppColors.textMuted,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
