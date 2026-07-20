import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../data/models/progress_entity.dart';
import '../../logic/cubit/progress_cubit.dart';
import '../../logic/cubit/progress_state.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProgressCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: BlocBuilder<ProgressCubit, ProgressState>(
          builder: (context, state) => switch (state) {
            ProgressInitial() || ProgressLoading() => const _LoadingView(),
            ProgressError(:final message) => _ErrorView(message: message),
            ProgressLoaded(:final summary, :final period) =>
                _LoadedView(summary: summary, period: period),
          },
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Loaded View
// ══════════════════════════════════════════════════════════════
class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.summary, required this.period});
  final ProgressSummary summary;
  final ProgressPeriod period;

  @override
  Widget build(BuildContext context) {
    final weightChange = summary.weightChange;
    final totalHours = summary.totalMinutes ~/ 60;

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: () => context.read<ProgressCubit>().load(period),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ─── Header ──────────────────────────────────────
            const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'رحلتك الرياضية',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8A8A8A),
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'تقدمي 📈',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ─── Period Pills ─────────────────────────────────
            Row(
              children: ProgressPeriod.values.map((p) {
                final active = period == p;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: () => context.read<ProgressCubit>().changePeriod(p),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? AppColors.bgDark : AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        p.labelAr,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: active
                              ? AppColors.textOnDark
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // ─── Stats Grid 2×2 ───────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    emoji: '🔥',
                    value: '14',
                    label: 'يوم متتالي',
                    valueColor: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    emoji: '🏋️',
                    value: summary.totalWorkouts.toString(),
                    label: 'تمرين',
                    valueColor: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    emoji: '⚡',
                    value: summary.totalCaloriesBurned > 999
                        ? '${(summary.totalCaloriesBurned / 1000).toStringAsFixed(0)},${(summary.totalCaloriesBurned % 1000).toInt().toString().padLeft(3, '0')}'
                        : summary.totalCaloriesBurned.toInt().toString(),
                    label: 'إجمالي السعرات',
                    valueColor: AppColors.danger,
                    valueFontSize: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    emoji: '⏱',
                    value: '${totalHours}h',
                    label: 'وقت النشاط',
                    valueColor: AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ─── Workouts This Week Chart ─────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'تمارين هذا الأسبوع',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8A8A8A),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    child: _WeeklyBarChart(
                      points: summary.weeklyWorkoutPoints,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ─── Body Stats ───────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => _showWeightSheet(context),
                  child: const Text(
                    'تحديث',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Text(
                  'قياسات الجسم',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8A8A8A),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Weight
            _BodyStatRow(
              emoji: '⚖️',
              label: 'الوزن',
              value: summary.currentWeight != null
                  ? '${summary.currentWeight!.toStringAsFixed(0)} كجم'
                  : '--',
              change: weightChange != null
                  ? '${weightChange < 0 ? '' : '+'}${weightChange.toStringAsFixed(0)} كجم'
                  : null,
              changeColor:
              (weightChange ?? 0) < 0 ? AppColors.accent : AppColors.danger,
            ),
            const SizedBox(height: 8),

            // Height
            _BodyStatRow(
              emoji: '📏',
              label: 'الطول',
              value: '178 سم',
              change: '—',
              changeColor: AppColors.textMuted,
            ),
            const SizedBox(height: 8),

            // BMI
            _BodyStatRow(
              emoji: '🧮',
              label: 'مؤشر كتلة الجسم',
              value: summary.currentWeight != null
                  ? (summary.currentWeight! / (1.78 * 1.78)).toStringAsFixed(1)
                  : '--',
              change: 'وزن طبيعي',
              changeColor: AppColors.accent,
            ),
            const SizedBox(height: 8),

            // Body Fat
            _BodyStatRow(
              emoji: '💧',
              label: 'Body Fat',
              value: '16%',
              change: '-1.2%',
              changeColor: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }

  void _showWeightSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BlocProvider.value(
        value: context.read<WeightLogCubit>(),
        child: const _WeightSheet(),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Stat Card — زي التصميم
// ══════════════════════════════════════════════════════════════
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.valueColor,
    this.valueFontSize = 28,
  });

  final String emoji;
  final String value;
  final String label;
  final Color valueColor;
  final double valueFontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: valueFontSize,
              fontWeight: FontWeight.w900,
              color: valueColor,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: Color(0xFF8A8A8A),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Body Stat Row — زي التصميم
// ══════════════════════════════════════════════════════════════
class _BodyStatRow extends StatelessWidget {
  const _BodyStatRow({
    required this.emoji,
    required this.label,
    required this.value,
    this.change,
    this.changeColor,
  });

  final String emoji;
  final String label;
  final String value;
  final String? change;
  final Color? changeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: Color(0xFF8A8A8A),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (change != null)
            Text(
              change!,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: changeColor ?? AppColors.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Weekly Bar Chart — أعمدة خضراء زي التصميم
// ══════════════════════════════════════════════════════════════
class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({required this.points});
  final List<ChartPoint> points;

  static const _days = ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];

  @override
  Widget build(BuildContext context) {
    // لو مفيش داتا نعمل demo data
    final data = points.isNotEmpty
        ? points
        : List.generate(
        7,
            (i) => ChartPoint(
          x: i.toDouble(),
          y: [1.0, 1.0, 0.0, 1.0, 1.0, 0.0, 0.5][i],
        ));

    final maxY = data.fold(0.0, (m, p) => p.y > m ? p.y : m);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (i) {
        final point =
        i < data.length ? data[i] : ChartPoint(x: i.toDouble(), y: 0);
        final hasWorkout = point.y > 0;
        final heightFraction = maxY > 0 ? (point.y / maxY) : 0.0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Bar
            AnimatedContainer(
              duration: Duration(milliseconds: 300 + (i * 50)),
              width: 28,
              height: hasWorkout ? (60 * heightFraction).clamp(20.0, 60.0) : 4,
              decoration: BoxDecoration(
                color: hasWorkout ? AppColors.accent : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 6),
            // Day label
            Text(
              _days[i],
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8A8A8A),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Weight Sheet
// ══════════════════════════════════════════════════════════════
class _WeightSheet extends StatefulWidget {
  const _WeightSheet();
  @override
  State<_WeightSheet> createState() => _WeightSheetState();
}

class _WeightSheetState extends State<_WeightSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WeightLogCubit, WeightLogState>(
      listener: (context, state) {
        if (state is WeightLogSuccess) Navigator.of(context).pop();
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            16, 24, 16, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'تسجيل الوزن',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _ctrl,
              autofocus: true,
              textDirection: TextDirection.ltr,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
              decoration: InputDecoration(
                labelText: 'الوزن',
                suffixText: 'كجم',
                filled: true,
                fillColor: AppColors.bgElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: BlocBuilder<WeightLogCubit, WeightLogState>(
                builder: (context, state) => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bgDark,
                    foregroundColor: AppColors.textOnDark,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: state is WeightLogLoading
                      ? null
                      : () {
                    final w = double.tryParse(_ctrl.text);
                    if (w != null && w > 0) {
                      context.read<WeightLogCubit>().addEntry(w);
                    }
                  },
                  child: state is WeightLogLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                      : const Text(
                    'حفظ',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Loading / Error
// ══════════════════════════════════════════════════════════════
class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(color: AppColors.accent));
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.error_outline_rounded,
          color: AppColors.danger, size: 48),
      const SizedBox(height: 16),
      Text(message, style: AppTextStyles.bodyMedium),
      const SizedBox(height: 16),
      GestureDetector(
        onTap: () => context.read<ProgressCubit>().load(),
        child: Text('حاول مجدداً', style: AppTextStyles.accentLabel),
      ),
    ]),
  );
}
