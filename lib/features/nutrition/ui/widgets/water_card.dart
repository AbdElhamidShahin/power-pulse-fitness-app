import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';

class WaterCard extends StatelessWidget {
  const WaterCard({
    super.key,
    required this.current,
    required this.goal,
  });

  final double current;
  final double goal;

  static const int _totalBars = 5;

  int get _filledBars =>
      (current / goal * _totalBars).round().clamp(0, _totalBars);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.spaceL.w,
        vertical: (AppConstants.spaceM + 2).h,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'الماء',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text('💧', style: TextStyle(fontSize: 13.sp)),
                ],
              ),
              SizedBox(height: 4.h),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontFamily: 'Cairo'),
                  children: [
                    TextSpan(
                      text: '${goal}L',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                      ),
                    ),
                    TextSpan(
                      text: ' / ${current}L',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: List.generate(_totalBars, (i) {
              final isFilled = i < _filledBars;
              return Container(
                margin: EdgeInsets.only(right: 6.w),
                width: 18.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: isFilled
                      ? AppColors.info
                      : AppColors.info.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6.r),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}