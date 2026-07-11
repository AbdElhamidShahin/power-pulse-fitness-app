import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/ui_constants.dart';

/// دائرة السعرات في أعلى شاشة التغذية
class CalorieRing extends StatelessWidget {
  const CalorieRing({
    super.key,
    required this.consumed,
    required this.goal,
    this.size = 160,
  });

  final double consumed;
  final double goal;
  final double size;

  @override
  Widget build(BuildContext context) {
    final progress = (consumed / goal).clamp(0.0, 1.0);
    final remaining = (goal - consumed).clamp(0.0, goal);
    final isOver = consumed > goal;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ring
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: progress,
              trackColor: AppColors.bgElevated,
              progressColor: isOver ? AppColors.danger : AppColors.accent,
              strokeWidth: 10,
            ),
          ),
          // Center text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                consumed.toInt().toString(),
                style: AppTextStyles.statNumber.copyWith(fontSize: 28),
              ),
              Text(
                'من ${goal.toInt()}',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 2),
              Text(
                isOver
                    ? 'تجاوزت الهدف!'
                    : '${remaining.toInt()} متبقي',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isOver ? AppColors.danger : AppColors.accent,
                  fontSize: 10,
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
    const startAngle = -math.pi / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Track
    canvas.drawCircle(center, radius, trackPaint);

    // Progress
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.progressColor != progressColor;
}

/// بار صغيرة للماكروز — بروتين، كارب، دهون
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
  final double value;
  final String unit;
  final Color color;
  final double progress; // 0.0 → 1.0

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.labelSmall),
            Text(
              '${value.toInt()}$unit',
              style: AppTextStyles.labelSmall.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: UiConstants.spaceXS),
        ClipRRect(
          borderRadius: BorderRadius.circular(UiConstants.radiusPill),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 4,
            color: color,
            backgroundColor: AppColors.bgElevated,
          ),
        ),
      ],
    );
  }
}
