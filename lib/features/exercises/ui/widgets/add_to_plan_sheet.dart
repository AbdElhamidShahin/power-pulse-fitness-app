import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../workout_plan/data/models/workout_plan_entity.dart';
import '../../../workout_plan/logic/cubit/workout_plan_cubit.dart';
import '../../../workout_plan/logic/cubit/workout_plan_state.dart';
import '../../data/models/exercise_entity.dart';

class AddToPlanSheet extends StatefulWidget {
  const AddToPlanSheet({required this.exercise});
  final Exercise exercise;

  @override
  State<AddToPlanSheet> createState() => _AddToPlanSheetState();
}

class _AddToPlanSheetState extends State<AddToPlanSheet> {
  int? _selectedWeekday;
  bool _added = false;

  static const _dayNames = [
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<WorkoutPlanCubit>()..load(),
      child: BlocBuilder<WorkoutPlanCubit, WorkoutPlanState>(
        builder: (context, state) {
          if (state is WorkoutPlanEmpty || state is WorkoutPlanInitial) {
            return _buildNoPlanContent(context);
          }

          final plan = state is WorkoutPlanLoaded
              ? state.plan
              : state is WorkoutPlanEditing
                  ? state.draft
                  : null;

          if (plan == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          if (_added) return _buildSuccessContent(context);

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderMedium,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusPill),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'أضف لأي يوم؟',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.exercise.nameAr.isNotEmpty
                      ? widget.exercise.nameAr
                      : widget.exercise.name,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                ...List.generate(7, (i) {
                  final wd = i + 1;
                  final day = plan.days.firstWhere(
                    (d) => d.weekday == wd,
                    orElse: () => PlanDay(weekday: wd, isRest: true),
                  );
                  final isSelected = _selectedWeekday == wd;
                  final isToday = wd == DateTime.now().weekday;
                  final alreadyHas = day.exercises
                      .any((e) => e.exerciseId == widget.exercise.id);

                  return GestureDetector(
                    onTap: day.isRest
                        ? null
                        : () {
                            setState(() => _selectedWeekday = wd);
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accentDim
                            : AppColors.bgElevated,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusM),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accent
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            day.isRest ? '😴' : '💪',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Text(
                                    _dayNames[i],
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: day.isRest
                                          ? AppColors.textMuted
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  if (isToday) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentDim,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text('اليوم',
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 10,
                                            color: AppColors.accent,
                                            fontWeight: FontWeight.w700,
                                          )),
                                    ),
                                  ],
                                ]),
                                if (!day.isRest)
                                  Text(
                                    alreadyHas
                                        ? '✓ مضاف بالفعل'
                                        : '${day.exercises.length} تمارين',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 11,
                                      color: alreadyHas
                                          ? AppColors.success
                                          : AppColors.textMuted,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.accent, size: 20),
                          if (day.isRest)
                            const Text('راحة',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                )),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                GestureDetector(
                  onTap: _selectedWeekday == null
                      ? null
                      : () {
                          final planCubit = context.read<WorkoutPlanCubit>();

                          if (planCubit.state is! WorkoutPlanEditing) {
                            planCubit.startEditing();
                          }
                          planCubit.addExerciseToDay(
                            _selectedWeekday!,
                            PlanExercise(
                              exerciseId: widget.exercise.id,
                              exerciseName: widget.exercise.nameAr.isNotEmpty
                                  ? widget.exercise.nameAr
                                  : widget.exercise.name,
                              bodyPart: widget.exercise.bodyPartAr.isNotEmpty
                                  ? widget.exercise.bodyPartAr
                                  : widget.exercise.bodyPart,
                              gifUrl: widget.exercise.gifUrl,
                            ),
                          );
                          planCubit.saveDraft();
                          setState(() => _added = true);
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _selectedWeekday != null
                          ? AppColors.accent
                          : AppColors.bgElevated,
                      borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _selectedWeekday != null
                          ? 'أضف ليوم ${_dayNames[_selectedWeekday! - 1]}'
                          : 'اختار اليوم الأول',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _selectedWeekday != null
                            ? AppColors.textOnAccent
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoPlanContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💪', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          const Text(
            'مفيش خطة تمرين بعد',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'اعمل خطة الأسبوع الأول وبعدين ضيف التمارين',
            style: TextStyle(
                fontFamily: 'Cairo', fontSize: 13, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              context.push(AppRouter.workoutPlan);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
              ),
              alignment: Alignment.center,
              child: const Text(
                'إعداد الخطة الأسبوعية',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textOnAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.successDim,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                color: AppColors.success, size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'تمت الإضافة! 🎉',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اتضاف لـ ${_dayNames[(_selectedWeekday ?? 1) - 1]}',
            style: const TextStyle(
                fontFamily: 'Cairo', fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.bgElevated,
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  ),
                  alignment: Alignment.center,
                  child: const Text('تمام',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppRouter.workoutPlan);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.accentDim,
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    border: Border.all(color: AppColors.accent),
                  ),
                  alignment: Alignment.center,
                  child: const Text('عرض الخطة',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent)),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
