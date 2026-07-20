import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/user_profile_entity.dart';
import '../../logic/cubit/profile_cubit.dart';
import '../../logic/cubit/profile_state.dart';
import '../widgets/profile_header.dart' show ProfileHeader;
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
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _metricUnitsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;

    return CustomScrollView(
      slivers: [
        // ─── Header ──────────────────────────────────────────
        SliverToBoxAdapter(
          child: ProfileHeader(profile: profile),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 16.h)),

        // ─── البيانات الشخصية ─────────────────────────────────
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ProfileSectionTitle(title: 'البيانات الشخصية'),
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

        // ─── الإعدادات ─────────────────────────────────────────
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ProfileSectionTitle(title: 'الإعدادات'),
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
                        label: 'الإشعارات',
                        value: _notificationsEnabled,
                        onChanged: (val) =>
                            setState(() => _notificationsEnabled = val),
                      ),
                      const ProfileDivider(),
                      ProfileToggleRow(
                        icon: Icons.nightlight_round,
                        iconColor: const Color(0xFFF59E0B),
                        label: 'الوضع الليلي',
                        value: _darkModeEnabled,
                        onChanged: (val) =>
                            setState(() => _darkModeEnabled = val),
                      ),
                      const ProfileDivider(),
                      ProfileToggleRow(
                        icon: Icons.square_foot_rounded,
                        iconColor: const Color(0xFF10B981),
                        label: 'الوحدات (كجم/سم)',
                        value: _metricUnitsEnabled,
                        onChanged: (val) =>
                            setState(() => _metricUnitsEnabled = val),
                      ),
                      const ProfileDivider(),
                      ProfileInfoRow(
                        icon: Icons.lock_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        label: 'الخصوصية',
                        value: '',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 20.h)),

        // ─── تسجيل الخروج ──────────────────────────────────────
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverToBoxAdapter(
            child: InkWell(
              onTap: () {},
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
                      'تسجيل الخروج',
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
}