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

class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen({super.key});

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  int _selectedWeekday = DateTime.now().weekday; // اليوم الحالي مختار افتراضياً

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
              // ─── Week Strip ──────────────────────────────────────
              _WeekStrip(
                days: draft.days,
                selectedWeekday: _selectedWeekday,
                onSelect: (wd) => setState(() => _selectedWeekday = wd),
              ),
              const SizedBox(height: AppConstants.spaceM),
              // ─── Selected Day Content ────────────────────────────
              Expanded(
                child: _DayDetail(
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
                  // ─── زرار ابدأ التمرين ────────────────────────
                  _StartTodayWorkoutButton(draft: draft),
                  const SizedBox(height: AppConstants.spaceS),
                  // ─── زرار حفظ الخطة ──────────────────────────
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
      builder: (_) => _ExercisePickerSheet(
        exercisesCubit: exCubit,
        onPick: (ex) {
          // ─── بسيط: ٣×١٠ تلقائي، بدون أي picker معقد ───
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

// ─── Week Strip ─────────────────────────────────────────────────────
class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
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

// ─── Day Detail ─────────────────────────────────────────────────────
class _DayDetail extends StatefulWidget {
  const _DayDetail({
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
  State<_DayDetail> createState() => _DayDetailState();
}

class _DayDetailState extends State<_DayDetail> {
  late TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.day.name);
  }

  @override
  void didUpdateWidget(_DayDetail old) {
    super.didUpdateWidget(old);
    // لما اليوزر يبدل اليوم نحدّث الـ controller
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

// ─── Exercise Picker Sheet ───────────────────────────────────────────
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
    if (mounted)
      setState(() {
        _results = list;
        _loading = false;
      });
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
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderMedium,
              borderRadius: BorderRadius.circular(AppConstants.radiusPill),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppConstants.screenPaddingH,
                AppConstants.spaceL,
                AppConstants.screenPaddingH,
                AppConstants.spaceM),
            child: Row(
              children: [
                Text('اختر تمريناً', style: AppTextStyles.headlineMedium),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded,
                      color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenPaddingH),
            child: TextField(
              controller: _ctrl,
              onChanged: _load,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'ابحث...',
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
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent))
                : _results.isEmpty
                    ? Center(
                        child: Text('لا توجد نتائج',
                            style: AppTextStyles.bodyMedium))
                    : ListView.builder(
                        controller: scroll,
                        padding: const EdgeInsets.fromLTRB(
                          AppConstants.screenPaddingH,
                          0,
                          AppConstants.screenPaddingH,
                          AppConstants.space5XL,
                        ),
                        itemCount: _results.length,
                        itemBuilder: (_, i) {
                          final ex = _results[i];
                          final name =
                              ex.nameAr.isNotEmpty ? ex.nameAr : ex.name;
                          final part = ex.bodyPartAr.isNotEmpty
                              ? ex.bodyPartAr
                              : ex.bodyPart;
                          return GestureDetector(
                            onTap: () => widget.onPick(ex),
                            child: Container(
                              margin: const EdgeInsets.only(
                                  bottom: AppConstants.spaceS),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.spaceM,
                                vertical: AppConstants.spaceM,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.bgElevated,
                                borderRadius:
                                    BorderRadius.circular(AppConstants.radiusL),
                              ),
                              child: Row(
                                children: [
                                  // ── صورة التمرين ──────────────────────
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        AppConstants.radiusM),
                                    child: ex.gifUrl.isNotEmpty
                                        ? Image.network(
                                            ex.gifUrl,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                _ExercisePlaceholder(
                                                    bodyPart: ex.bodyPart),
                                          )
                                        : _ExercisePlaceholder(
                                            bodyPart: ex.bodyPart),
                                  ),
                                  const SizedBox(width: AppConstants.spaceM),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(name,
                                            style: AppTextStyles.labelMedium,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: AppConstants.spaceS,
                                              vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.accentDim,
                                            borderRadius: BorderRadius.circular(
                                                AppConstants.radiusPill),
                                          ),
                                          child: Text(part,
                                              style: AppTextStyles.labelSmall
                                                  .copyWith(
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

// ─── Start Today Workout Button ───────────────────────────────────────
// يعرض زرار "ابدأ تمرين اليوم" لو اليوم مش راحة
class _StartTodayWorkoutButton extends StatelessWidget {
  const _StartTodayWorkoutButton({required this.draft});
  final WorkoutPlan draft;

  @override
  Widget build(BuildContext context) {
    final today = draft.dayFor(DateTime.now());
    final hasWorkout =
        today != null && !today.isRest && today.exercises.isNotEmpty;

    if (!hasWorkout) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.push(AppRouter.workoutLogger),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.accentDim,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(color: AppColors.accent, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded,
                color: AppColors.accent, size: 22),
            const SizedBox(width: 8),
            Text(
              'ابدأ تمرين اليوم',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.accent),
            ),
            if (today != null && today.name.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                '— ${today.name}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.accent.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Exercise Image Placeholder ────────────────────────────────────
// يظهر لما الـ gifUrl فاضي أو فيه error في التحميل
class _ExercisePlaceholder extends StatelessWidget {
  const _ExercisePlaceholder({required this.bodyPart});
  final String bodyPart;

  // لون كل مجموعة عضلية
  Color _colorFor(String part) {
    final p = part.toLowerCase();
    if (p.contains('chest')) return AppColors.muscleChest;
    if (p.contains('back')) return AppColors.muscleBack;
    if (p.contains('leg')) return AppColors.muscleLegs;
    if (p.contains('shoulder')) return AppColors.muscleShoulder;
    if (p.contains('arm') || p.contains('bicep') || p.contains('tricep'))
      return AppColors.muscleArms;
    if (p.contains('core') || p.contains('abs') || p.contains('waist'))
      return AppColors.muscleCore;
    return AppColors.accent;
  }

  String _emojiFor(String part) {
    final p = part.toLowerCase();
    if (p.contains('chest')) return '🫁';
    if (p.contains('back')) return '🔙';
    if (p.contains('leg')) return '🦵';
    if (p.contains('shoulder')) return '💪';
    if (p.contains('arm') || p.contains('bicep') || p.contains('tricep'))
      return '💪';
    if (p.contains('core') || p.contains('abs')) return '🎯';
    return '🏋️';
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(bodyPart);
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      alignment: Alignment.center,
      child: Text(_emojiFor(bodyPart), style: const TextStyle(fontSize: 26)),
    );
  }
}
