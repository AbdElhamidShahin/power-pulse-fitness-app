import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../logic/cubit/home_cubit.dart';
import '../../logic/cubit/home_state.dart';
import 'RingPainter.dart';

class DailyGoalsCard extends StatelessWidget {
  const DailyGoalsCard({
    super.key,
    required this.calories,
    required this.caloriesGoal,
    required this.protein,
    required this.minutes,
  });

  final double calories;
  final double caloriesGoal;
  final double protein;
  final double minutes;

  @override
  Widget build(BuildContext context) {
    final workoutMins = () {
      final state = context.watch<HomeCubit>().state;
      if (state is HomeLoaded)
        return state.summary.todayWorkoutMinutes.toDouble();
      return minutes;
    }();

    final movePct = (calories / caloriesGoal.clamp(1, 9999)).clamp(0.0, 1.0);
    final exPct = (workoutMins / 60).clamp(0.0, 1.0);
    final standPct = (protein / 150).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الأهداف اليومية',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _GoalRow(
                      dot: AppColors.accent,
                      label: 'الحركة',
                      value: calories.toInt(),
                      goal: caloriesGoal.toInt(),
                      unit: 'سعر',
                    ),
                    SizedBox(height: 12.h),
                    _GoalRow(
                      dot: AppColors.danger,
                      label: 'التمرين',
                      value: workoutMins.toInt(),
                      goal: 60,
                      unit: 'دقيقة',
                      // يظهر ✓ لو حقق الهدف
                      done: workoutMins >= 60,
                    ),
                    SizedBox(height: 12.h),
                    _GoalRow(
                      dot: AppColors.info,
                      label: 'بروتين',
                      value: protein.toInt(),
                      goal: 150,
                      unit: 'جم',
                    ),
                  ],
                ),
              ),
              SizedBox(width: 14.w),
              SizedBox(
                width: 90.r,
                height: 90.r,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size(90.r, 90.r),
                      painter: RingPainter(
                        progress: movePct,
                        color: AppColors.accent,
                        trackColor: const Color(0xFFE8E8E8),
                        strokeWidth: 8.w,
                      ),
                    ),
                    CustomPaint(
                      size: Size(68.r, 68.r),
                      painter: RingPainter(
                        progress: exPct,
                        color: AppColors.danger,
                        trackColor: const Color(0xFFE8E8E8),
                        strokeWidth: 7.w,
                      ),
                    ),
                    CustomPaint(
                      size: Size(48.r, 48.r),
                      painter: RingPainter(
                        progress: standPct,
                        color: AppColors.info,
                        trackColor: const Color(0xFFE8E8E8),
                        strokeWidth: 6.w,
                      ),
                    ),
                    // نسبة الإنجاز الكلية في المنتصف
                    Text(
                      '${((movePct + exPct + standPct) / 3 * 100).toInt()}%',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.dot,
    required this.label,
    required this.value,
    required this.goal,
    this.unit = '',
    this.done = false,
  });

  final Color dot;
  final String label;
  final int value;
  final int goal;
  final String unit;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8.r,
              height: 8.r,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                letterSpacing: 0.3,
              ),
            ),
            if (done) ...[
              SizedBox(width: 4.w),
              Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 14.r),
            ],
          ],
        ),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontFamily: 'Cairo'),
            children: [
              TextSpan(
                text: '$goal',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFFCCCCCC),
                ),
              ),
              TextSpan(
                text: '/$value',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: done ? AppColors.success : dot,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
