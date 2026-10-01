import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';

class BodyStatRow extends StatelessWidget {
  const BodyStatRow({
    super.key,
    required this.emoji,
    required this.label,
    required this.value,
    this.change,
    this.changeColor,
  });

  final String emoji;
  final String label;
  final String value;
  final String? change;
  final Color? changeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    color: Color(0xFF8A8A8A),
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    if (change != null) ...[
                      SizedBox(width: 8.w),
                      Text(
                        change!,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: changeColor ?? context.colors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 14.w),
          Text(
            emoji,
            style: TextStyle(fontSize: 22.sp),
          ),
        ],
      ),
    );
  }
}