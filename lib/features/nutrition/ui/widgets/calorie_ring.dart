import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';

class NutritionCalorieRing extends StatelessWidget {
  const NutritionCalorieRing({
    super.key,
    required this.consumed,
    required this.goal,
    this.size = 110,
  });

  final double consumed;
  final double goal;
  final double size;

  double get _pct => goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0;
  bool get _isOver => consumed > goal;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: _pct,
              trackColor: AppColors.bgElevated,
              progressColor: _isOver ? AppColors.danger : AppColors.accent,
              strokeWidth: 9.r,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                consumed.toInt().toString(),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1.0,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'سعرة محروقة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 9.sp,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, basePaint..color = trackColor);

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        basePaint..color = progressColor,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.progressColor != progressColor;
}

class CalorieRing extends StatelessWidget {
  const CalorieRing({
    super.key,
    required this.consumed,
    required this.goal,
    this.size = 110,
  });

  final double consumed;
  final double goal;
  final double size;

  @override
  Widget build(BuildContext context) => NutritionCalorieRing(
    consumed: consumed,
    goal: goal,
    size: size,
  );
}

class MacroBar extends StatelessWidget {
  const MacroBar({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.progress,
  });

  final String label;
  final String unit;
  final double value;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10.sp,
                color: AppColors.textMuted,
              ),
            ),
            Text(
              '${value.toInt()} $unit',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: AppConstants.spaceXS.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusPill.r),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 4.h,
            color: color,
            backgroundColor: AppColors.bgElevated,
          ),
        ),
      ],
    );
  }
}