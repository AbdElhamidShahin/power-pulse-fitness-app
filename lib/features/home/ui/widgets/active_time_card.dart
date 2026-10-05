import 'package:flutter/material.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/theme/app_theme_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/theme/app_colors.dart';

class ActiveTimeCard extends StatelessWidget {
  const ActiveTimeCard({super.key, required this.minutes});
  final int minutes;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: context.colors.bgDark,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.activeTime,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF888888),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '$minutes',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.0,
            ),
          ),
          Text(
            l10n.minutesToday,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.sp,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
