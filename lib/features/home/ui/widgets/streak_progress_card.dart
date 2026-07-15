import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// Streak + Daily Progress Card — Dark card بالـ ring
/// جديد في Design v2 — يحل محل quick_stats_row للـ streak
class StreakProgressCard extends StatelessWidget {
  const StreakProgressCard({
    super.key,
    required this.currentStreak,
    required this.dailyProgress, // 0.0 → 1.0
  });

  final int currentStreak;
  final double dailyProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceXL),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
      ),
      child: Row(
        children: [
          // ─── Ring دائري ──────────────────────────────────
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(64, 64),
                  painter: _CircleRingPainter(
                    progress: dailyProgress,
                    color: AppColors.accent,
                    trackColor: AppColors.bgDarkSub,
                    strokeWidth: 6,
                  ),
                ),
                Text(
                  '${(dailyProgress * 100).toInt()}%',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppConstants.spaceXL),

          // ─── النص ────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'السلسلة الحالية',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 4),
                    Text(
                      '$currentStreak يوم',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textOnDark,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ring Painter ──────────────────────────────────────────────
class _CircleRingPainter extends CustomPainter {
  const _CircleRingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2;
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0, math.pi * 2, false,
      paint..color = trackColor,
    );
    // Progress
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, math.pi * 2 * progress.clamp(0.0, 1.0), false,
        paint..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_CircleRingPainter old) =>
      old.progress != progress || old.color != color;
}
