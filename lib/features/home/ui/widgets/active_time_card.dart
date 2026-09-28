import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/theme/app_colors.dart';

class ActiveTimeCard extends StatelessWidget {
  const ActiveTimeCard({super.key, required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 24.w, 14.h),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'وقت النشاط',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14.sp,
              color: const Color(0xFF888888),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '$minutes',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 30.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.accent,
              height: 1.0,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'دقيقة اليوم',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14.sp,
              color: const Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }
}