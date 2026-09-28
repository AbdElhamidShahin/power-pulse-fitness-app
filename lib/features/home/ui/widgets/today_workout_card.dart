import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/logic/cubit/home_cubit.dart';
import '../../../home/logic/cubit/home_state.dart';
import '../../../workout_plan/data/models/workout_plan_entity.dart';
import '../../../workout_plan/logic/cubit/workout_plan_cubit.dart';
import '../../../workout_plan/logic/cubit/workout_plan_state.dart';

class TodayWorkoutCard extends StatefulWidget {
  const TodayWorkoutCard({super.key});

  @override
  State<TodayWorkoutCard> createState() => _TodayWorkoutCardState();
}

class _TodayWorkoutCardState extends State<TodayWorkoutCard> {
  int _selectedWeekday = DateTime.now().weekday;

  static const _dayNamesShort = ['س', 'أح', 'إث', 'ث', 'أر', 'خ', 'ج'];

  static const _dayNamesFull = [
    'السبت',
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutPlanCubit, WorkoutPlanState>(
      builder: (context, state) {
        if (state is WorkoutPlanEmpty || state is WorkoutPlanInitial) {
          return _NoPlantCard(
            onSetup: () => context.push(AppRouter.workoutPlan),
          );
        }
        if (state is WorkoutPlanLoading) {
          return SizedBox(
            height: 120.h,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }

        final plan = state is WorkoutPlanLoaded
            ? state.plan
            : (state as WorkoutPlanEditing).draft;

        final selectedDay = plan.dayFor(
          DateTime.now().add(Duration(
            days: _selectedWeekday - DateTime.now().weekday,
          )),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WeekStrip(
              days: plan.days,
              selectedWeekday: _selectedWeekday,
              dayNamesShort: _dayNamesShort,
              onSelect: (wd) => setState(() => _selectedWeekday = wd),
            ),
            SizedBox(height: 12.h),

            // ── Day Card ────────────────────────────────────
            if (selectedDay.isRest)
              _RestDayCard(
                dayName: _dayNamesFull[selectedDay.weekday - 1],
                isToday: selectedDay.weekday == DateTime.now().weekday,
                onEdit: () => context.push(AppRouter.workoutPlan),
              )
            else
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, homeState) {
                  final completedToday = homeState is HomeLoaded
                      ? homeState.summary.hasWorkedOutToday
                      : false;
                  return _WorkoutDayCard(
                    day: selectedDay,
                    isToday: selectedDay.weekday == DateTime.now().weekday,
                    dayName: _dayNamesFull[selectedDay.weekday - 1],
                    completedToday: completedToday,
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.days,
    required this.selectedWeekday,
    required this.dayNamesShort,
    required this.onSelect,
  });

  final List<PlanDay> days;
  final int selectedWeekday;
  final List<String> dayNamesShort;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(7, (i) {
        final wd = i + 1;
        final day = days.firstWhere((d) => d.weekday == wd,
            orElse: () => PlanDay(weekday: wd, isRest: true));
        final isSelected = wd == selectedWeekday;
        final isToday = wd == DateTime.now().weekday;

        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(wd),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              padding: EdgeInsets.symmetric(vertical: 7.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent
                    : day.isRest
                        ? AppColors.bgElevated
                        : AppColors.accentDim,
                borderRadius: BorderRadius.circular(10.r),
                border: isToday && !isSelected
                    ? Border.all(color: AppColors.accent, width: 1.2)
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dayNamesShort[i],
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10.sp,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w400,
                      color: isSelected
                          ? AppColors.textOnAccent
                          : AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    day.isRest ? '😴' : '💪',
                    style: TextStyle(fontSize: 13.sp),
                  ),
                  if (!day.isRest && day.exercises.isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    Container(
                      width: 4.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.textOnAccent
                            : AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _NoPlantCard extends StatelessWidget {
  const _NoPlantCard({required this.onSetup});
  final VoidCallback onSetup;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Text('💪', style: TextStyle(fontSize: 32.sp)),
          SizedBox(height: 8.h),
          Text('ابدأ بإعداد خطة الأسبوع',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              )),
          SizedBox(height: 4.h),
          Text('حدد تمارينك لكل يوم ويوم الراحة مرة واحدة',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.sp,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: onSetup,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(14.r),
              ),
              alignment: Alignment.center,
              child: Text('إعداد الخطة الأسبوعية',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textOnAccent,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestDayCard extends StatelessWidget {
  const _RestDayCard({
    required this.dayName,
    required this.isToday,
    required this.onEdit,
  });
  final String dayName;
  final bool isToday;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Text('😴', style: TextStyle(fontSize: 28.sp)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday ? 'يوم راحة اليوم' : 'يوم راحة — $dayName',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  isToday
                      ? 'استرح كويس — بكرة هيكون عندك تمرين'
                      : 'لا توجد تمارين هذا اليوم',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          // زرار تعديل
          GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.bgElevated,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.borderMedium),
              ),
              child: Text('تعديل',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutDayCard extends StatelessWidget {
  const _WorkoutDayCard({
    required this.day,
    required this.isToday,
    required this.dayName,
    this.completedToday = false,
  });
  final PlanDay day;
  final bool isToday;
  final String dayName;
  final bool completedToday;

  @override
  Widget build(BuildContext context) {
    final exCount = day.exercises.length;
    final setCount = day.exercises.fold(0, (s, e) => s + e.defaultSets);
    final mins = day.estimatedMinutes;

    // ── اليوزر خلص تمرين النهارده ─────────────────────────────
    if (isToday && completedToday) {
      return _CompletedTodayCard(day: day, dayName: dayName);
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isToday
              ? AppColors.accent.withOpacity(0.4)
              : AppColors.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── header ────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  day.name.isNotEmpty ? day.name : 'تمرين $dayName',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isToday ? AppColors.accentDim : AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  isToday ? 'اليوم 💪' : dayName,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: isToday ? AppColors.accent : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // ─── stats ─────────────────────────────────────────
          Row(
            children: [
              _Stat(emoji: '🕐', label: '$mins دقيقة'),
              SizedBox(width: 14.w),
              _Stat(emoji: '💪', label: '$exCount تمارين'),
              SizedBox(width: 14.w),
              _Stat(emoji: '🔁', label: '$setCount سيت'),
            ],
          ),
          SizedBox(height: 12.h),

          // ─── exercise chips ────────────────────────────────
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: _buildChips(day.exercises),
          ),
          SizedBox(height: 16.h),

          // ─── زرار — اليوم فقط يبدأ التمرين، باقي الأيام تعديل
          GestureDetector(
            onTap: () => isToday
                ? context.push(AppRouter.workoutLogger, extra: day)
                : context.push(AppRouter.workoutPlan),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 15.h),
              decoration: BoxDecoration(
                color: isToday ? AppColors.accent : AppColors.bgElevated,
                borderRadius: BorderRadius.circular(14.r),
                border:
                    isToday ? null : Border.all(color: AppColors.borderMedium),
              ),
              alignment: Alignment.center,
              child: Text(
                isToday ? 'ابدأ التمرين  ←' : 'تعديل الخطة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: isToday
                      ? AppColors.textOnAccent
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChips(List<PlanExercise> exercises) {
    const maxVisible = 3;
    final visible = exercises.take(maxVisible).toList();
    final extra = exercises.length - maxVisible;
    return [
      ...visible.map((e) => _Chip(label: e.exerciseName)),
      if (extra > 0) _Chip(label: '+$extra', muted: true),
    ];
  }
}

class _CompletedTodayCard extends StatelessWidget {
  const _CompletedTodayCard({required this.day, required this.dayName});
  final PlanDay day;
  final String dayName;

  @override
  Widget build(BuildContext context) {
    final exCount = day.exercises.length;
    final mins = day.estimatedMinutes;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20.r),
        border:
            Border.all(color: AppColors.success.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── header ──────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: const BoxDecoration(
                  color: AppColors.successDim,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppColors.success, size: 24),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أتمرنت النهارده 🎉',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      day.name.isNotEmpty ? day.name : 'تمرين $dayName',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // ── stats ────────────────────────────────────────────
          Row(children: [
            _Stat(emoji: '💪', label: '$exCount تمارين'),
            SizedBox(width: 14.w),
            _Stat(emoji: '🕐', label: '$mins دقيقة'),
          ]),
          SizedBox(height: 16.h),

          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => context.push(AppRouter.workoutPlan),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.bgElevated,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.borderMedium),
                  ),
                  alignment: Alignment.center,
                  child: Text('تعديل الخطة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      )),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: GestureDetector(
                onTap: () => context.push(AppRouter.workoutLogger, extra: day),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.successDim,
                    borderRadius: BorderRadius.circular(12.r),
                    border:
                        Border.all(color: AppColors.success.withOpacity(0.4)),
                  ),
                  alignment: Alignment.center,
                  child: Text('أعد تاني 🔥',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      )),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.emoji, required this.label});
  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: TextStyle(fontSize: 14.sp)),
        SizedBox(width: 3.w),
        Text(label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              color: AppColors.textMuted,
            )),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.muted = false});
  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: muted ? AppColors.textMuted : AppColors.textPrimary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
