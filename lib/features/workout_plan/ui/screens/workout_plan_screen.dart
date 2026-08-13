import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/pp_button.dart';
import '../../../exercises/logic/cubit/exercises_cubit.dart';
import '../../data/models/workout_plan_entity.dart';
import '../../logic/cubit/workout_plan_cubit.dart';
import '../../logic/cubit/workout_plan_state.dart';
import '../widgets/day_detail.dart';
import '../widgets/exercise_picker_sheet.dart';
import '../widgets/start_today_workout_button.dart';
import '../widgets/week_strip.dart';

class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen({super.key});

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  int _selectedWeekday = DateTime.now().weekday;

  @override
  void initState() {
    super.initState();
    context.read<WorkoutPlanCubit>().startEditing();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutPlanCubit, WorkoutPlanState>(
      listener: (context, state) {
        if (state is WorkoutPlanLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ تم حفظ الخطة'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
        if (state is WorkoutPlanError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is! WorkoutPlanEditing) {
          return const Scaffold(
            backgroundColor: AppColors.bgDeep,
            body: Center(
                child: CircularProgressIndicator(color: AppColors.accent)),
          );
        }
        final draft = state.draft;
        final selectedDay = draft.days.firstWhere(
          (d) => d.weekday == _selectedWeekday,
          orElse: () => draft.days.first,
        );

        return Scaffold(
          backgroundColor: AppColors.bgDeep,
          appBar: AppBar(
            backgroundColor: AppColors.bgDeep,
            elevation: 0,
            title: Text('خطة الأسبوع', style: AppTextStyles.headlineMedium),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: () => context.read<WorkoutPlanCubit>().saveDraft(),
                child: Text('حفظ',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.accent)),
              ),
            ],
          ),
          body: Column(
            children: [
              WeekStrip(
                days: draft.days,
                selectedWeekday: _selectedWeekday,
                onSelect: (wd) => setState(() => _selectedWeekday = wd),
              ),
              const SizedBox(height: AppConstants.spaceM),
              Expanded(
                child: DayDetail(
                  day: selectedDay,
                  onToggleRest: () => context
                      .read<WorkoutPlanCubit>()
                      .toggleDayRest(selectedDay.weekday),
                  onNameChanged: (name) => context
                      .read<WorkoutPlanCubit>()
                      .setDayName(selectedDay.weekday, name),
                  onAddExercise: () =>
                      _showExercisePicker(context, selectedDay.weekday),
                  onRemoveExercise: (id) => context
                      .read<WorkoutPlanCubit>()
                      .removeExerciseFromDay(selectedDay.weekday, id),
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.screenPaddingH,
                0,
                AppConstants.screenPaddingH,
                AppConstants.spaceM,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StartTodayWorkoutButton(draft: draft),
                  const SizedBox(height: AppConstants.spaceS),
                  PPButton(
                    label: 'حفظ الخطة',
                    width: double.infinity,
                    onPressed: () =>
                        context.read<WorkoutPlanCubit>().saveDraft(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showExercisePicker(BuildContext context, int weekday) async {
    final cubit = context.read<WorkoutPlanCubit>();
    final exCubit = context.read<ExercisesCubit>();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXXL)),
      ),
      builder: (_) => ExercisePickerSheet(
        exercisesCubit: exCubit,
        onPick: (ex) {
          cubit.addExerciseToDay(
            weekday,
            PlanExercise(
              exerciseId: ex.id,
              exerciseName: ex.nameAr.isNotEmpty ? ex.nameAr : ex.name,
              bodyPart: ex.bodyPartAr.isNotEmpty ? ex.bodyPartAr : ex.bodyPart,
              gifUrl: ex.gifUrl,
              defaultSets: 3,
              defaultReps: 10,
            ),
          );
          Navigator.pop(context);
        },
      ),
    );
  }
}
