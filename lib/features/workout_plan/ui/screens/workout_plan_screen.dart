import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/pp_button.dart';
import '../../../exercises/data/models/exercise_entity.dart';
import '../../../exercises/logic/cubit/exercises_cubit.dart';
import '../../data/models/workout_plan_entity.dart';
import '../../logic/cubit/workout_plan_cubit.dart';
import '../../logic/cubit/workout_plan_state.dart';

class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen({super.key});

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
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
          Navigator.pop(context, true); // حُفظت بنجاح
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
            body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
          );
        }
        final draft = state.draft;
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
                child: Text('حفظ', style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.accent,
                )),
              ),
            ],
          ),
          body: Column(
            children: [
              // ─── تلميح ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.screenPaddingH, AppConstants.spaceS,
                  AppConstants.screenPaddingH, AppConstants.spaceM,
                ),
                child: Text(
                  'حدد أيام التمرين وأضف تمارين لكل يوم — الباقي أيام راحة',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              ),
              // ─── قائمة الأيام ─────────────────────────────────
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.screenPaddingH, 0,
                    AppConstants.screenPaddingH, AppConstants.space5XL,
                  ),
                  itemCount: 7,
                  separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spaceM),
                  itemBuilder: (_, i) {
                    final day = draft.days[i];
                    return _DayCard(
                      day: day,
                      onToggleRest: () => context.read<WorkoutPlanCubit>()
                          .toggleDayRest(day.weekday),
                      onNameChanged: (name) => context.read<WorkoutPlanCubit>()
                          .setDayName(day.weekday, name),
                      onAddExercise: () => _showExercisePicker(context, day.weekday),
                      onRemoveExercise: (id) => context.read<WorkoutPlanCubit>()
                          .removeExerciseFromDay(day.weekday, id),
                      onUpdateDefaults: (id, sets, reps) =>
                          context.read<WorkoutPlanCubit>().updateExerciseDefaults(
                            day.weekday, id, sets: sets, reps: reps,
                          ),
                    );
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.screenPaddingH),
              child: PPButton(
                label: 'حفظ الخطة',
                width: double.infinity,
                onPressed: () => context.read<WorkoutPlanCubit>().saveDraft(),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── Exercise Picker Sheet ─────────────────────────────────────
  Future<void> _showExercisePicker(BuildContext context, int weekday) async {
    final cubit = context.read<WorkoutPlanCubit>();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXXL),
        ),
      ),
      builder: (_) => _ExercisePickerSheet(
        exercisesCubit: context.read<ExercisesCubit>(),
        onPick: (ex) {
          final planEx = PlanExercise(
            exerciseId: ex.id,
            exerciseName: ex.nameAr.isNotEmpty ? ex.nameAr : ex.name,
            bodyPart: ex.bodyPartAr.isNotEmpty ? ex.bodyPartAr : ex.bodyPart,
          );
          cubit.addExerciseToDay(weekday, planEx);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ─── Day Card ──────────────────────────────────────────────────────
class _DayCard extends StatefulWidget {
  const _DayCard({
    required this.day,
    required this.onToggleRest,
    required this.onNameChanged,
    required this.onAddExercise,
    required this.onRemoveExercise,
    required this.onUpdateDefaults,
  });

  final PlanDay day;
  final VoidCallback onToggleRest;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onAddExercise;
  final ValueChanged<String> onRemoveExercise;
  final void Function(String id, int sets, int reps) onUpdateDefaults;

  @override
  State<_DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<_DayCard> {
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.day.name);
  }

  @override
  void didUpdateWidget(_DayCard old) {
    super.didUpdateWidget(old);
    if (old.day.name != widget.day.name && _nameCtrl.text != widget.day.name) {
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
    final isRest = day.isRest;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: isRest ? AppColors.borderSubtle : AppColors.accent.withOpacity(0.4),
          width: isRest ? 0.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spaceL, AppConstants.spaceM,
              AppConstants.spaceS, AppConstants.spaceM,
            ),
            child: Row(
              children: [
                // اسم اليوم
                Text(dayName, style: AppTextStyles.labelLarge),
                const SizedBox(width: AppConstants.spaceS),
                // badge حالة
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceS, vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isRest ? AppColors.bgElevated : AppColors.accentDim,
                    borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                  ),
                  child: Text(
                    isRest ? 'راحة' : 'تمرين',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isRest ? AppColors.textMuted : AppColors.accent,
                    ),
                  ),
                ),
                const Spacer(),
                // toggle
                GestureDetector(
                  onTap: widget.onToggleRest,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceM, vertical: AppConstants.spaceXS,
                    ),
                    decoration: BoxDecoration(
                      color: isRest ? AppColors.accent : AppColors.bgElevated,
                      borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                    ),
                    child: Text(
                      isRest ? 'أضف تمرين' : 'اجعله راحة',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isRest ? AppColors.textOnAccent : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── محتوى يوم التمرين ───────────────────────────────
          if (!isRest) ...[
            // اسم اليوم (مثلاً "تمرين الصدر")
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spaceL, 0, AppConstants.spaceL, AppConstants.spaceS,
              ),
              child: TextField(
                controller: _nameCtrl,
                onChanged: widget.onNameChanged,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'اسم اليوم (مثلاً: تمرين الصدر)',
                  hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.bgElevated,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceM, vertical: AppConstants.spaceS,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // قائمة التمارين
            if (day.exercises.isNotEmpty)
              ...day.exercises.map((ex) => _ExerciseRow(
                exercise: ex,
                onRemove: () => widget.onRemoveExercise(ex.exerciseId),
                onUpdateDefaults: (sets, reps) =>
                    widget.onUpdateDefaults(ex.exerciseId, sets, reps),
              )),

            // زرار إضافة تمرين
            GestureDetector(
              onTap: widget.onAddExercise,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.spaceL, AppConstants.spaceXS,
                  AppConstants.spaceL, AppConstants.spaceM,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add_circle_outline_rounded,
                        color: AppColors.accent, size: 18),
                    const SizedBox(width: AppConstants.spaceXS),
                    Text('إضافة تمرين',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.accent,
                        )),
                  ],
                ),
              ),
            ),
          ] else
            const SizedBox(height: AppConstants.spaceS),
        ],
      ),
    );
  }
}

// ─── Exercise Row ───────────────────────────────────────────────────
class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required this.exercise,
    required this.onRemove,
    required this.onUpdateDefaults,
  });

  final PlanExercise exercise;
  final VoidCallback onRemove;
  final void Function(int sets, int reps) onUpdateDefaults;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spaceL, 0, AppConstants.spaceM, AppConstants.spaceXS,
      ),
      child: Row(
        children: [
          // نقطة
          Container(
            width: 6, height: 6,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppConstants.spaceS),
          // اسم التمرين
          Expanded(
            child: Text(
              exercise.exerciseName,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // sets × reps
          _SetsRepsControl(
            sets: exercise.defaultSets,
            reps: exercise.defaultReps,
            onChange: onUpdateDefaults,
          ),
          // حذف
          GestureDetector(
            onTap: onRemove,
            child: const Padding(
              padding: EdgeInsets.all(AppConstants.spaceXS),
              child: Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sets × Reps Control ────────────────────────────────────────────
class _SetsRepsControl extends StatelessWidget {
  const _SetsRepsControl({
    required this.sets,
    required this.reps,
    required this.onChange,
  });

  final int sets;
  final int reps;
  final void Function(int sets, int reps) onChange;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceS, vertical: 3,
        ),
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(AppConstants.radiusPill),
        ),
        child: Text(
          '$sets × $reps',
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    int tmpSets = sets;
    int tmpReps = reps;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXXL)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: const EdgeInsets.all(AppConstants.spaceXXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('سيتات × رابس', style: AppTextStyles.headlineMedium),
              const SizedBox(height: AppConstants.spaceXXL),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Stepper(
                    label: 'سيتات',
                    value: tmpSets,
                    min: 1, max: 10,
                    onChanged: (v) => setState(() => tmpSets = v),
                  ),
                  Text('×', style: AppTextStyles.headlineMedium),
                  _Stepper(
                    label: 'رابس',
                    value: tmpReps,
                    min: 1, max: 30,
                    onChanged: (v) => setState(() => tmpReps = v),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceXXL),
              PPButton(
                label: 'تأكيد',
                width: double.infinity,
                onPressed: () {
                  onChange(tmpSets, tmpReps);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: AppConstants.spaceM),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Stepper ────────────────────────────────────────────────────────
class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
        const SizedBox(height: AppConstants.spaceS),
        Row(
          children: [
            _StepBtn(
              icon: Icons.remove,
              onTap: value > min ? () => onChanged(value - 1) : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceL),
              child: Text('$value', style: AppTextStyles.headlineMedium),
            ),
            _StepBtn(
              icon: Icons.add,
              onTap: value < max ? () => onChanged(value + 1) : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: onTap == null ? AppColors.bgElevated : AppColors.accentDim,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon, size: 18,
          color: onTap == null ? AppColors.textMuted : AppColors.accent,
        ),
      ),
    );
  }
}

// ─── Exercise Picker Sheet ──────────────────────────────────────────
class _ExercisePickerSheet extends StatefulWidget {
  const _ExercisePickerSheet({
    required this.exercisesCubit,
    required this.onPick,
  });

  final ExercisesCubit exercisesCubit;
  final ValueChanged<Exercise> onPick;

  @override
  State<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<_ExercisePickerSheet> {
  final _ctrl = TextEditingController();
  List<Exercise> _results = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load('');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _load(String q) async {
    setState(() => _loading = true);
    final list = q.isEmpty
        ? await widget.exercisesCubit.browseAll()
        : await widget.exercisesCubit.search(q);
    if (mounted) setState(() { _results = list; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scroll) => Column(
        children: [
          const SizedBox(height: AppConstants.spaceM),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderMedium,
              borderRadius: BorderRadius.circular(AppConstants.radiusPill),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.screenPaddingH, AppConstants.spaceL,
              AppConstants.screenPaddingH, AppConstants.spaceM,
            ),
            child: Row(
              children: [
                Text('اختر تمريناً', style: AppTextStyles.headlineMedium),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPaddingH),
            child: TextField(
              controller: _ctrl,
              onChanged: _load,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'ابحث...',
                hintStyle: AppTextStyles.bodyMedium,
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textMuted, size: 20),
                filled: true,
                fillColor: AppColors.bgElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceM),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                : ListView.builder(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(
                AppConstants.screenPaddingH, 0,
                AppConstants.screenPaddingH, AppConstants.space5XL,
              ),
              itemCount: _results.length,
              itemBuilder: (_, i) {
                final ex = _results[i];
                final name = ex.nameAr.isNotEmpty ? ex.nameAr : ex.name;
                final part = ex.bodyPartAr.isNotEmpty ? ex.bodyPartAr : ex.bodyPart;
                return GestureDetector(
                  onTap: () => widget.onPick(ex),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: AppConstants.spaceS),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceL,
                      vertical: AppConstants.spaceM,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgElevated,
                      borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: AppTextStyles.labelMedium,
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppConstants.spaceS, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accentDim,
                                  borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                                ),
                                child: Text(part,
                                    style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.accent)),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.add_circle_outline_rounded,
                            color: AppColors.accent, size: 22),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
