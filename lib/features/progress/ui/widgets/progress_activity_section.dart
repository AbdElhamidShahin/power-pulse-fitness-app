import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../data/models/progress_entity.dart';

/// قسم "نشاطك اليومي" — بيجمع في مكان واحد البيانات اللي جاية من باقي
/// التطبيق: الخطوات (عداد الخطوات)، السعرات والمياه (التغذية)،
/// والتزامك بخطة التمرين.
class ProgressActivitySection extends StatelessWidget {
  const ProgressActivitySection({super.key, required this.summary});

  final ProgressSummary summary;

  // BUG 9 fix: التقويم المصري — السبت أول الأسبوع
  // weekday: Mon=1..Sat=6..Sun=7
  static const Map<int, String> _dayLetterMap = {
    1: 'ن', 2: 'ث', 3: 'ر', 4: 'خ', 5: 'ج', 6: 'س', 7: 'ح',
  };

  @override
  Widget build(BuildContext context) {
    final days = summary.dailyActivity;
    final hasAny = days.any((d) =>
        d.steps > 0 || d.caloriesIn > 0 || d.waterLiters > 0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: context.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نشاطك اليومي',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'من عداد الخطوات والتغذية وخطة التمرين',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.sp,
              color: context.colors.textMuted,
            ),
          ),
          SizedBox(height: 14.h),

          // ─── المتوسطات ─────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  emoji: '👟',
                  value: _fmt(summary.avgSteps.toDouble()),
                  label: 'متوسط الخطوات',
                  color: AppColors.accent,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _MiniStat(
                  emoji: '🍽',
                  value: _fmt(summary.avgCaloriesIn),
                  label: 'متوسط السعرات',
                  color: AppColors.warning,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _MiniStat(
                  emoji: '💧',
                  value: '${summary.avgWaterLiters.toStringAsFixed(1)} ل',
                  label: 'متوسط المياه',
                  color: AppColors.info,
                ),
              ),
            ],
          ),

          // ─── التزام بالخطة ─────────────────────────────
          if (summary.plannedDays > 0) ...[
            SizedBox(height: 16.h),
            Row(
              children: [
                Text(
                  'التزامك بخطة التمرين (آخر 7 أيام)',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${summary.plannedDaysDone}/${summary.plannedDays}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: LinearProgressIndicator(
                value: summary.planAdherence,
                minHeight: 7.h,
                backgroundColor: context.colors.bgElevated,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.success),
              ),
            ),
          ],

          // ─── آخر 7 أيام ────────────────────────────────
          SizedBox(height: 16.h),
          Text(
            'آخر 7 أيام',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          if (!hasAny)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                'سجّل وجباتك ومشي النهارده وهتلاقي نشاطك هنا 👌',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11.sp,
                  color: context.colors.textMuted,
                ),
              ),
            )
          else
            _WeekBars(days: days, goal: summary.calorieGoal),
        ],
      ),
    );
  }

  static String _fmt(double v) {
    if (v <= 0) return '0';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}ك';
    return v.round().toString();
  }

  static String letterFor(DateTime d) => _dayLetterMap[d.weekday] ?? '';
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  final String emoji;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
      decoration: BoxDecoration(
        color: context.colors.bgElevated,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: 16.sp)),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 9.sp,
              color: context.colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// أعمدة بسيطة: الخطوات (أخضر) + السعرات (برتقالي) لكل يوم
class _WeekBars extends StatelessWidget {
  const _WeekBars({required this.days, required this.goal});

  final List<DailyActivity> days;
  final double? goal;

  @override
  Widget build(BuildContext context) {
    final maxSteps = days.fold<int>(0, (m, d) => d.steps > m ? d.steps : m);
    final maxCal = days.fold<double>(
      (goal ?? 0),
      (m, d) => d.caloriesIn > m ? d.caloriesIn : m,
    );
    final barMax = 70.h;

    return SizedBox(
      height: barMax + 34.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final d in days)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Bar(
                        height: maxSteps == 0
                            ? 0
                            : barMax * (d.steps / maxSteps),
                        color: AppColors.accent,
                      ),
                      SizedBox(width: 3.w),
                      _Bar(
                        height: maxCal <= 0
                            ? 0
                            : barMax * (d.caloriesIn / maxCal),
                        color: AppColors.warning,
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    ProgressActivitySection.letterFor(d.date),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textMuted,
                    ),
                  ),
                  if (d.workoutMinutes > 0)
                    Text(
                      '🏋️',
                      style: TextStyle(fontSize: 9.sp),
                    )
                  else
                    SizedBox(height: 12.sp),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.height, required this.color});
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 8.w,
        height: height < 3 ? 3 : height,
        decoration: BoxDecoration(
          color: height < 3 ? color.withOpacity(0.25) : color,
          borderRadius: BorderRadius.circular(4.r),
        ),
      );
}
