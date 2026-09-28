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

class WeekStrip extends StatelessWidget {
  const WeekStrip({
    required this.days,
    required this.selectedWeekday,
    required this.onSelect,
  });

  final List<PlanDay> days;
  final int selectedWeekday;
  final ValueChanged<int> onSelect;

  static const _names = ['إث', 'ث', 'أر', 'خ', 'ج', 'س', 'أح'];
  static const _fullNames = [
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgDeep,
      padding: const EdgeInsets.fromLTRB(
        AppConstants.screenPaddingH,
        0,
        AppConstants.screenPaddingH,
        AppConstants.spaceS,
      ),
      child: Row(
        children: List.generate(7, (i) {
          final day = days[i];
          final wd = i + 1;
          final isSelected = wd == selectedWeekday;
          final isToday = wd == DateTime.now().weekday;

          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(wd),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accent
                      : day.isRest
                      ? AppColors.bgElevated
                      : AppColors.accentDim,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: isToday && !isSelected
                      ? Border.all(color: AppColors.accent, width: 1)
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _names[i],
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isSelected
                            ? AppColors.textOnAccent
                            : AppColors.textMuted,
                        fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      day.isRest ? '😴' : '💪',
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (!day.isRest && day.exercises.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.textOnAccent
                              : AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
