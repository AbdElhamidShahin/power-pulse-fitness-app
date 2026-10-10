import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:power_pulse/core/theme/app_theme_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
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
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
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
              _StatItem(value: '47', label: context.l10n.exerciseUnit),
              _StatItem(value: '14', label: context.l10n.currentStreak),
              _StatItem(
                value: context.l10n.valueKg.replaceFirst('{value}', '${profile.weightKg.toInt()}'),
                label: context.l10n.weight,
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

// ─── Profile Avatar (Google photo or initials) ───────────────
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          profile.avatarUrl!,
          width: 80.r,
          height: 80.r,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _Initials(name: profile.name),
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : _Initials(name: profile.name),
        ),
      );
    }
    return _Initials(name: profile.name);
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.r,
      height: 80.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.bgDark,
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'A',
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 32.sp,
          fontWeight: FontWeight.w900,
          color: AppColors.textOnDark,
        ),
      ),
    );
  }
}
