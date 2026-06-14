import 'package:flutter/material.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/ui/components/pp_app_bar.dart';
import '../../../core/ui/components/pp_empty_state.dart';

/// ProgressScreen — the weekly investment view.
///
/// Shows the user their accumulated effort.
/// This is the answer to "why come back tomorrow?"
/// Because they can SEE what they've built.
///
/// Sections:
///   1. This week — 3 stats (sessions, minutes, calories)
///   2. Consistency heatmap — 7-day visual
///   3. Recent sessions — last 10 workouts
///   4. Personal records — longest streak, total sessions
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc     = UserProfileService.instance;
    final history = svc.history;
    final week    = svc.thisWeekHistory;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PpAppBar(title: 'التقدم', showNotification: false),
      body: history.isEmpty
          ? PpEmptyState(
              emoji: '📈',
              title:    'لا يوجد تاريخ بعد',
              subtitle: 'أكمل تمرينك الأول\nوستظهر إحصائياتك هنا',
              ctaLabel: 'ابدأ أول تمرين',
              onCta: () => Navigator.of(context).maybePop(),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                left:   AppSpacing.marginMobile,
                right:  AppSpacing.marginMobile,
                top:    AppSpacing.sm,
                bottom: AppSpacing.bottomNavHeight + AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ── 1. This week stats ─────────────────────────────────
                  _WeekStats(
                    sessions:  week.length,
                    minutes:   svc.weeklyTotalMinutes,
                    calories:  svc.weeklyTotalCalories,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── 2. Consistency heatmap ─────────────────────────────
                  _ConsistencyHeatmap(history: history),
                  const SizedBox(height: AppSpacing.md),

                  // ── 3. Personal records ────────────────────────────────
                  _PersonalRecords(
                    currentStreak: svc.currentStreak,
                    longestStreak: svc.longestStreak,
                    totalSessions: history.length,
                    totalMinutes:  history.fold(0, (s, r) => s + r.durationMinutes),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── 4. Recent sessions ─────────────────────────────────
                  Text('الجلسات الأخيرة', style: AppTextStyles.labelMuted),
                  const SizedBox(height: AppSpacing.xs),
                  ...history.take(15).map(
                      (r) => _SessionRow(record: r)),
                ],
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// THIS WEEK — 3 stats in a row
// ─────────────────────────────────────────────────────────────────────────────
class _WeekStats extends StatelessWidget {
  const _WeekStats({
    required this.sessions,
    required this.minutes,
    required this.calories,
  });

  final int sessions, minutes, calories;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('هذا الأسبوع', style: AppTextStyles.labelMuted),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.cardPaddingLg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatBlock(
                  value: '$sessions',
                  label: 'تمارين',
                  color: AppColors.primary),
              _VertDivider(),
              _StatBlock(
                  value: '$minutes',
                  label: 'دقيقة',
                  color: AppColors.success),
              _VertDivider(),
              _StatBlock(
                  value: '$calories',
                  label: 'سعرة',
                  color: AppColors.warning),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value, label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.displayMetrics.copyWith(
              fontSize: 32, color: color),
        ),
        const SizedBox(height: 3),
        Text(label, style: AppTextStyles.labelMuted),
      ],
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      width: 1, height: 44, color: AppColors.separator);
}

// ─────────────────────────────────────────────────────────────────────────────
// CONSISTENCY HEATMAP — last 28 days as 4×7 grid
// Visual proof of effort — the investment loop
// ─────────────────────────────────────────────────────────────────────────────
class _ConsistencyHeatmap extends StatelessWidget {
  const _ConsistencyHeatmap({required this.history});
  final List<WorkoutRecord> history;

  @override
  Widget build(BuildContext context) {
    // Build a set of date strings for the last 28 days that had workouts
    final trainedDates = <String>{};
    for (final r in history) {
      trainedDates.add(
          '${r.date.year}-${r.date.month.toString().padLeft(2,'0')}-${r.date.day.toString().padLeft(2,'0')}');
    }

    final today = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('الاتساق — 28 يوم', style: AppTextStyles.labelMuted),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Column(
            children: [
              // 4 rows × 7 columns (newest on right)
              ...List.generate(4, (week) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: List.generate(7, (day) {
                      final daysAgo = (3 - week) * 7 + (6 - day);
                      final date = today.subtract(
                          Duration(days: daysAgo));
                      final key =
                          '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';
                      final trained  = trainedDates.contains(key);
                      final isToday  = daysAgo == 0;
                      final isFuture = daysAgo < 0;

                      return Container(
                        width: 30, height: 30,
                        margin: const EdgeInsets.only(left: 5),
                        decoration: BoxDecoration(
                          color: isFuture
                              ? Colors.transparent
                              : trained
                                  ? AppColors.primary.withOpacity(0.85)
                                  : AppColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(8),
                          border: isToday
                              ? Border.all(
                                  color: AppColors.primary, width: 1.5)
                              : null,
                        ),
                        child: trained
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 14)
                            : null,
                      );
                    }),
                  ),
                );
              }),

              const SizedBox(height: 8),

              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text('تمرين مكتمل',
                      style:
                          AppTextStyles.labelMuted.copyWith(fontSize: 10)),
                  const SizedBox(width: 14),
                  Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text('لا تمرين',
                      style:
                          AppTextStyles.labelMuted.copyWith(fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PERSONAL RECORDS — the achievement anchors
// ─────────────────────────────────────────────────────────────────────────────
class _PersonalRecords extends StatelessWidget {
  const _PersonalRecords({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalSessions,
    required this.totalMinutes,
  });

  final int currentStreak, longestStreak, totalSessions, totalMinutes;

  @override
  Widget build(BuildContext context) {
    final totalHours = totalMinutes ~/ 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('أرقامك', style: AppTextStyles.labelMuted),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Column(
            children: [
              _RecordRow(
                  label: 'السلسلة الحالية',
                  value: '$currentStreak يوم',
                  color: AppColors.primary),
              _Divider(),
              _RecordRow(
                  label: 'أطول سلسلة',
                  value: '$longestStreak يوم',
                  color: AppColors.success),
              _Divider(),
              _RecordRow(
                  label: 'إجمالي الجلسات',
                  value: '$totalSessions جلسة',
                  color: AppColors.warning),
              _Divider(),
              _RecordRow(
                  label: 'إجمالي الوقت',
                  value: totalHours > 0
                      ? '$totalHours ساعة'
                      : '$totalMinutes دقيقة',
                  color: AppColors.textSecondary),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(
            value,
            style: AppTextStyles.headingSmall.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      height: 0.5,
      color: AppColors.separator);
}

// ─────────────────────────────────────────────────────────────────────────────
// SESSION ROW — recent workout history entry
// ─────────────────────────────────────────────────────────────────────────────
class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.record});
  final WorkoutRecord record;

  @override
  Widget build(BuildContext context) {
    final date = record.date;
    final dateStr =
        '${date.day}/${date.month}/${date.year}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            // Stats
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${record.durationMinutes} د  ·  '
                  '${record.estimatedCalories} سعرة  ·  '
                  '${record.exerciseCount} تمارين',
                  style: AppTextStyles.labelMuted,
                ),
                const SizedBox(height: 3),
                if (record.systemName.isNotEmpty)
                  Text(record.systemName,
                      style: AppTextStyles.labelMuted
                          .copyWith(color: AppColors.textTertiary)),
              ],
            ),
            const Spacer(),
            // Muscle group + date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(record.muscleGroup,
                    style: AppTextStyles.headingSmall
                        .copyWith(fontSize: 14)),
                const SizedBox(height: 2),
                Text(dateStr, style: AppTextStyles.labelMuted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
