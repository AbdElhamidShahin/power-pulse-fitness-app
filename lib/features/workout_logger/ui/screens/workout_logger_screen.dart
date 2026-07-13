import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/pp_button.dart';
import '../../data/models/workout_session_entity.dart';
import '../../logic/cubit/workout_logger_cubit.dart';
import '../../logic/cubit/workout_logger_state.dart';
import '../widgets/exercise_logger_card.dart';

class WorkoutLoggerScreen extends StatefulWidget {
  const WorkoutLoggerScreen({super.key});

  @override
  State<WorkoutLoggerScreen> createState() => _WorkoutLoggerScreenState();
}

class _WorkoutLoggerScreenState extends State<WorkoutLoggerScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WorkoutLoggerCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutLoggerCubit, WorkoutLoggerState>(
      listener: (context, state) {
        if (state is WorkoutLoggerFinished) {
          _showSummarySheet(context, state.session);
        }
      },
      builder: (context, state) => switch (state) {
        WorkoutLoggerInitial() ||
        WorkoutLoggerLoading() =>
          const _LoadingView(),
        WorkoutLoggerIdle() => const _IdleView(),
        WorkoutLoggerActive(session: final s) => _ActiveView(session: s),
        WorkoutLoggerFinished() => const _LoadingView(),
        WorkoutLoggerError(message: final m) => _ErrorView(message: m),
      },
    );
  }

  void _showSummarySheet(BuildContext context, WorkoutSession session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXXL)),
      ),
      builder: (_) => _SummarySheet(session: session),
    ).then((_) => context.read<WorkoutLoggerCubit>().reset());
  }
}

// ─── Idle ─────────────────────────────────────────────────────
class _IdleView extends StatefulWidget {
  const _IdleView();

  @override
  State<_IdleView> createState() => _IdleViewState();
}

class _IdleViewState extends State<_IdleView> {
  final _nameCtrl = TextEditingController(text: 'تمريني اليوم');

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: AppConstants.spaceM),
                  Text('تسجيل التمرين',
                      style: Theme.of(context).textTheme.headlineLarge),
                ],
              ),
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.accentDim,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.fitness_center_rounded,
                          color: AppColors.accent, size: 44),
                    ),
                    const SizedBox(height: AppConstants.spaceXL),
                    Text('ابدأ تمرينك',
                        style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: AppConstants.spaceS),
                    Text('سجّل تمارينك، sets، reps، والوزن',
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center),
                    const SizedBox(height: AppConstants.spaceXXL),
                    // اسم الجلسة
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
                          borderSide: const BorderSide(color: AppColors.accent),
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

// ─── Active Session ────────────────────────────────────────────
class _ActiveView extends StatelessWidget {
  const _ActiveView({required this.session});
  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkoutLoggerCubit>();

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ──────────────────────────────────
            _ActiveHeader(session: session, onCancel: cubit.cancelSession),
            const Divider(color: AppColors.borderSubtle, height: 1),

            // ─── Exercises List ───────────────────────────
            Expanded(
              child: session.exercises.isEmpty
                  ? _EmptyExercises(
                      onAdd: () => _showAddExercise(context, cubit))
                  : ListView.builder(
                      padding:
                          const EdgeInsets.all(AppConstants.screenPaddingH),
                      itemCount: session.exercises.length,
                      itemBuilder: (_, i) {
                        final ex = session.exercises[i];
                        return ExerciseLoggerCard(
                          exercise: ex,
                          onUpdateSet: ({
                            required exerciseId,
                            required setIndex,
                            reps,
                            weight,
                            isCompleted,
                          }) =>
                              cubit.updateSet(
                            exerciseId: exerciseId,
                            setIndex: setIndex,
                            reps: reps,
                            weight: weight,
                            isCompleted: isCompleted,
                          ),
                          onAddSet: () => cubit.addSet(ex.exerciseId),
                          onRemoveSet: (idx) =>
                              cubit.removeSet(ex.exerciseId, idx),
                          onRemoveExercise: () =>
                              cubit.removeExercise(ex.exerciseId),
                        );
                      },
                    ),
            ),

            // ─── Bottom Actions ───────────────────────────
            _BottomBar(
              session: session,
              onAddExercise: () => _showAddExercise(context, cubit),
              onFinish: cubit.finishSession,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExercise(BuildContext context, WorkoutLoggerCubit cubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXXL)),
      ),
      builder: (_) => _AddExerciseSheet(
        onAdd: (exercise) {
          cubit.addExercise(exercise);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ─── Active Header ─────────────────────────────────────────────
class _ActiveHeader extends StatefulWidget {
  const _ActiveHeader({required this.session, required this.onCancel});
  final WorkoutSession session;
  final VoidCallback onCancel;

  @override
  State<_ActiveHeader> createState() => _ActiveHeaderState();
}

class _ActiveHeaderState extends State<_ActiveHeader> {
  late final Stream<int> _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Stream.periodic(const Duration(seconds: 1),
        (_) => DateTime.now().difference(widget.session.startTime).inSeconds);
  }

  String _fmt(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.screenPaddingH,
        AppConstants.spaceL,
        AppConstants.screenPaddingH,
        AppConstants.spaceL,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.session.name,
                    style: Theme.of(context).textTheme.headlineMedium),
                StreamBuilder<int>(
                  stream: _ticker,
                  initialData: 0,
                  builder: (_, snap) => Text(
                    '⏱ ${_fmt(snap.data ?? 0)}',
                    style: AppTextStyles.accentLabel,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: AppColors.bgSurface,
                title: Text('إلغاء التمرين؟',
                    style: Theme.of(context).textTheme.headlineSmall),
                content: Text('سيتم حذف التمرين الحالي',
                    style: AppTextStyles.bodyMedium),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('لا', style: AppTextStyles.accentLabel),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onCancel();
                    },
                    child: Text('نعم',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.danger)),
                  ),
                ],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceM,
                  vertical: AppConstants.spaceS),
              decoration: BoxDecoration(
                color: AppColors.dangerDim,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Text('إلغاء',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.danger)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Bar ────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.session,
    required this.onAddExercise,
    required this.onFinish,
  });
  final WorkoutSession session;
  final VoidCallback onAddExercise;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.screenPaddingH,
        AppConstants.spaceL,
        AppConstants.screenPaddingH,
        AppConstants.spaceXL,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onAddExercise,
              child: Container(
                height: AppConstants.buttonHeightMedium,
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  border: Border.all(color: AppColors.borderMedium),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded,
                        color: AppColors.textMuted, size: 20),
                    const SizedBox(width: AppConstants.spaceS),
                    Text('إضافة تمرين',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spaceM),
          Expanded(
            child: PPButton(
              label: 'إنهاء التمرين ✅',
              width: double.infinity,
              onPressed: onFinish,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────
class _EmptyExercises extends StatelessWidget {
  const _EmptyExercises({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add_circle_outline_rounded,
              color: AppColors.textMuted, size: 56),
          const SizedBox(height: AppConstants.spaceL),
          Text('لا يوجد تمارين بعد',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppConstants.spaceS),
          Text('اضغط "إضافة تمرين" للبدء', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppConstants.spaceXXL),
          PPButton(
            label: '+ إضافة أول تمرين',
            size: PPButtonSize.medium,
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}

// ─── Add Exercise Sheet ────────────────────────────────────────
class _AddExerciseSheet extends StatefulWidget {
  const _AddExerciseSheet({required this.onAdd});
  final void Function(SessionExercise) onAdd;

  @override
  State<_AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends State<_AddExerciseSheet> {
  final _nameCtrl = TextEditingController();
  String _selectedBodyPart = 'صدر';

  static const _bodyParts = [
    'صدر',
    'ظهر',
    'أكتاف',
    'بايسبس',
    'ترايسبس',
    'أرجل',
    'بطن',
    'كارديو',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppConstants.screenPaddingH,
        right: AppConstants.screenPaddingH,
        top: AppConstants.spaceXXL,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('إضافة تمرين',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppConstants.spaceXL),

          // اسم التمرين
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            style: AppTextStyles.titleLarge,
            decoration: InputDecoration(
              hintText: 'اسم التمرين (مثال: بنش برس)',
              hintStyle: AppTextStyles.bodyMedium,
              filled: true,
              fillColor: AppColors.bgElevated,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceL),

          // Body Part
          Text('العضلة المستهدفة', style: AppTextStyles.labelMedium),
          const SizedBox(height: AppConstants.spaceS),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _bodyParts.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppConstants.spaceS),
              itemBuilder: (_, i) {
                final part = _bodyParts[i];
                final selected = part == _selectedBodyPart;
                return GestureDetector(
                  onTap: () => setState(() => _selectedBodyPart = part),
                  child: AnimatedContainer(
                    duration: AppConstants.durationFast,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spaceL),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.accent : AppColors.bgElevated,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusPill),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      part,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: selected
                            ? AppColors.textOnAccent
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppConstants.spaceXXL),
          PPButton(
            label: 'إضافة',
            width: double.infinity,
            onPressed: () {
              final name = _nameCtrl.text.trim();
              if (name.isEmpty) return;
              final exercise = SessionExercise(
                exerciseId: '${name}_${DateTime.now().millisecondsSinceEpoch}',
                exerciseName: name,
                bodyPart: _selectedBodyPart,
                sets: [const ExerciseSet(setNumber: 1)],
              );
              widget.onAdd(exercise);
            },
          ),
          const SizedBox(height: AppConstants.spaceXXL),
        ],
      ),
    );
  }
}

// ─── Summary Sheet ─────────────────────────────────────────────
class _SummarySheet extends StatelessWidget {
  const _SummarySheet({required this.session});
  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spaceXXL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events_rounded,
              color: AppColors.accent, size: 56),
          const SizedBox(height: AppConstants.spaceL),
          Text('أحسنت! 💪', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: AppConstants.spaceS),
          Text('انتهى تمرين "${session.name}"',
              style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppConstants.spaceXXL),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SummaryItem(
                  value: '${session.durationMinutes}',
                  unit: 'دقيقة',
                  icon: Icons.timer_rounded,
                  color: AppColors.accent),
              _SummaryItem(
                  value: session.exercises.length.toString(),
                  unit: 'تمرين',
                  icon: Icons.fitness_center_rounded,
                  color: AppColors.info),
              _SummaryItem(
                  value: session.completedSets.toString(),
                  unit: 'مجموعة',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.success),
              _SummaryItem(
                  value: session.caloriesBurned.toInt().toString(),
                  unit: 'سعرة',
                  icon: Icons.local_fire_department_rounded,
                  color: AppColors.warning),
            ],
          ),

          const SizedBox(height: AppConstants.spaceXXL),
          PPButton(
            label: 'ممتاز!',
            width: double.infinity,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(height: AppConstants.spaceL),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: AppConstants.spaceXS),
        Text(value,
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary)),
        Text(unit, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

// ─── Loading / Error ───────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(_) => const Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Center(child: CircularProgressIndicator(color: AppColors.accent)));
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Center(child: Text(message, style: AppTextStyles.bodyMedium)));
}
