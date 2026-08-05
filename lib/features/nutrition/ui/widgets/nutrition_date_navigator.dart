import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../logic/cubit/nutrition_cubit.dart';

class NutritionDateNavigator extends StatelessWidget {
  const NutritionDateNavigator({super.key});

  String _formatLabel(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d).inDays;
    if (diff == 0) return 'اليوم';
    if (diff == 1) return 'امبارح';
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
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          _formatLabel(date),
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: isToday ? null : cubit.goToNextDay,
          child: Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              color: isToday ? AppColors.bgDeep : AppColors.bgElevated,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.chevron_left_rounded,
              color: isToday ? AppColors.borderMedium : AppColors.textMuted,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}