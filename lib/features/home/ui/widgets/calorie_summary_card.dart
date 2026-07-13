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
        border: Border.all(color: AppColors.borderAccent),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // ─── Ring ───────────────────────────────────
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(100, 100),
                      painter: _RingPainter(
                        progress: _progress,
                        color: _isOver ? AppColors.danger : AppColors.accent,
                        trackColor: AppColors.bgElevated,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          consumed.toInt().toString(),
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            height: 1.0,
                          ),
                        ),
                        Text('سعرة', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppConstants.spaceXL),

              // ─── Info ────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('السعرات اليومية',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: AppConstants.spaceS),
                    _InfoRow(
                      label: 'الهدف',
                      value: '${goal.toInt()} سعرة',
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppConstants.spaceXS),
                    _InfoRow(
                      label: _isOver ? 'تجاوزت' : 'متبقي',
                      value: '${_isOver ? (consumed - goal).toInt() : _remaining.toInt()} سعرة',
                      color: _isOver ? AppColors.danger : AppColors.accent,
                    ),
                    const SizedBox(height: AppConstants.spaceM),
                    // Progress bar thin
                    ClipRRect(
                      borderRadius:
                      BorderRadius.circular(AppConstants.radiusPill),
                      child: LinearProgressIndicator(
                        value: _progress,
                        minHeight: 5,
                        color:
                        _isOver ? AppColors.danger : AppColors.accent,
                        backgroundColor: AppColors.bgElevated,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spaceL),
          const Divider(color: AppColors.borderSubtle, height: 1),
          const SizedBox(height: AppConstants.spaceL),

          // ─── Macros Row ───────────────────────────────────
          Row(
            children: [
              _MacroItem(label: 'بروتين', value: protein, color: AppColors.info),
              _Divider(),
              _MacroItem(label: 'كارب', value: carbs, color: AppColors.warning),
              _Divider(),
              _MacroItem(label: 'دهون', value: fat, color: AppColors.danger),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        const SizedBox(width: AppConstants.spaceXS),
        Text(value,
            style: AppTextStyles.labelSmall.copyWith(color: color)),
      ],
    );
  }
}

class _MacroItem extends StatelessWidget {
  const _MacroItem(
      {required this.label, required this.value, required this.color});
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

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      width: 1, height: 30, color: AppColors.borderSubtle);
}

// ─── Ring Painter ─────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });
  final double progress;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 8.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = trackColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    if (progress > 0) {
      // Progress
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
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
