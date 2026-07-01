import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../core/services/user_profile_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/ui/components/pp_app_bar.dart';
import '../../../core/ui/components/pp_button.dart';
import '../../../core/ui/components/pp_card.dart';
import '../../../core/ui/components/pp_empty_state.dart';
import '../logic/progress_cubit.dart';
import '../logic/progress_state.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProgressCubit(
        GetIt.instance<UserProfileService>(),
      )..load(),
      child: const _ProgressBody(),
    );
  }
}

class _ProgressBody extends StatelessWidget {
  const _ProgressBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgressCubit, ProgressState>(
      builder: (context, state) => switch (state) {
        ProgressLoading() => const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
        ProgressEmpty() => _EmptyProgress(),
        ProgressLoaded(
          :final totalWorkouts,
          :final currentStreak,
          :final thisWeekCount,
          :final history
        ) =>
          _LoadedProgress(
            totalWorkouts: totalWorkouts,
            currentStreak: currentStreak,
            thisWeekCount: thisWeekCount,
            history: history,
          ),
        ProgressError(:final message) => Scaffold(
            backgroundColor: AppColors.background,
            body: PpEmptyState(
              emoji: '⚠️',
              title: 'خطأ',
              subtitle: message,
            ),
          ),
      },
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyProgress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PpAppBar(title: 'التقدم', showNotification: false),
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(
              child: PpEmptyState(
                emoji: '📈',
                title: 'لا يوجد تاريخ بعد',
                subtitle: 'أكمل تمرينك الأول\nوستظهر إحصائياتك هنا',
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginMobile,
                0,
                AppSpacing.marginMobile,
                AppSpacing.lg,
              ),
              child: PpButton(
                label: 'ابدأ أول تمرين',
                icon: Icons.fitness_center_rounded,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Loaded State ──────────────────────────────────────────────────────────────

class _LoadedProgress extends StatelessWidget {
  const _LoadedProgress({
    required this.totalWorkouts,
    required this.currentStreak,
    required this.thisWeekCount,
    required this.history,
  });

  final int totalWorkouts;
  final int currentStreak;
  final int thisWeekCount;
  final List<WorkoutRecord> history;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PpAppBar(title: 'التقدم', showNotification: false),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(
            left: AppSpacing.marginMobile,
            right: AppSpacing.marginMobile,
            top: AppSpacing.sm,
            bottom: AppSpacing.bottomNavHeight + AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // ── Stats row ────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'هذا الأسبوع',
                      value: '$thisWeekCount',
                      unit: 'تمارين',
                      color: AppColors.success,
                      icon: Icons.calendar_today_rounded,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: _StatCard(
                      label: 'السلسلة',
                      value: '$currentStreak',
                      unit: UserProfileService.streakDayLabel(currentStreak),
                      color: AppColors.primary,
                      icon: Icons.local_fire_department_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // ── History list ─────────────────────────────────────────
              Text('سجل التمارين', style: AppTextStyles.headingSmall),
              const SizedBox(height: AppSpacing.xs),
              ...history.reversed.map((r) => _HistoryItem(record: r)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
  });

  final String label, value, unit;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return PpCard(
      borderColor: color.withOpacity(0.25),
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(label, style: AppTextStyles.labelMuted),
              const SizedBox(width: 6),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.displayHero.copyWith(color: color),
          ),
          Text(unit, style: AppTextStyles.labelMuted),
        ],
      ),
    );
  }
}

// ── History Item ──────────────────────────────────────────────────────────────

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({required this.record});
  final WorkoutRecord record;

  @override
  Widget build(BuildContext context) {
    final d = record.date;
    final label =
        '${d.day}/${d.month}/${d.year}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PpCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPaddingLg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: const Icon(Icons.check_rounded,
                  color: AppColors.success, size: 18),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('تمرين مكتمل', style: AppTextStyles.bodyMd),
                const SizedBox(height: 2),
                Text(label, style: AppTextStyles.labelMuted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
