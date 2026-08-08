import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/pp_badge.dart';
import '../../../../../shared/widgets/pp_button.dart';
import '../../../workout_plan/data/models/workout_plan_entity.dart';
import '../../../workout_plan/logic/cubit/workout_plan_cubit.dart';
import '../../../workout_plan/logic/cubit/workout_plan_state.dart';
import '../../data/models/exercise_entity.dart';
import '../../logic/cubit/exercises_cubit.dart';
import '../../logic/cubit/exercises_state.dart';
import '../../../../../core/di/injection.dart';

class ExerciseDetailScreen extends StatefulWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId});
  final String exerciseId;

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ExerciseDetailCubit>().load(widget.exerciseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ExerciseDetailCubit, ExerciseDetailState>(
        builder: (context, state) => switch (state) {
          ExerciseDetailInitial() ||
          ExerciseDetailLoading() =>
          const _DetailLoading(),
          ExerciseDetailError(:final message) => _DetailError(message: message),
          ExerciseDetailLoaded(:final exercise) =>
              _DetailContent(exercise: exercise),
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.exercise});
  final Exercise exercise;

  void _showAddToPlanSheet(BuildContext context, Exercise ex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddToPlanSheet(exercise: ex),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
    exercise.nameAr.isNotEmpty ? exercise.nameAr : exercise.name;
    final displayBodyPart = exercise.bodyPartAr.isNotEmpty
        ? exercise.bodyPartAr
        : exercise.bodyPart;
    final displayTarget =
    exercise.targetAr.isNotEmpty ? exercise.targetAr : exercise.target;
    final displayEquipment = exercise.equipmentAr.isNotEmpty
        ? exercise.equipmentAr
        : exercise.equipment;
    final steps = exercise.instructionsAr.isNotEmpty
        ? exercise.instructionsAr
        : exercise.instructions;
    final muscles = exercise.secondaryMusclesAr.isNotEmpty
        ? exercise.secondaryMusclesAr
        : exercise.secondaryMuscles;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: AppColors.bgDeep,
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              margin: const EdgeInsets.all(AppConstants.spaceS),
              decoration: BoxDecoration(
                color: AppColors.bgSurface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textPrimary,
                size: AppConstants.iconS,
              ),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: CachedNetworkImage(
              imageUrl: exercise.gifUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: AppColors.bgElevated,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.bgElevated,
                child: const Icon(Icons.fitness_center,
                    color: AppColors.textMuted, size: 64),
              ),
            ),
          ),
        ),

        // ─── Info ────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.all(AppConstants.screenPaddingH),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                displayName,
                style: Theme.of(context).textTheme.headlineLarge,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: AppConstants.spaceM),

              // Badges
              Wrap(
                spacing: AppConstants.spaceS,
                runSpacing: AppConstants.spaceS,
                children: [
                  MuscleGroupBadge(muscle: displayBodyPart),
                  PPBadge(label: displayTarget, color: AppColors.info),
                  PPBadge(label: displayEquipment, color: AppColors.textMuted),
                ],
              ),
              const SizedBox(height: AppConstants.spaceXXL),

              if (muscles.isNotEmpty) ...[
                Text('العضلات الثانوية',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: AppConstants.spaceM),
                Wrap(
                  spacing: AppConstants.spaceS,
                  runSpacing: AppConstants.spaceS,
                  children: muscles
                      .map((m) => PPBadge(
                    label: m,
                    color: AppColors.textMuted,
                    size: PPBadgeSize.small,
                  ))
                      .toList(),
                ),
                const SizedBox(height: AppConstants.spaceXXL),
              ],

              // Instructions
              if (steps.isNotEmpty) ...[
                Text('كيفية الأداء',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: AppConstants.spaceL),
                ...steps.asMap().entries.map(
                      (e) => Padding(
                    padding:
                    const EdgeInsets.only(bottom: AppConstants.spaceM),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textDirection: TextDirection.rtl,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          margin: const EdgeInsets.only(
                              left: AppConstants.spaceM),
                          decoration: BoxDecoration(
                            color: AppColors.accentDim,
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusPill),
                            border:
                            Border.all(color: AppColors.borderAccent),
                          ),
                          child: Center(
                            child: Text(
                              '${e.key + 1}',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.accent,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            e.value,
                            style: AppTextStyles.bodyMedium,
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppConstants.space3XL),

              PPButton(
                label: 'أضف للخطة',
                onPressed: () => _showAddToPlanSheet(context, exercise),
                icon: Icons.add_rounded,
              ),
              const SizedBox(height: AppConstants.spaceXL),
            ]),
          ),
        ),
      ],
    );
  }
}

class _DetailLoading extends StatelessWidget {
  const _DetailLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.accent),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.danger, size: 48),
          const SizedBox(height: AppConstants.spaceM),
          Text(message, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

// ─── Add To Plan Sheet ────────────────────────────────────────────
// يسمح لليوزر يختار أي يوم في الخطة يضيف فيه التمرين
class _AddToPlanSheet extends StatefulWidget {
  const _AddToPlanSheet({required this.exercise});
  final Exercise exercise;

  @override
  State<_AddToPlanSheet> createState() => _AddToPlanSheetState();
}

class _AddToPlanSheetState extends State<_AddToPlanSheet> {
  int? _selectedWeekday;
  bool _added = false;

  static const _dayNames = [
    'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس',
    'الجمعة', 'السبت', 'الأحد',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<WorkoutPlanCubit>()..load(),
      child: BlocBuilder<WorkoutPlanCubit, WorkoutPlanState>(
        builder: (context, state) {
          // لو مفيش خطة بعد — نعمل خطة جديدة ونضيف فيها
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
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderMedium,
                      borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'أضف لأي يوم؟',
                  style: const TextStyle(
                    fontFamily: 'Cairo', fontSize: 18,
                    fontWeight: FontWeight.w900, color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.exercise.nameAr.isNotEmpty
                      ? widget.exercise.nameAr
                      : widget.exercise.name,
                  style: const TextStyle(
                    fontFamily: 'Cairo', fontSize: 14,
                    color: AppColors.accent, fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                // أيام الأسبوع
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
                    onTap: day.isRest ? null : () {
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
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        border: Border.all(
                          color: isSelected ? AppColors.accent : Colors.transparent,
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
                                      fontFamily: 'Cairo', fontSize: 14,
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
                                            fontFamily: 'Cairo', fontSize: 10,
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
                                      fontFamily: 'Cairo', fontSize: 11,
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
                                  fontFamily: 'Cairo', fontSize: 11,
                                  color: AppColors.textMuted,
                                )),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 16),
                // زرار الإضافة
                GestureDetector(
                  onTap: _selectedWeekday == null
                      ? null
                      : () {
                    final planCubit = context.read<WorkoutPlanCubit>();
                    // نبدأ editing لو مش editing
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
              fontFamily: 'Cairo', fontSize: 16,
              fontWeight: FontWeight.w900, color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'اعمل خطة الأسبوع الأول وبعدين ضيف التمارين',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
                color: AppColors.textMuted),
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
                  fontFamily: 'Cairo', fontSize: 14,
                  fontWeight: FontWeight.w700, color: AppColors.textOnAccent,
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
            width: 72, height: 72,
            decoration: const BoxDecoration(
              color: AppColors.successDim, shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                color: AppColors.success, size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'تمت الإضافة! 🎉',
            style: TextStyle(
              fontFamily: 'Cairo', fontSize: 18,
              fontWeight: FontWeight.w900, color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اتضاف لـ ${_dayNames[(_selectedWeekday ?? 1) - 1]}',
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14,
                color: AppColors.textMuted),
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
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 14,
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
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 14,
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
