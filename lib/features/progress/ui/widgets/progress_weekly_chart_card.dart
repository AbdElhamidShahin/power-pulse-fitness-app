import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../data/models/progress_entity.dart';

class ProgressWeeklyChartCard extends StatelessWidget {
  const ProgressWeeklyChartCard({super.key, required this.points});

  final List<ChartPoint> points;

  @override
  Widget build(BuildContext context) {
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
            'تمارين هذا الأسبوع',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF8A8A8A),
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 100.h,
            child: _WeeklyBarChart(points: points),
          ),
        ],
      ),
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({required this.points});

  final List<ChartPoint> points;
  static const _days = ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];

  @override
  Widget build(BuildContext context) {
    final data = points.isNotEmpty
        ? points
        : List.generate(
      7,
          (i) => ChartPoint(
        x: i.toDouble(),
        y: [1.0, 1.0, 0.0, 1.0, 1.0, 0.0, 0.5][i],
      ),
    );

    final maxY = data.fold(0.0, (m, p) => p.y > m ? p.y : m);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (i) {
        final point =
        i < data.length ? data[i] : ChartPoint(x: i.toDouble(), y: 0);
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
                color: hasWorkout ? AppColors.accent : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              _days[i],
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8A8A8A),
              ),
            ),
          ],
        );
      }),
    );
  }
}