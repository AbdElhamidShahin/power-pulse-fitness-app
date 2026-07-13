import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/workout_session_entity.dart';
import 'set_row_widget.dart';

class ExerciseLoggerCard extends StatelessWidget {
  const ExerciseLoggerCard({
    super.key,
    required this.exercise,
    required this.onUpdateSet,
    required this.onAddSet,
    required this.onRemoveSet,
    required this.onRemoveExercise,
  });

  final SessionExercise exercise;
  final void Function({required String exerciseId, required int setIndex,
      int? reps, double? weight, bool? isCompleted}) onUpdateSet;
  final VoidCallback onAddSet;
  final void Function(int setIndex) onRemoveSet;
  final VoidCallback onRemoveExercise;

  @override
  Widget build(BuildContext context) {
    final isFullyDone = exercise.isFullyDone;
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spaceM),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: isFullyDone ? AppColors.borderAccent : AppColors.borderSubtle,
          width: isFullyDone ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spaceL,
              AppConstants.spaceL,
              AppConstants.spaceM,
              AppConstants.spaceM,
            ),
            child: Row(
              children: [
                // Body part chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceS,
                      vertical: AppConstants.spaceXS),
                  decoration: BoxDecoration(
                    color: AppColors.accentDim,
                    borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                  ),
                  child: Text(exercise.bodyPart,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.accent)),
                ),
                const SizedBox(width: AppConstants.spaceS),
                Expanded(
                  child: Text(
                    exercise.exerciseName,
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Progress
                Text(
                  '${exercise.completedSets}/${exercise.sets.length}',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(width: AppConstants.spaceS),
                // Remove exercise
                GestureDetector(
                  onTap: onRemoveExercise,
                  child: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.textMuted, size: 20),
                ),
              ],
            ),
          ),

          // ─── Sets Header ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceL),
            child: Row(
              children: [
                const SizedBox(width: 28),
                const SizedBox(width: AppConstants.spaceM),
                Expanded(
                  child: Text('الوزن', style: AppTextStyles.labelSmall,
                      textAlign: TextAlign.center),
                ),
                const SizedBox(width: AppConstants.spaceM),
                Expanded(
                  child: Text('التكرارات', style: AppTextStyles.labelSmall,
                      textAlign: TextAlign.center),
                ),
                const SizedBox(width: AppConstants.spaceM),
                const SizedBox(width: 36),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spaceS),

          // ─── Sets ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceL),
            child: Column(
              children: exercise.sets.asMap().entries.map((entry) {
                return SetRowWidget(
                  key: ValueKey('${exercise.exerciseId}_${entry.key}'),
                  exerciseSet: entry.value,
                  exerciseId: exercise.exerciseId,
                  onUpdate: onUpdateSet,
                  onRemove: () => onRemoveSet(entry.key),
                );
              }).toList(),
            ),
          ),

          // ─── Add Set ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spaceL,
              AppConstants.spaceXS,
              AppConstants.spaceL,
              AppConstants.spaceL,
            ),
            child: GestureDetector(
              onTap: onAddSet,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(color: AppColors.borderMedium),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded,
                        color: AppColors.textMuted, size: 18),
                    const SizedBox(width: AppConstants.spaceXS),
                    Text('إضافة مجموعة',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
