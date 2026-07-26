import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/pp_button.dart';
import '../../../workout_plan/data/models/workout_plan_entity.dart';
import '../../../workout_plan/logic/cubit/workout_plan_cubit.dart';
import '../../../workout_plan/logic/cubit/workout_plan_state.dart';
import '../../logic/cubit/workout_logger_cubit.dart';

class WorkoutLoggerIdleView extends StatefulWidget {
  const WorkoutLoggerIdleView({super.key});

  @override
  State<WorkoutLoggerIdleView> createState() => _WorkoutLoggerIdleViewState();
}

class _WorkoutLoggerIdleViewState extends State<WorkoutLoggerIdleView> {
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    final planState = context.read<WorkoutPlanCubit>().state;
    WorkoutPlan? plan;
    if (planState is WorkoutPlanLoaded) plan = planState.plan;
    if (planState is WorkoutPlanEditing) plan = planState.draft;

    final todayPlan = plan?.dayFor(DateTime.now());
    final defaultName =
    (todayPlan != null && !todayPlan.isRest && todayPlan.name.isNotEmpty)
        ? todayPlan.name
        : 'تمريني اليوم';
    _nameCtrl = TextEditingController(text: defaultName);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WorkoutLoggerCubit>().startSession(
        _nameCtrl.text,
        planDay:
        (todayPlan != null && !todayPlan.isRest) ? todayPlan : null,
      );
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.screenPaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceM),
                  Text(
                    'تسجيل التمرين',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ],
              ),
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        color: AppColors.accentDim,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.fitness_center_rounded,
                        color: AppColors.accent,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceXL),
                    Text(
                      'ابدأ تمرينك',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: AppConstants.spaceS),
                    Text(
                      'سجّل تمارينك، sets، reps، والوزن',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spaceXXL),
                    TextField(
                      controller: _nameCtrl,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineMedium,
                      decoration: InputDecoration(
                        hintText: 'اسم التمرين',
                        filled: true,
                        fillColor: AppColors.bgSurface,
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(AppConstants.radiusL),
                          borderSide:
                          const BorderSide(color: AppColors.borderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(AppConstants.radiusL),
                          borderSide:
                          const BorderSide(color: AppColors.borderSubtle),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(AppConstants.radiusL),
                          borderSide:
                          const BorderSide(color: AppColors.accent),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              PPButton(
                label: 'ابدأ التمرين 💪',
                width: double.infinity,
                onPressed: () {
                  final name = _nameCtrl.text.trim().isEmpty
                      ? 'تمريني اليوم'
                      : _nameCtrl.text.trim();
                  context.read<WorkoutLoggerCubit>().startSession(name);
                },
              ),
              const SizedBox(height: AppConstants.spaceL),
            ],
          ),
        ),
      ),
    );
  }
}