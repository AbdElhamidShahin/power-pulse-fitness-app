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
  final void Function({
  required String exerciseId,
  required int setIndex,
  int? reps,
  double? weight,
  bool? isCompleted,
  }) onUpdateSet;
  final VoidCallback onAddSet;
  final void Function(int setIndex) onRemoveSet;
  final VoidCallback onRemoveExercise;

  @override
  Widget build(BuildContext context) {
    final done      = exercise.isFullyDone;
    final completed = exercise.completedSets;
    final total     = exercise.sets.length;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spaceL),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
          color: done ? AppColors.accent : AppColors.borderSubtle,
          width: done ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(
              children: [
                // اسم + bodyPart
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.exerciseName,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentDim,
                          borderRadius:
                          BorderRadius.circular(AppConstants.radiusPill),
                        ),
                        child: Text(
                          exercise.bodyPart,
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.accent),
                        ),
                      ),
                    ],
                  ),
                ),
                // progress badge
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: done ? AppColors.accent : AppColors.bgElevated,
                    borderRadius:
                    BorderRadius.circular(AppConstants.radiusPill),
                  ),
                  child: Text(
                    done ? '✓ مكتمل' : '$completed / $total',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: done
                          ? AppColors.textOnAccent
                          : AppColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // حذف
                GestureDetector(
                  onTap: onRemoveExercise,
                  child: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.textMuted, size: 20),
                ),
              ],
            ),
          ),

          // ─── Sets header ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const SizedBox(width: 30),
                Expanded(
                  child: Text('وزن (كجم)',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.textMuted),
                      textAlign: TextAlign.center),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('رابس',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.textMuted),
                      textAlign: TextAlign.center),
                ),
                const SizedBox(width: 52),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // ─── Sets ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
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

          // ─── Add set ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: GestureDetector(
              onTap: onAddSet,
              child: Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius:
                  BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(
                      color: AppColors.borderMedium, width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded,
                        color: AppColors.textMuted, size: 16),
                    const SizedBox(width: 4),
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
