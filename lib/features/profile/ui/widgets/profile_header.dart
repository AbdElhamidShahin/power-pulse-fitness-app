import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/user_profile_entity.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E),
      padding: EdgeInsets.fromLTRB(16.w, 48.h, 16.w, 20.h),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 72.r,
            height: 72.r,
            decoration: const BoxDecoration(
              color: Color(0xFFA3E635),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                profile.name.isNotEmpty ? profile.name[0] : 'أ',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E1E1E),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            profile.name,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'ahmed@email.com',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.sp,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          SizedBox(height: 16.h),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(value: '47', label: 'تمرين'),
              _StatItem(value: '14', label: 'سلسلة'),
              _StatItem(
                value: '${profile.weightKg.toInt()} كجم',
                label: 'الوزن',
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
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFA3E635),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11.sp,
            color: const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }
}