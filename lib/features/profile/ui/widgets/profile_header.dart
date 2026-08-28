import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/user_profile_entity.dart';

// Shows user avatar, name, real email, and key stats at the top of profile.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.profile,
    this.workoutCount = 0,
    this.streakDays   = 0,
  });

  final UserProfile profile;
  final int         workoutCount;
  final int         streakDays;

  @override
  Widget build(BuildContext context) {
    // Use Firebase Auth email if the profile email is empty (e.g. Google login)
    final email = profile.email.isNotEmpty
        ? profile.email
        : (FirebaseAuth.instance.currentUser?.email ?? '');

    final initial = profile.name.isNotEmpty ? profile.name[0] : 'أ';

    return Container(
      color: const Color(0xFF1A1A1A),
      padding: EdgeInsets.fromLTRB(16.w, 48.h, 16.w, 20.h),
      child: Column(
        children: [
          // Avatar circle with first letter
          Container(
            width: 72.r,
            height: 72.r,
            decoration: BoxDecoration(
              color:  AppColors.accent,
              shape:  BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: AppTextStyles.headlineLarge.copyWith(
                  color:      const Color(0xFF1A1A1A),
                  fontSize:   26.sp,
                ),
              ),
            ),
          ),

          SizedBox(height: 8.h),

          // Name
          Text(
            profile.name,
            style: AppTextStyles.headlineMedium.copyWith(
              color:      Colors.white,
              fontSize:   18.sp,
            ),
          ),

          SizedBox(height: 2.h),

          // Real email from Firebase Auth or profile
          if (email.isNotEmpty)
            Text(
              email,
              style: AppTextStyles.bodySmall.copyWith(
                color:    const Color(0xFF9CA3AF),
                fontSize: 11.sp,
              ),
            ),

          SizedBox(height: 16.h),

          // Stats row — real data, no hardcoded numbers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(
                value: workoutCount.toString(),
                label: AppStrings.profileWorkouts,
              ),
              _StatItem(
                value: streakDays.toString(),
                label: AppStrings.profileStreak,
              ),
              _StatItem(
                value: '${profile.weightKg.toInt()} ${AppStrings.fieldWeightSuffix}',
                label: AppStrings.profileWeight,
              ),
            ],
          ),
        ],
      ),
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
        Text(
          value,
          style: AppTextStyles.headlineSmall.copyWith(
            color:    AppColors.accent,
            fontSize: 16.sp,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color:    const Color(0xFF9CA3AF),
            fontSize: 11.sp,
          ),
        ),
      ],
    );
  }
}
