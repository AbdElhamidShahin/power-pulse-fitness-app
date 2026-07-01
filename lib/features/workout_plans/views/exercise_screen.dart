import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task/features/workout_plans/views/widgets/custom_tab_bar_widget.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/ui/components/pp_button.dart';
import '../../../core/ui/components/pp_card.dart';
import '../../../core/ui/components/pp_empty_state.dart';
import '../../exercises/data/model/exercise.dart';
import '../../../shared/providers/item_provider.dart';
import '../../workout_completion/views/workout_completion_screen.dart';


class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({
    super.key,
    required this.currentDay,
    this.systemName = '',
    this.muscleGroup = '',
  });

  final String currentDay;
  final String systemName;
  final String muscleGroup;

  
  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  late final Stopwatch _stopwatch;
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _sessionStarted = false;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _startSession();
  }

  void _startSession() {
    if (_sessionStarted) return;
    _sessionStarted = true;
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds = _stopwatch.elapsed.inSeconds);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  String get _timerLabel {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _completeWorkout(List<Exercise> items) {
    _stopwatch.stop();
    _timer?.cancel();

    final durationMinutes = (_elapsedSeconds / 60).ceil().clamp(1, 999);

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => WorkoutCompletionScreen(
          muscleGroup:     widget.muscleGroup.isNotEmpty
              ? widget.muscleGroup
              : widget.currentDay,
          exerciseCount:   items.length,
          durationMinutes: durationMinutes,
          systemName:      widget.systemName,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showDetail(Exercise ex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExerciseDetailSheet(exercise: ex),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items =
    Provider.of<ItemProvider>(context).getItems(widget.currentDay);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _SessionAppBar(
        day:       widget.currentDay,
        timer:     _timerLabel,
        count:     items.length,
        isRunning: _sessionStarted,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => CustomTabBarDemo(pageId: widget.currentDay)),
        ),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: AppColors.onPrimary),
      ),
      body: items.isEmpty
          ? const PpEmptyState(
        emoji: '🏋️',
        title: 'خطتك فارغة',
        subtitle: 'اضغط + لإضافة تمارين\nوابنِ روتينك اليومي',
      )
          : Column(
        children: [
          // Exercise list
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginMobile, AppSpacing.sm,
                AppSpacing.marginMobile, AppSpacing.xs,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: _ExerciseRow(
                  exercise:  items[i],
                  index:     i + 1,
                  total:     items.length,
                  onTap:     () => _showDetail(items[i]),
                  onRemove:  () => Provider.of<ItemProvider>(
                      context, listen: false)
                      .removeItem(widget.currentDay, items[i]),
                ),
              ),
            ),
          ),

          // Complete Workout CTA
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.marginMobile, 0,
              AppSpacing.marginMobile, AppSpacing.sm,
            ),
            child: PpButton(
              label: 'إنهاء التمرين',
              icon:  Icons.check_rounded,
              onPressed: () => _completeWorkout(items),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SESSION APP BAR — shows live timer + exercise count
// ─────────────────────────────────────────────────────────────────────────────
class _SessionAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SessionAppBar({
    required this.day,
    required this.timer,
    required this.count,
    required this.isRunning,
  });

  final String day, timer;
  final int count;
  final bool isRunning;

  @override
  Size get preferredSize => const Size.fromHeight(AppSpacing.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
            bottom: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: AppSpacing.appBarHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.marginMobile),
            child: Row(
              children: [
                // Back
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textPrimary, size: 17),
                  ),
                ),

                // Timer — live session clock
                if (isRunning) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(
                            color: AppColors.primary, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                      Text(timer,
                          style: AppTextStyles.labelCaps.copyWith(
                              color: AppColors.primary, fontSize: 11)),
                    ]),
                  ),
                ],

                const Spacer(),

                // Day + count — right aligned
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(day, style: AppTextStyles.headingSmall),
                    Text(
                      count > 0 ? '$count تمارين' : 'لا تمارين',
                      style: AppTextStyles.labelMuted,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXERCISE ROW — numbered, with position context
// ─────────────────────────────────────────────────────────────────────────────
class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required this.exercise,
    required this.index,
    required this.total,
    required this.onTap,
    required this.onRemove,
  });

  final Exercise exercise;
  final int index, total;
  final VoidCallback onTap, onRemove;

  @override
  Widget build(BuildContext context) {
    return PpCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 108,
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(AppSpacing.radiusLg),
                bottomRight: Radius.circular(AppSpacing.radiusLg),
              ),
              child: SizedBox(
                width: 108, height: 108,
                child: Stack(fit: StackFit.expand, children: [
                  Image.asset(exercise.image, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surfaceHigh,
                          child: const Icon(Icons.fitness_center,
                              color: AppColors.outline))),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [
                            Colors.transparent,
                            AppColors.surface.withOpacity(0.85)
                          ],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Exercise number badge
                  Positioned(
                    bottom: 6, right: 6,
                    child: Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.85),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('$index',
                            style: AppTextStyles.labelCaps.copyWith(
                                color: Colors.white, fontSize: 9)),
                      ),
                    ),
                  ),
                ]),
              ),
            ),

            // Text
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(exercise.title,
                        style: AppTextStyles.headingSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end),
                    const SizedBox(height: 4),
                    Text(exercise.details,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end),
                    const SizedBox(height: 6),
                    // Position context
                    Text('$index من $total',
                        style: AppTextStyles.labelMuted.copyWith(fontSize: 10)),
                  ],
                ),
              ),
            ),

            // Remove
            GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 32, height: 32,
                margin: const EdgeInsets.only(left: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.remove_rounded,
                    color: AppColors.error, size: 16),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXERCISE DETAIL SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _ExerciseDetailSheet extends StatelessWidget {
  const _ExerciseDetailSheet({required this.exercise});
  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(999)),
          ),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.marginMobile, 0,
                  AppSpacing.marginMobile, AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    child: SizedBox(
                      height: 180, width: double.infinity,
                      child: Image.asset(exercise.image, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: AppColors.surfaceHigh)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(exercise.title, style: AppTextStyles.headlineMd),
                  const SizedBox(height: AppSpacing.xs),
                  Text(exercise.details,
                      style: AppTextStyles.bodyMd
                          .copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.end),
                  const SizedBox(height: AppSpacing.sm),
                  Text('التعليمات', style: AppTextStyles.labelPrimary),
                  const SizedBox(height: AppSpacing.xs),
                  ...exercise.instructions.map((inst) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '• $inst',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.end,
                      textDirection: TextDirection.rtl,
                    ),
                  )),
                  const SizedBox(height: AppSpacing.sm),
                  PpButton(
                      label: 'إغلاق',
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
