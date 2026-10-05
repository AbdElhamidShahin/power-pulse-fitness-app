import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme_colors.dart';
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
      backgroundColor: context.colors.bgSurface,
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
          backgroundColor: context.colors.bgDeep,
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              margin: const EdgeInsets.all(AppConstants.spaceS),
              decoration: BoxDecoration(
                color: context.colors.bgSurface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Icon(
                Icons.arrow_back_ios,
                color: context.colors.textPrimary,
                size: AppConstants.iconL,
              ),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: CachedNetworkImage(
              imageUrl: exercise.gifUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: context.colors.bgElevated,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: context.colors.bgElevated,
                child: Icon(Icons.fitness_center,
                    color: context.colors.textMuted, size: 64),
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
                  PPBadge(label: displayEquipment, color: context.colors.textMuted),
                ],
              ),
              const SizedBox(height: AppConstants.spaceXXL),

              if (muscles.isNotEmpty) ...[
                Text(context.l10n.secondaryMuscles,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: AppConstants.spaceM),
                Wrap(
                  spacing: AppConstants.spaceS,
                  runSpacing: AppConstants.spaceS,
                  children: muscles
                      .map((m) => PPBadge(
                    label: m,
                    color: context.colors.textMuted,
                    size: PPBadgeSize.small,
                  ))
                      .toList(),
                ),
                const SizedBox(height: AppConstants.spaceXXL),
              ],

              // Instructions
              if (steps.isNotEmpty) ...[
                Text(context.l10n.howToPerform,
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
                label: context.l10n.addToPlan,
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
          Icon(Icons.error_outline_rounded,
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
    context.l10n.monday, context.l10n.tuesday, context.l10n.wednesday, context.l10n.thursday,
    context.l10n.friday, context.l10n.saturday, context.l10n.sunday,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<WorkoutPlanCubit>()..ensureLoaded(),
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
                      color: context.colors.borderMedium,
                      borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.addToWhichDay,
                  style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 18,
                    fontWeight: FontWeight.w900, color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.exercise.nameAr.isNotEmpty
                      ? widget.exercise.nameAr
                      : widget.exercise.name,
                  style: TextStyle(
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
                            : context.colors.bgElevated,
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
                            style: TextStyle(fontSize: 18),
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
                                          ? context.colors.textMuted
                                          : context.colors.textPrimary,
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
                                      child: Text(context.l10n.today,
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
                                        ? context.l10n.alreadyAdded
                                        : '${day.exercises.length} تمارين',
                                    style: TextStyle(
                                      fontFamily: 'Cairo', fontSize: 11,
                                      color: alreadyHas
                                          ? AppColors.success
                                          : context.colors.textMuted,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle_rounded,
                                color: AppColors.accent, size: 20),
                          if (day.isRest)
                              Text(context.l10n.restLabel,
                                style: TextStyle(
                                  fontFamily: 'Cairo', fontSize: 11,
                                  color: context.colors.textMuted,
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
                    planCubit.addExerciseAndSave(
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
                    setState(() => _added = true);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _selectedWeekday != null
                          ? AppColors.accent
                          : context.colors.bgElevated,
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
                            : context.colors.textMuted,
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
            Text(
            context.l10n.noWorkoutPlan,
            style: TextStyle(
              fontFamily: 'Cairo', fontSize: 16,
              fontWeight: FontWeight.w900, color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
            Text(
            'اعمل خطة الأسبوع الأول وبعدين ضيف التمارين',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
                color: context.colors.textMuted),
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
            decoration: BoxDecoration(
              color: AppColors.successDim, shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded,
                color: AppColors.success, size: 40),
          ),
          const SizedBox(height: 16),
            Text(
            'تمت الإضافة! 🎉',
            style: TextStyle(
              fontFamily: 'Cairo', fontSize: 18,
              fontWeight: FontWeight.w900, color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اتضاف لـ ${_dayNames[(_selectedWeekday ?? 1) - 1]}',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 14,
                color: context.colors.textMuted),
          ),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: context.colors.bgElevated,
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  ),
                  alignment: Alignment.center,
                  child:   Text('تمام',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: context.colors.textPrimary)),
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
