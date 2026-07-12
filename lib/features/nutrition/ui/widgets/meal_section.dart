import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../data/models/food_entity.dart';

class MealSection extends StatelessWidget {
  const MealSection({
    super.key,
    required this.mealType,
    required this.entries,
    required this.onAddTap,
    required this.onDeleteEntry,
  });

  final MealType mealType;
  final List<MealEntry> entries;
  final VoidCallback onAddTap;
  final ValueChanged<String> onDeleteEntry;

  static IconData _icon(MealType t) => switch (t) {
        MealType.breakfast => Icons.wb_sunny_rounded,
        MealType.lunch     => Icons.lunch_dining_rounded,
        MealType.dinner    => Icons.nightlight_round,
        MealType.snack     => Icons.apple_rounded,
      };

  double get _totalCalories =>
      entries.fold(0, (s, e) => s + e.calories);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppConstants.spaceL),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accentDim,
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Icon(
                    _icon(mealType),
                    color: AppColors.accent,
                    size: AppConstants.iconS,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mealType.labelAr,
                          style: AppTextStyles.titleMedium),
                      if (entries.isNotEmpty)
                        Text(
                          '${_totalCalories.toInt()} سعرة',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.accent),
                        ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onAddTap,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.accentDim,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusS),
                      border: Border.all(color: AppColors.borderAccent),
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: AppColors.accent, size: 18),
                  ),
                ),
              ],
            ),
          ),

          // Entries
          if (entries.isNotEmpty) ...[
            const Divider(height: 0.5, color: AppColors.borderSubtle),
            ...entries.map(
              (entry) => _MealEntryRow(
                entry: entry,
                onDelete: () => onDeleteEntry(entry.id),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MealEntryRow extends StatelessWidget {
  const _MealEntryRow({required this.entry, required this.onDelete});
  final MealEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppConstants.spaceL),
        color: AppColors.danger.withValues(alpha: 0.15),
        child: const Icon(Icons.delete_rounded,
            color: AppColors.danger, size: AppConstants.iconM),
      ),
      onDismissed: (_) => onDelete(),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceL,
          vertical: AppConstants.spaceM,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.food.name,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${entry.quantity.toInt()}g',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.calories.toInt()} سعرة',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  'ب${entry.protein.toInt()} | ك${entry.carbs.toInt()} | د${entry.fat.toInt()}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
