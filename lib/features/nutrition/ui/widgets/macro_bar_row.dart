import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/app_constants.dart';

// ════════════════════════════════════════════════════════════════
// MacroBarRow — شريط الماكرو
// مطابق للصورة: Label يمين | "current / goal" يسار | بار ملون
// مثال: Protein    142g / 180g  [══════░░░]
// ════════════════════════════════════════════════════════════════
class MacroBarRow extends StatelessWidget {
  const MacroBarRow({
    super.key,
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
  });

  final String label;
  final double current, goal;
  final Color color;

  double get _pct => goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ─── Label + Values ────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // القيم يسار
            Text(
              '${current.toInt()}g / ${goal.toInt()}g',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            // التسمية يمين
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // ─── Progress Bar ──────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusPill),
          child: LinearProgressIndicator(
            value:           _pct,
            minHeight:       5,
            color:           color,
            backgroundColor: AppColors.bgElevated,
          ),
        ),
      ],
    );
  }
}
