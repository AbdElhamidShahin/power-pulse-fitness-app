import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../logic/cubit/pedometer_cubit.dart';
import '../../logic/cubit/pedometer_state.dart';

// Step counter card shown on the home screen.
// Shows today's steps, progress bar, and goal.
// Falls back to a helpful message when the sensor is unavailable.
class StepCounterCard extends StatelessWidget {
  const StepCounterCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PedometerCubit, PedometerState>(
      builder: (_, state) => switch (state) {
        PedometerInitial()     => const _LoadingCard(),
        PedometerUnavailable() => const _UnavailableCard(),
        PedometerCounting()    => _CountingCard(state: state),
      },
    );
  }
}

// Shows live step count with a progress bar toward the daily goal.
class _CountingCard extends StatelessWidget {
  const _CountingCard({required this.state});
  final PedometerCounting state;

  String _fmt(int n) => n >= 1000
      ? '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}ك'
      : n.toString();

  @override
  Widget build(BuildContext context) {
    final reached = state.goalReached;
    final color   = reached ? AppColors.success : AppColors.accent;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color:        AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: reached ? AppColors.success.withOpacity(0.4) : AppColors.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(children: [
            Text('👟', style: TextStyle(fontSize: 20.sp)),
            SizedBox(width: 8.w),
            Text(
              AppStrings.pedometerSteps,
              style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textMuted, fontSize: 13.sp),
            ),
            const Spacer(),
            if (reached)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color:        AppColors.successDim,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text('هدف ✓',
                  style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.success, fontSize: 10.sp)),
              ),
          ]),

          SizedBox(height: 10.h),

          // Step count + goal
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              _fmt(state.steps),
              style: AppTextStyles.displaySmall.copyWith(
                  color: color, fontSize: 32.sp, height: 1.0),
            ),
            SizedBox(width: 6.w),
            Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Text(
                '/ ${_fmt(state.goal)}',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted, fontSize: 13.sp),
              ),
            ),
          ]),

          SizedBox(height: 10.h),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value:           state.progress,
              minHeight:       7.h,
              backgroundColor: AppColors.bgElevated,
              valueColor:      AlwaysStoppedAnimation<Color>(color),
            ),
          ),

          SizedBox(height: 6.h),

          // Remaining text
          Text(
            reached
                ? '🎉 تجاوزت هدفك اليومي!'
                : 'باقي ${_fmt(state.goal - state.steps)} خطوة للهدف',
            style: AppTextStyles.bodySmall.copyWith(
                color: reached ? AppColors.success : AppColors.textMuted,
                fontSize: 11.sp),
          ),
        ],
      ),
    );
  }
}

// Loading skeleton shown before the first step event arrives.
class _LoadingCard extends StatelessWidget {
  const _LoadingCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110.h,
      decoration: BoxDecoration(
        color:        AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
    );
  }
}

// Shown when the device sensor is unavailable or permission was denied.
class _UnavailableCard extends StatelessWidget {
  const _UnavailableCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color:        AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(children: [
        Text('👟', style: TextStyle(fontSize: 24.sp)),
        SizedBox(width: 12.w),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.pedometerDenied,
              style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                  fontSize: 14.sp),
            ),
            SizedBox(height: 2.h),
            Text(
              AppStrings.pedometerGrantMsg,
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted, fontSize: 11.sp),
            ),
          ],
        )),
      ]),
    );
  }
}
