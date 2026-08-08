import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../data/models/food_entity.dart';
import 'calorie_ring.dart';
import 'macro_bar_row.dart';

class CalorieSummaryCard extends StatelessWidget {
  const CalorieSummaryCard({super.key, required this.daily});

  final DailyNutrition daily;

  @override
  Widget build(BuildContext context) {
    final isOverGoal = daily.totalCalories > daily.calorieGoal;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp),
                        children: [
                          const TextSpan(
                            text: 'الهدف: ',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                          TextSpan(
                            text: '${daily.calorieGoal.toInt()} سعرة',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp),
                        children: [
                          const TextSpan(
                            text: 'المتبقي: ',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                          TextSpan(
                            text: '${daily.caloriesLeft.toInt()} سعرة',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isOverGoal
                                  ? AppColors.danger
                                  : AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    MacroBarRow(
                      label: 'بروتين',
                      current: daily.totalProtein,
                      goal: daily.proteinGoal,
                      color: AppColors.info,
                    ),
                    SizedBox(height: 6.h),
                    MacroBarRow(
                      label: 'كارب',
                      current: daily.totalCarbs,
                      goal: daily.carbsGoal,
                      color: AppColors.warning,
                    ),
                    SizedBox(height: 6.h),
                    MacroBarRow(
                      label: 'دهون',
                      current: daily.totalFat,
                      goal: daily.fatGoal,
                      color: AppColors.danger,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 24.w),
              NutritionCalorieRing(
                consumed: daily.totalCalories,
                goal: daily.calorieGoal,
                size: 100.r,
              ),
            ],
          ),
        ),
        if (isOverGoal) ...[
          SizedBox(height: 8.h),
          _OverGoalWarning(
            surplus: (daily.totalCalories - daily.calorieGoal).toInt(),
          ),
        ],
      ],
    );
  }
}

class _OverGoalWarning extends StatelessWidget {
  const _OverGoalWarning({required this.surplus});

  final int surplus;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.dangerDim,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Text('⚠️', style: TextStyle(fontSize: 14.sp)),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'تخطيت هدف السعرات بـ $surplus سعرة',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}