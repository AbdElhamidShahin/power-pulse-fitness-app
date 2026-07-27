import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/theme/app_colors.dart';

class CaloriesCard extends StatelessWidget {
  const CaloriesCard({super.key, required this.calories});

  final double calories;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 24.w, 14.h),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'السعرات',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14.sp,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            calories.toInt().toString(),
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 30.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              height: 1.0,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'سعرة اليوم',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14.sp,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}