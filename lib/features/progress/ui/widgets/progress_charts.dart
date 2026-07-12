import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../data/models/progress_entity.dart';

class WeightChart extends StatelessWidget {
  const WeightChart({
    super.key,
    required this.points,
    this.height = 180,
  });

  final List<ChartPoint> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const _EmptyChart(label: 'لا توجد بيانات وزن');

    final minY = points.map((p) => p.y).reduce((a, b) => a < b ? a : b) - 2;
    final maxY = points.map((p) => p.y).reduce((a, b) => a > b ? a : b) + 2;

    return Container(
      padding: const EdgeInsets.all(UiConstants.spaceL),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(UiConstants.radiusL),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('تغير الوزن',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: UiConstants.spaceXL),
          SizedBox(
            height: height,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.borderSubtle,
                    strokeWidth: 0.5,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}',
                        style: AppTextStyles.labelSmall,
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: points.length <= 10,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= points.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          points[idx].label ?? '',
                          style: AppTextStyles.labelSmall,
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: points
                        .map((p) => FlSpot(p.x, p.y))
                        .toList(),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: AppColors.accent,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: points.length <= 15,
                      getDotPainter: (_, __, ___, ____) =>
                          FlDotCirclePainter(
                        radius: 3,
                        color: AppColors.accent,
                        strokeWidth: 1.5,
                        strokeColor: AppColors.bgDeep,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.accent.withValues(alpha: 0.2),
                          AppColors.accent.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.bgElevated,
                    getTooltipItems: (spots) => spots
                        .map((s) => LineTooltipItem(
                              '${s.y.toStringAsFixed(1)} كج',
                              AppTextStyles.labelSmall
                                  .copyWith(color: AppColors.accent),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WorkoutBarChart extends StatelessWidget {
  const WorkoutBarChart({
    super.key,
    required this.points,
    this.height = 160,
  });

  final List<ChartPoint> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty || points.every((p) => p.y == 0)) {
      return const _EmptyChart(label: 'لا توجد تمارين مسجلة');
    }

    final maxY = points.map((p) => p.y).reduce((a, b) => a > b ? a : b) + 1;

    return Container(
      padding: const EdgeInsets.all(UiConstants.spaceL),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(UiConstants.radiusL),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('التمارين المكتملة',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: UiConstants.spaceXL),
          SizedBox(
            height: height,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.borderSubtle,
                    strokeWidth: 0.5,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 1,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}',
                        style: AppTextStyles.labelSmall,
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                  ),
                  bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: points
                    .map((p) => BarChartGroupData(
                          x: p.x.toInt(),
                          barRods: [
                            BarChartRodData(
                              toY: p.y,
                              color: p.y > 0
                                  ? AppColors.accent
                                  : AppColors.bgElevated,
                              width: _barWidth(points.length),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: maxY,
                                color: AppColors.bgElevated,
                              ),
                            ),
                          ],
                        ))
                    .toList(),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.bgElevated,
                    getTooltipItem: (_, __, rod, ___) => BarTooltipItem(
                      '${rod.toY.toInt()} تمرين',
                      AppTextStyles.labelSmall
                          .copyWith(color: AppColors.accent),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _barWidth(int count) {
    if (count <= 7)  return 20;
    if (count <= 14) return 14;
    return 8;
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(UiConstants.radiusL),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bar_chart_rounded,
                color: AppColors.textMuted, size: 36),
            const SizedBox(height: UiConstants.spaceS),
            Text(label,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
