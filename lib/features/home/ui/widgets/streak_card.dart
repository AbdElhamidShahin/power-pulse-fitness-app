import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/theme/app_colors.dart';
import 'RingPainter.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({super.key, required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final pct = (streak / 30).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                    trackColor: const Color(0xFF333333),
                    strokeWidth: 5.w,
                  ),
                ),
                Text(
                  '${(pct * 100).toInt()}%',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 6.w),
              Text(
                'السلسلة الحالية',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF888888),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Text(
                    '$streak يوم',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text('🔥', style: TextStyle(fontSize: 24.sp)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}