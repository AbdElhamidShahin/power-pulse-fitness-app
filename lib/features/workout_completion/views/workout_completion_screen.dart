import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// WorkoutCompletionScreen — the reward moment.
///
/// This screen is the emotional payoff of every session.
/// It is the ONLY place a user feels: "I did something real today."
///
/// Design principles:
///   - Full screen. No distractions.
///   - The streak number is the hero element.
///   - One coaching message — earned, not generic.
///   - Three stats: time, calories, exercises.
///   - Two actions: share (future) and done.
///
/// Called from ExerciseScreen after "Complete Workout" is tapped.
/// It records the session and updates the streak before showing.
class WorkoutCompletionScreen extends StatefulWidget {
  const WorkoutCompletionScreen({
    super.key,
    required this.muscleGroup,
    required this.exerciseCount,
    required this.durationMinutes,
    this.systemName = '',
  });

  final String muscleGroup;
  final int exerciseCount;
  final int durationMinutes;
  final String systemName;

  @override
  State<WorkoutCompletionScreen> createState() =>
      _WorkoutCompletionScreenState();
}

class _WorkoutCompletionScreenState
    extends State<WorkoutCompletionScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideAnim;

  int _newStreak       = 0;
  bool _loaded         = false;
  late String _message;
  late int _calories;

  @override
  void initState() {
    super.initState();

    // Estimate calories: rough METs-based estimate
    // Average MET for resistance training ≈ 5.0, weight 75kg assumed
    _calories = (widget.durationMinutes * 5.0 * 75 / 60).round();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim  = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _recordAndLoad();
  }

  Future<void> _recordAndLoad() async {
    // Record the session — this is where the streak increments
    final streak = await UserProfileService.instance.recordWorkoutCompleted();
    await UserProfileService.instance.saveWorkoutRecord(
      WorkoutRecord(
        date:              DateTime.now(),
        muscleGroup:       widget.muscleGroup,
        durationMinutes:   widget.durationMinutes,
        estimatedCalories: _calories,
        exerciseCount:     widget.exerciseCount,
        systemName:        widget.systemName,
      ),
    );

    _message = UserProfileService.completionMessage(
      durationMinutes: widget.durationMinutes,
      streak:          streak,
      exerciseCount:   widget.exerciseCount,
    );

    if (!mounted) return;
    setState(() {
      _newStreak = streak;
      _loaded    = true;
    });

    // Haptic — subtle premium feedback
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loaded ? _buildContent() : _buildLoading(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),

              // ── Top: done signal ─────────────────────────────────────
              _DoneSignal(animate: _controller),

              const Spacer(),

              // ── Center: streak hero ──────────────────────────────────
              ScaleTransition(
                scale: _scaleAnim,
                child: _StreakHero(streak: _newStreak),
              ),

              const SizedBox(height: AppSpacing.md),

              // ── Coaching message ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg),
                child: Text(
                  _message,
                  style: AppTextStyles.bodyLg.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(),

              // ── Stats row ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.marginMobile),
                child: _StatsRow(
                  duration:   widget.durationMinutes,
                  calories:   _calories,
                  exercises:  widget.exerciseCount,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Done button ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.marginMobile),
                child: _DoneButton(onTap: () {
                  // Pop back to root — close workout stack
                  Navigator.of(context)
                      .popUntil((route) => route.isFirst);
                }),
              ),

              const SizedBox(height: AppSpacing.md),

              // ── Muscle group label ────────────────────────────────────
              Text(
                widget.muscleGroup,
                style: AppTextStyles.labelMuted,
              ),

              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DONE SIGNAL — animated checkmark at top
// ─────────────────────────────────────────────────────────────────────────────
class _DoneSignal extends StatelessWidget {
  const _DoneSignal({required this.animate});
  final AnimationController animate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
          builder: (_, v, __) => Transform.scale(
            scale: v,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.success.withOpacity(0.3), width: 1.5),
              ),
              child: Icon(
                Icons.check_rounded,
                color: AppColors.success,
                size: 30,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'تمرين مكتمل',
          style: AppTextStyles.labelCaps.copyWith(
            color: AppColors.success,
            letterSpacing: 2.0,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STREAK HERO — the one number that matters
// ─────────────────────────────────────────────────────────────────────────────
class _StreakHero extends StatelessWidget {
  const _StreakHero({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    final isMilestone = streak == 7  ||
                        streak == 14 ||
                        streak == 30 ||
                        streak == 60 ||
                        streak == 100;

    return Column(
      children: [
        // Ambient glow behind the number — subtle, not crypto
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.primary.withOpacity(isMilestone ? 0.18 : 0.10),
                Colors.transparent,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$streak',
                  style: AppTextStyles.displayHero.copyWith(
                    fontSize: streak >= 100 ? 72 : 88,
                    color: isMilestone ? AppColors.success : AppColors.primary,
                  ),
                ),
                Text(
                  UserProfileService.streakDayLabel(streak),
                  style: AppTextStyles.labelMuted.copyWith(
                    fontSize: 13,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Milestone badge — only on earned days
        if (isMilestone)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                  color: AppColors.success.withOpacity(0.3)),
            ),
            child: Text(
              _milestoneLabel(streak),
              style: AppTextStyles.labelCaps.copyWith(
                color: AppColors.success,
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
          ),
      ],
    );
  }

  String _milestoneLabel(int s) {
    if (s == 7)   return 'أسبوع كامل';
    if (s == 14)  return 'أسبوعان';
    if (s == 30)  return 'شهر كامل';
    if (s == 60)  return 'شهران';
    if (s == 100) return '١٠٠ يوم';
    return '';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATS ROW — three session metrics
// ─────────────────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.duration,
    required this.calories,
    required this.exercises,
  });

  final int duration, calories, exercises;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(value: '$duration', unit: 'دقيقة',  icon: Icons.timer_outlined),
          _StatDivider(),
          _Stat(value: '$calories', unit: 'سعرة',    icon: Icons.local_fire_department_outlined),
          _StatDivider(),
          _Stat(value: '$exercises', unit: 'تمرين',  icon: Icons.fitness_center_outlined),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.unit, required this.icon});
  final String value, unit;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.displayMetrics.copyWith(
            fontSize: 28,
            color: AppColors.textPrimary,
          ),
        ),
        Text(unit, style: AppTextStyles.labelMuted),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 48,
        color: AppColors.separator,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// DONE BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _DoneButton extends StatelessWidget {
  const _DoneButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: AppSpacing.touchTarget,
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
        ),
        child: Center(
          child: Text(
            'العودة للرئيسية',
            style: AppTextStyles.buttonLabel.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
