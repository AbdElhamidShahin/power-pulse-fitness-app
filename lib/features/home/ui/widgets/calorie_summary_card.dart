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

  double get _progress => (consumed / goal).clamp(0.0, 1.0);
  double get _remaining => (goal - consumed).clamp(0.0, goal);
  bool get _isOver => consumed > goal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceL),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('السعرات اليوم',
                  style: Theme.of(context).textTheme.headlineSmall),
              const Spacer(),
              Text(
                _isOver ? 'تجاوزت الهدف!' : '${_remaining.toInt()} متبقي',
                style: AppTextStyles.labelSmall.copyWith(
                  color: _isOver ? AppColors.danger : AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceL),

          // Progress bar
          Row(
            children: [
              Text(
                consumed.toInt().toString(),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '/ ${goal.toInt()} سعرة',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceM),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusPill),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 8,
              color: _isOver ? AppColors.danger : AppColors.accent,
              backgroundColor: AppColors.bgElevated,
            ),
          ),
          const SizedBox(height: AppConstants.spaceL),

          // Macro row
          Row(
            children: [
              _MacroItem(
                  label: 'بروتين', value: protein, color: AppColors.info),
              _MacroItem(
                  label: 'كارب', value: carbs, color: AppColors.warning),
              _MacroItem(
                  label: 'دهون', value: fat, color: AppColors.danger),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroItem extends StatelessWidget {
  const _MacroItem({
    required this.label,
    required this.value,
    required this.color,
  });

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
              fontSize: 15,
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
