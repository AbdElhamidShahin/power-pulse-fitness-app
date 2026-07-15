import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// Daily Goals Card — Design v2 (من التصميم الثالث)
/// حلقات متداخلة على اليمين + أرقام ملونة على اليسار
class DailyGoalsCard extends StatelessWidget {
  const DailyGoalsCard({
    super.key,
    required this.moveCurrent,
    required this.moveGoal,
    required this.exerciseCurrent,
    required this.exerciseGoal,
    required this.standCurrent,
    required this.standGoal,
  });

  final int moveCurrent;
  final int moveGoal;
  final int exerciseCurrent;
  final int exerciseGoal;
  final int standCurrent;
  final int standGoal;

  double get _moveProgress =>
      moveGoal > 0 ? (moveCurrent / moveGoal).clamp(0.0, 1.0) : 0;
  double get _exerciseProgress =>
      exerciseGoal > 0 ? (exerciseCurrent / exerciseGoal).clamp(0.0, 1.0) : 0;
  double get _standProgress =>
      standGoal > 0 ? (standCurrent / standGoal).clamp(0.0, 1.0) : 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceL),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ─── Section title ─────────────────────────────
          Text('الأهداف اليومية',
              style: AppTextStyles.bodySmall
                  .copyWith(fontWeight: FontWeight.w700, fontSize: 11)),
          const SizedBox(height: AppConstants.spaceM),

          // ─── Rings + Numbers ───────────────────────────
          Row(
            children: [
              // Numbers (يسار)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _GoalRow(
                      label: 'الحركة',
                      current: moveCurrent,
                      goal: moveGoal,
                      color: AppColors.ringMove,
                    ),
                    const SizedBox(height: AppConstants.spaceM),
                    _GoalRow(
                      label: 'التمرين',
                      current: exerciseCurrent,
                      goal: exerciseGoal,
                      color: AppColors.ringExercise,
                    ),
                    const SizedBox(height: AppConstants.spaceM),
                    _GoalRow(
                      label: 'الوقوف',
                      current: standCurrent,
                      goal: standGoal,
                      color: AppColors.ringStand,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppConstants.spaceXL),

              // Stacked Rings (يمين)
              SizedBox(
                width: 88,
                height: 88,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // الحلقة الخارجية — حركة
                    CustomPaint(
                      size: const Size(88, 88),
                      painter: _RingPainter(
                        progress: _moveProgress,
                        color: AppColors.ringMove,
                        trackColor: AppColors.bgElevated,
                        strokeWidth: 8,
                      ),
                    ),
                    // الحلقة الوسطى — تمرين
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: CustomPaint(
                        size: const Size(60, 60),
                        painter: _RingPainter(
                          progress: _exerciseProgress,
                          color: AppColors.ringExercise,
                          trackColor: AppColors.bgElevated,
                          strokeWidth: 7,
                        ),
                      ),
                    ),
                    // الحلقة الداخلية — وقوف
                    Padding(
                      padding: const EdgeInsets.all(27),
                      child: CustomPaint(
                        size: const Size(34, 34),
                        painter: _RingPainter(
                          progress: _standProgress,
                          color: AppColors.ringStand,
                          trackColor: AppColors.bgElevated,
                          strokeWidth: 6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Goal Row ──────────────────────────────────────────────────
class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
  });

  final String label;
  final int current;
  final int goal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(fontFamily: 'Cairo'),
            children: [
              TextSpan(
                text: '$current',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              TextSpan(
                text: '/$goal',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.bgHighest,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: AppTextStyles.bodySmall
                .copyWith(fontWeight: FontWeight.w600, fontSize: 11)),
        const SizedBox(width: 6),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ─── Ring Painter ──────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  const _RingPainter({
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
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    const startAngle = -math.pi / 2;
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0, math.pi * 2, false,
      paint..color = trackColor,
    );
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        math.pi * 2 * progress.clamp(0.0, 1.0),
        false,
        paint..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
