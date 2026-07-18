import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/app_constants.dart';

// ════════════════════════════════════════════════════════════════
// NutritionCalorieRing — حلقة السعرات
// مطابقة للصورة: حلقة خضراء رفيعة + رقم السعرات في المنتصف
// + نص "kcal eaten" تحت الرقم
// ════════════════════════════════════════════════════════════════
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
      width:  size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ─── الحلقة ───────────────────────────────────────
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress:      _pct,
              trackColor:    AppColors.bgElevated,
              progressColor: _isOver ? AppColors.danger : AppColors.accent,
              strokeWidth:   9,
            ),
          ),

          // ─── النص في المنتصف ──────────────────────────────
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                consumed.toInt().toString(),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'kcal eaten',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 9,
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

// ─── Ring Painter ─────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor, progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final basePaint = Paint()
      ..style      = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap  = StrokeCap.round;

    // Track (رمادي فاتح)
    canvas.drawCircle(center, radius, basePaint..color = trackColor);

    // Progress (أخضر أو أحمر)
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

// ════════════════════════════════════════════════════════════════
// CalorieRing — (اسم مبسّط للاستخدام من nutrition_screen القديم)
// ════════════════════════════════════════════════════════════════
class CalorieRing extends StatelessWidget {
  const CalorieRing({
    super.key,
    required this.consumed,
    required this.goal,
    this.size = 110,
  });

  final double consumed, goal;
  final double size;

  @override
  Widget build(BuildContext context) => NutritionCalorieRing(
        consumed: consumed,
        goal:     goal,
        size:     size,
      );
}

// ════════════════════════════════════════════════════════════════
// MacroBar — شريط ماكرو مستقل (للاستخدام من الملفات الأخرى)
// ════════════════════════════════════════════════════════════════
class MacroBar extends StatelessWidget {
  const MacroBar({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.progress,
  });

  final String label, unit;
  final double value, progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${value.toInt()} $unit',
                style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 10,
                    fontWeight: FontWeight.w600, color: color)),
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Cairo', fontSize: 10,
                    color: AppColors.textMuted)),
          ],
        ),
        const SizedBox(height: AppConstants.spaceXS),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusPill),
          child: LinearProgressIndicator(
            value:           progress.clamp(0.0, 1.0),
            minHeight:       4,
            color:           color,
            backgroundColor: AppColors.bgElevated,
          ),
        ),
      ],
    );
  }
}
