import 'package:flutter/material.dart';
import 'package:power_pulse/core/localization/app_localizations.dart';
import 'package:power_pulse/core/theme/app_theme_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:power_pulse/core/theme/app_colors.dart';
import 'ring_painter.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({super.key, required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return streak == 0 ? _EmptyStreakCard() : _ActiveStreakCard(streak: streak);
  }
}

/// Empty state — motivates the user to complete their first workout
class _EmptyStreakCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: context.colors.bgDark,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accent.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text('🔥', style: TextStyle(fontSize: 22.sp)),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.streakEmptyTitle,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  l10n.streakEmptySubtitle,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    color: AppColors.textOnDarkMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Active state — shows the streak count and 30-day progress ring
class _ActiveStreakCard extends StatelessWidget {
  const _ActiveStreakCard({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pct = (streak / 30).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: context.colors.bgDark,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Progress ring — only shown when streak > 0
          SizedBox(
            width: 64.r,
            height: 64.r,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(64.r, 64.r),
                  painter: RingPainter(
                    progress: pct,
                    color: AppColors.accent,
                    trackColor: AppColors.bgDarkAlt,
                    strokeWidth: 5.w,
                  ),
                ),
                Text(
                  '🔥',
                  style: TextStyle(fontSize: 22.sp),
                ),
              ],
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.currentStreak,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textOnDarkMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$streak ${streak == 1 ? l10n.day : l10n.days}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${(pct * 100).toInt()}% ${l10n.of} ${l10n.streakGoal}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10.sp,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
