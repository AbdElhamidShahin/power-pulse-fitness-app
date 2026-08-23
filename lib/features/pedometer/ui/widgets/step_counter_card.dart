import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../logic/cubit/pedometer_cubit.dart';
import '../../logic/cubit/pedometer_state.dart';

class StepCounterCard extends StatelessWidget {
  const StepCounterCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PedometerCubit, PedometerState>(
      builder: (context, state) {
        return switch (state) {
          PedometerInitial()     => const _LoadingCard(),
          PedometerUnavailable() => const _UnavailableCard(),
          PedometerCounting()    => _CountingCard(state: state),
        };
      },
    );
  }
}

class _CountingCard extends StatelessWidget {
  const _CountingCard({required this.state});
  final PedometerCounting state;

  @override
  Widget build(BuildContext context) {
    final pct = state.progress;
    final reached = state.goalReached;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: reached
              ? AppColors.success.withOpacity(0.4)
              : AppColors.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────
          Row(
            children: [
              Text('👟', style: TextStyle(fontSize: 20.sp)),
              SizedBox(width: 8.w),
              Text(
                'خطواتك اليوم',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
              const Spacer(),
              if (reached)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.successDim,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'هدف ✓',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10.sp,
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _format(state.steps),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w900,
                  color: reached ? AppColors.success : AppColors.accent,
                  height: 1.0,
                ),
              ),
              SizedBox(width: 6.w),
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Text(
                  '/ ${_format(state.goal)}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 7.h,
              backgroundColor: AppColors.bgElevated,
              valueColor: AlwaysStoppedAnimation<Color>(
                reached ? AppColors.success : AppColors.accent,
              ),
            ),
          ),
          SizedBox(height: 6.h),

          Text(
            reached
                ? '🎉 تجاوزت هدفك اليومي!'
                : 'باقي ${_format(state.goal - state.steps)} خطوة للهدف',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.sp,
              color: reached ? AppColors.success : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _format(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}ك';
    }
    return n.toString();
  }
}

// ─── Loading ──────────────────────────────────────────────────────────
class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110.h,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
    );
  }
}

class _UnavailableCard extends StatelessWidget {
  const _UnavailableCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Text('👟', style: TextStyle(fontSize: 24.sp)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'عداد الخطوات',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'الجهاز لا يدعم هذه الميزة أو تحتاج لمنح الإذن',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
