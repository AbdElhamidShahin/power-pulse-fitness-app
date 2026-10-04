import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme_colors.dart';
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
          PedometerUnavailable() => _UnavailableCard(state: state),
          PedometerCounting()    => _CountingCard(state: state),
        };
      },
    );
  }
}

// ─── Counting Card ────────────────────────────────────────────────────
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
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: reached
              ? AppColors.success.withOpacity(0.4)
              : context.colors.borderSubtle,
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
                  color: context.colors.textMuted,
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

          // ── Steps + Progress ─────────────────────────────────
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
                    color: context.colors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // ── Progress Bar ─────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 7.h,
              backgroundColor: context.colors.bgElevated,
              valueColor: AlwaysStoppedAnimation<Color>(
                reached ? AppColors.success : AppColors.accent,
              ),
            ),
          ),
          SizedBox(height: 6.h),

          // ── كم باقي ─────────────────────────────────────────
          Text(
            reached
                ? '🎉 تجاوزت هدفك اليومي!'
                : 'باقي ${_format(state.goal - state.steps)} خطوة للهدف',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.sp,
              color: reached ? AppColors.success : context.colors.textMuted,
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
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
    );
  }
}

// ─── Unavailable ──────────────────────────────────────────────────────
class _UnavailableCard extends StatelessWidget {
  const _UnavailableCard({required this.state});
  final PedometerUnavailable state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PedometerCubit>();
    final needsPermission = state.permissionDenied;
    final permanent = state.permanentlyDenied;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: context.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                        color: context.colors.textPrimary,
                      ),
                    ),
                    Text(
                      needsPermission
                          ? 'محتاجين إذن "النشاط البدني" عشان نعدّ خطواتك'
                          : 'الجهاز لا يدعم عداد الخطوات',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.sp,
                        color: context.colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (needsPermission) ...[
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: permanent
                    ? cubit.openSystemSettings
                    : cubit.retry,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  permanent ? 'فتح إعدادات التطبيق' : 'منح الإذن',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
