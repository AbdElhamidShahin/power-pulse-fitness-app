import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';

class ExercisesHeader extends StatelessWidget {
  const ExercisesHeader({
    super.key,
    required this.isSearching,
    required this.onSearchTap,
  });

  final bool isSearching;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مكتبة التمارين',
              style: TextStyle(
                fontSize: 11.sp,
                color: const Color(0xFF8A8A8A),
                fontFamily: 'Cairo',
              ),
            ),
            Text(
              'التمارين 🏋️',
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onSearchTap,
          child: Container(
            width: 42.w,
            height: 42.h,
            decoration: BoxDecoration(
              color: isSearching ? AppColors.bgDark : AppColors.bgElevated,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: isSearching ? AppColors.textOnDark : AppColors.textMuted,
              size: 24.r,
            ),
          ),
        ),
      ],
    );
  }
}