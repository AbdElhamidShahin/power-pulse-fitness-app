import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';

class ProgressStatCard extends StatelessWidget {
  const ProgressStatCard({
    super.key,
    required this.emoji,
    required this.value,
    required this.label,
    required this.valueColor,
    this.valueFontSize = 28,
  });

  final String emoji;
  final String value;
  final String label;
  final Color valueColor;
  final double valueFontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: 20.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: valueFontSize.sp,
              fontWeight: FontWeight.w900,
              color: valueColor,
              height: 1.0,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.sp,
              color: const Color(0xFF8A8A8A),
            ),
          ),
        ],
      ),
    );
  }
}