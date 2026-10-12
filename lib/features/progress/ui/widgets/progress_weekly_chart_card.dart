import 'package:flutter/material.dart';
import 'package:power_pulse/core/localization/app_localizations.dart';
import 'package:power_pulse/core/theme/app_theme_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:power_pulse/core/theme/app_colors.dart';
import '../../data/models/progress_entity.dart';

class ProgressWeeklyChartCard extends StatelessWidget {
  const ProgressWeeklyChartCard({super.key, required this.points});

  final List<ChartPoint> points;

  bool get _hasRealData => points.any((p) => p.y > 0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.weeklyWorkouts,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: context.colors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 16.h),
          if (_hasRealData)
            SizedBox(
              height: 100.h,
              child: _WeeklyBarChart(points: points),
            )
          else
            _ChartEmptyState(),
        ],
      ),
    );
  }
}

class _ChartEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.h,
      decoration: BoxDecoration(
        color: context.colors.bgDeep,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: context.colors.borderSubtle,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🏋️',
              style: TextStyle(fontSize: 24.sp),
            ),
            SizedBox(height: 6.h),
            Text(
              context.l10n.chartEmptyMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.sp,
                color: context.colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({required this.points});

  final List<ChartPoint> points;

  @override
  Widget build(BuildContext context) {
    final maxY = points.fold(0.0, (m, p) => p.y > m ? p.y : m);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (i) {
        final point =
            i < points.length ? points[i] : ChartPoint(x: i.toDouble(), y: 0);
        final hasWorkout = point.y > 0;
        final heightFraction = maxY > 0 ? (point.y / maxY) : 0.0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 300 + (i * 50)),
              width: 28.w,
              height:
                  hasWorkout ? (60.h * heightFraction).clamp(20.h, 60.h) : 4.h,
              decoration: BoxDecoration(
                color: hasWorkout
                    ? AppColors.accent
                    : context.colors.borderSubtle,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              context.l10n.dayLettersFriFirst[i],
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: context.colors.textMuted,
              ),
            ),
          ],
        );
      }),
    );
  }
}
