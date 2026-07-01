import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/pp_button.dart';
import '../../../exercises/data/models/exercise_entity.dart';
import '../../../exercises/logic/cubit/exercises_cubit.dart';
import '../../data/models/workout_plan_entity.dart';
import '../../logic/cubit/workout_plan_cubit.dart';
import '../../logic/cubit/workout_plan_state.dart';

class DayDetail extends StatefulWidget {
  const DayDetail({
    required this.day,
    required this.onToggleRest,
    required this.onNameChanged,
    required this.onAddExercise,
    required this.onRemoveExercise,
  });

  final PlanDay day;
  final VoidCallback onToggleRest;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onAddExercise;
  final ValueChanged<String> onRemoveExercise;

  @override
  State<DayDetail> createState() => DayDetailState();
}

class DayDetailState extends State<DayDetail> {
  late TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.day.name);
  }

  @override
  void didUpdateWidget(DayDetail old) {
    super.didUpdateWidget(old);
    if (old.day.weekday != widget.day.weekday) {
      _nameCtrl.text = widget.day.name;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final day = widget.day;
    final dayName = weekdayNamesAr[day.weekday - 1];
    final isToday = day.weekday == DateTime.now().weekday;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.screenPaddingH,
        0,
        AppConstants.screenPaddingH,
        120,
      ),
      children: [
        // ─── Day Header ─────────────────────────────────────
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(dayName, style: AppTextStyles.headlineMedium),
                    if (isToday) ...[
                      const SizedBox(width: AppConstants.spaceS),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentDim,
                          borderRadius:
                          BorderRadius.circular(AppConstants.radiusPill),
                        ),
                        child: Text('اليوم',
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.accent)),
                      ),
                    ],
                  ],
                ),
                Text(
                  day.isRest ? 'يوم راحة' : '${day.exercises.length} تمارين',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
            const Spacer(),
            // ─── Toggle زرار واحد بسيط ───────────────────
            GestureDetector(
              onTap: widget.onToggleRest,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceL,
                    vertical: AppConstants.spaceS),
                decoration: BoxDecoration(
                  color: day.isRest ? AppColors.accent : AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                  border: Border.all(
                    color:
                    day.isRest ? AppColors.accent : AppColors.borderMedium,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      day.isRest ? '😴' : '💪',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      day.isRest ? 'راحة' : 'تمرين',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: day.isRest
                            ? AppColors.textOnAccent
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spaceL),

        if (day.isRest) ...[
          // ─── Rest Day Info ─────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppConstants.spaceXXL),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              children: [
                const Text('😴', style: TextStyle(fontSize: 40)),
                const SizedBox(height: AppConstants.spaceM),
                Text('يوم راحة', style: AppTextStyles.labelLarge),
                const SizedBox(height: AppConstants.spaceS),
                Text('اضغط على "راحة" أعلاه لتحويله ليوم تمرين',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textMuted),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ] else ...[
          // ─── Day Name Field ────────────────────────────
          TextField(
            controller: _nameCtrl,
            onChanged: widget.onNameChanged,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'اسم اليوم — مثلاً: تمرين الصدر',
              hintStyle:
              AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.bgSurface,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceL,
                  vertical: AppConstants.spaceM),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceM),

          // ─── Exercises List ────────────────────────────
          if (day.exercises.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceXXL),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                border: Border.all(color: AppColors.borderSubtle, width: 0.5),
              ),
              child: Column(
                children: [
                  const Icon(Icons.fitness_center_rounded,
                      color: AppColors.textMuted, size: 32),
                  const SizedBox(height: AppConstants.spaceM),
                  Text('لا توجد تمارين بعد',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: AppConstants.spaceS),
                  Text('اضغط + لإضافة تمارين ليوم $dayName',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textMuted),
                      textAlign: TextAlign.center),
                ],
              ),
            )
          else
            ...day.exercises.asMap().entries.map((entry) {
              final i = entry.key;
              final ex = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: AppConstants.spaceS),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceL,
                    vertical: AppConstants.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(color: AppColors.borderSubtle, width: 0.5),
                ),
                child: Row(
                  children: [
                    // رقم
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.accentDim,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text('${i + 1}',
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.accent)),
                    ),
                    const SizedBox(width: AppConstants.spaceM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ex.exerciseName,
                              style: AppTextStyles.labelMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Text(
                            '${ex.defaultSets} سيتات × ${ex.defaultReps} رابس  •  ${ex.bodyPart}',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    // حذف
                    GestureDetector(
                      onTap: () => widget.onRemoveExercise(ex.exerciseId),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.close_rounded,
                            size: 18, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: AppConstants.spaceM),
          // ─── Add Exercise Button ───────────────────────
          GestureDetector(
            onTap: widget.onAddExercise,
            child: Container(
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(vertical: AppConstants.spaceL),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(
                    color: AppColors.accent.withOpacity(0.4), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_rounded,
                      color: AppColors.accent, size: 20),
                  const SizedBox(width: AppConstants.spaceS),
                  Text('إضافة تمرين',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.accent)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
