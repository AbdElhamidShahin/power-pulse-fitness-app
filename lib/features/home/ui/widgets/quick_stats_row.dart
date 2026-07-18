import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class QuickStatsRow extends StatelessWidget {
  const QuickStatsRow({
    super.key,
    required this.weeklyWorkouts,
    required this.todayMinutes,
    required this.hasWorkedOutToday,
    this.currentStreak = 0,
  });

  final int weeklyWorkouts;
  final int todayMinutes;
  final bool hasWorkedOutToday;
  final int currentStreak;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ─── Streak Card (داكن زي التصميم) ──────────────────
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceXL,
            vertical: AppConstants.spaceL,
          ),
          decoration: BoxDecoration(
            color: AppColors.bgDark,
            borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          ),
          child: Row(
            children: [
              // Progress Ring
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(60, 60),
                      painter: _RingPainter(
                        progress: (currentStreak / 30).clamp(0.0, 1.0),
                        color: AppColors.accent,
                        trackColor: const Color(0xFF333333),
                        strokeWidth: 5,
                      ),
                    ),
                    Text(
                      '${((currentStreak / 30) * 100).toInt()}%',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spaceL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'السلسلة الحالية',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: const Color(0xFF888888)),
                    ),
                    Text(
                      '$currentStreak يوم 🔥',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textOnDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppConstants.spaceM),

        // ─── وقت النشاط + السعرات ─────────────────────────────
        Row(
          children: [
            // وقت النشاط (داكن)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppConstants.spaceL),
                decoration: BoxDecoration(
                  color: AppColors.bgDark,
                  borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'وقت النشاط',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: const Color(0xFF888888), fontSize: 10),
                    ),
                    const SizedBox(height: AppConstants.spaceXS),
                    Text(
                      hasWorkedOutToday ? '$todayMinutes' : '0',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accent,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'دقيقة اليوم',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: const Color(0xFF888888), fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: AppConstants.spaceM),

            // التمارين الأسبوعية (فاتح)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppConstants.spaceL),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'التمارين الأسبوعية',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textMuted, fontSize: 10),
                    ),
                    const SizedBox(height: AppConstants.spaceXS),
                    Text(
                      '$weeklyWorkouts',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'تمرين هذا الأسبوع',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textMuted, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Ring Painter ─────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    this.strokeWidth = 6,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0, math.pi * 2, false,
      Paint()
        ..color = trackColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
