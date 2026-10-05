import 'package:flutter/material.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';
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
              context.l10n.exerciseLibrary,
              style: TextStyle(
                fontSize: 11.sp,
                color: Color(0xFF8A8A8A),
                fontFamily: 'Cairo',
              ),
            ),
            Text(
              context.l10n.qaExercises,
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w900,
                color: context.colors.textPrimary,
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
              color: isSearching ? context.colors.bgDark : context.colors.bgElevated,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: isSearching ? AppColors.textOnDark : context.colors.textMuted,
              size: 24.r,
            ),
          ),
        ),
      ],
    );
  }
}