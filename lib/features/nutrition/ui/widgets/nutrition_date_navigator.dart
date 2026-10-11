import 'package:flutter/material.dart';
import 'package:power_pulse/core/localization/app_localizations.dart';
import 'package:power_pulse/core/theme/app_theme_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:power_pulse/core/theme/app_colors.dart';
import '../../logic/cubit/nutrition_cubit.dart';

class NutritionDateNavigator extends StatelessWidget {
  const NutritionDateNavigator({super.key});

  String _formatLabel(BuildContext context, DateTime d) {
    final now = DateTime.now();
    final selectedDay = DateTime(d.year, d.month, d.day);
    final today = DateTime(now.year, now.month, now.day);
    final difference = today.difference(selectedDay).inDays;
    if (difference == 0) return context.l10n.translate('today');
    if (difference == 1) return context.l10n.translate('yesterday');
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NutritionCubit>();
    final date = cubit.selectedDate;
    final isToday = cubit.isToday;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: cubit.goToPreviousDay,
          child: Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              color: context.colors.bgElevated,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              color: context.colors.textMuted,
              size: 20,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          _formatLabel(context, date),
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
          ),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: isToday ? null : cubit.goToNextDay,
          child: Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              color: isToday ? context.colors.bgDeep : context.colors.bgElevated,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.chevron_left_rounded,
              color: isToday ? context.colors.borderMedium : context.colors.textMuted,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}