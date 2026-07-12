import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../data/models/progress_entity.dart';

class WeightHistoryList extends StatelessWidget {
  const WeightHistoryList({
    super.key,
    required this.entries,
    required this.onDelete,
  });

  final List<WeightEntry> entries;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.spaceXXL),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.monitor_weight_outlined,
                  color: AppColors.textMuted, size: 36),
              const SizedBox(height: AppConstants.spaceS),
              Text('لم تسجل وزنك بعد',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textMuted)),
            ],
          ),
        ),
      );
    }

    final reversed = entries.reversed.take(10).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.spaceL),
            child: Text('سجل الوزن',
                style: Theme.of(context).textTheme.headlineSmall),
          ),
          const Divider(height: 0.5, color: AppColors.borderSubtle),
          ...reversed.map(
            (entry) => Dismissible(
              key: Key(entry.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: AppConstants.spaceL),
                color: AppColors.danger.withValues(alpha: 0.12),
                child: const Icon(Icons.delete_rounded,
                    color: AppColors.danger, size: AppConstants.iconM),
              ),
              onDismissed: (_) => onDelete(entry.id),
              child: _WeightRow(entry: entry),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightRow extends StatelessWidget {
  const _WeightRow({required this.entry});
  final WeightEntry entry;

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceL,
        vertical: AppConstants.spaceM,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(entry.date),
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textPrimary),
                ),
                if (entry.note != null)
                  Text(entry.note!, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Text(
            '${entry.weight.toStringAsFixed(1)} كج',
            style: AppTextStyles.titleMedium
                .copyWith(color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}
