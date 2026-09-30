import 'dart:math' as math;
import 'package:flutter/material.dart';

class RingPainter extends CustomPainter {
  const RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    this.strokeWidth = 6,
  });

  final double progress;
  final double strokeWidth;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - strokeWidth) / 2;
    final p = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(c, r, p..color = trackColor);
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        p..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(RingPainter oldDelegate) => oldDelegate.progress != progress;
}