import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class CalorieSummaryCard extends StatelessWidget {
  const CalorieSummaryCard({
    super.key,
    required this.consumed,
    required this.goal,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final double consumed;
  final double goal;
  final double protein;
  final double carbs;
  final double fat;

  double get _progress => goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0;
  double get _remaining => (goal - consumed).clamp(0.0, goal);
  bool get _isOver => consumed > goal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceXL),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // ─── Ring ──────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('الأهداف اليومية',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: AppConstants.spaceM),
                    // Triple rings زي التصميم الجديد
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(80, 80),
                            painter: _RingPainter(
                              progress: _progress,
                              color: AppColors.accent,
                              trackColor: AppColors.bgElevated,
                              strokeWidth: 7,
                            ),
                          ),
                          CustomPaint(
                            size: const Size(62, 62),
                            painter: _RingPainter(
                              progress: (protein / 150).clamp(0.0, 1.0),
                              color: AppColors.danger,
                              trackColor: AppColors.bgElevated,
                              strokeWidth: 6,
                            ),
                          ),
                          CustomPaint(
                            size: const Size(46, 46),
                            painter: _RingPainter(
                              progress: (carbs / 300).clamp(0.0, 1.0),
                              color: AppColors.info,
                              trackColor: AppColors.bgElevated,
                              strokeWidth: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceM),
                    _StatLine(label: 'الحركة', value: '${consumed.toInt()}', goal: '${goal.toInt()}', color: AppColors.accent),
                    const SizedBox(height: AppConstants.spaceS),
                    _StatLine(label: 'بروتين', value: '${protein.toInt()}', goal: '150', color: AppColors.danger),
                    const SizedBox(height: AppConstants.spaceS),
                    _StatLine(label: 'كارب', value: '${carbs.toInt()}', goal: '300', color: AppColors.info),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spaceL),
          const Divider(color: AppColors.borderSubtle),
          const SizedBox(height: AppConstants.spaceL),

          // ─── Macros Row ──────────────────────────────────
          Row(
            children: [
              _MacroItem(
                label: 'بروتين',
                value: protein,
                color: AppColors.info,
              ),
              Container(width: 1, height: 30, color: AppColors.borderSubtle),
              _MacroItem(
                label: 'كارب',
                value: carbs,
                color: AppColors.warning,
              ),
              Container(width: 1, height: 30, color: AppColors.borderSubtle),
              _MacroItem(
                label: 'دهون',
                value: fat,
                color: AppColors.danger,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({
    required this.label,
    required this.value,
    required this.goal,
    required this.color,
  });

  final String label;
  final String value;
  final String goal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$value/$goal',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Row(
          children: [
            Text(label,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
            const SizedBox(width: AppConstants.spaceS),
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ],
        ),
      ],
    );
  }
}

class _MacroItem extends StatelessWidget {
  const _MacroItem({required this.label, required this.value, required this.color});
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '${value.toInt()}g',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}

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
        ..style = PaintingStyle.stroke,
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
