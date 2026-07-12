import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../data/models/progress_entity.dart';
import '../../logic/cubit/progress_cubit.dart';
import '../../logic/cubit/progress_state.dart';
import '../widgets/progress_charts.dart';
import '../widgets/progress_stat_card.dart';
import '../widgets/weight_history_list.dart';

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
      body: SafeArea(
        child: BlocBuilder<ProgressCubit, ProgressState>(
          builder: (context, state) => switch (state) {
            ProgressInitial() ||
            ProgressLoading()                => const _LoadingView(),
            ProgressError(:final message)    => _ErrorView(message: message),
            ProgressLoaded(:final summary, :final period) =>
              _LoadedView(summary: summary, period: period),
          },
        ),
      ),
      floatingActionButton: _AddWeightFAB(),
    );
  }
}

// ─── Loaded ─────────────────────────────────────────────────
class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.summary, required this.period});
  final ProgressSummary summary;
  final ProgressPeriod period;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              UiConstants.screenPaddingH,
              UiConstants.spaceL,
              UiConstants.screenPaddingH,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('تقدمي',
                          style: Theme.of(context).textTheme.headlineLarge),
                      Text('تابع رحلتك',
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Period selector
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UiConstants.screenPaddingH,
              vertical: UiConstants.spaceL,
            ),
            child: _PeriodSelector(
              selected: period,
              onSelect: (p) =>
                  context.read<ProgressCubit>().changePeriod(p),
            ),
          ),
        ),

        // Stats grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(
              horizontal: UiConstants.screenPaddingH),
          sliver: SliverGrid(
            delegate: SliverChildListDelegate([
              ProgressStatCard(
                value: summary.totalWorkouts.toString(),
                label: 'تمارين مكتملة',
                icon: Icons.fitness_center_rounded,
                iconColor: AppColors.accent,
              ),
              ProgressStatCard(
                value: summary.totalMinutesFormatted,
                label: 'إجمالي الوقت',
                icon: Icons.timer_rounded,
                iconColor: AppColors.info,
              ),
              ProgressStatCard(
                value: summary.totalCaloriesBurned.toInt().toString(),
                label: 'سعرات محروقة',
                suffix: 'كال',
                icon: Icons.local_fire_department_rounded,
                iconColor: AppColors.danger,
              ),
              ProgressStatCard(
                value: summary.currentWeight != null
                    ? summary.currentWeight!.toStringAsFixed(1)
                    : '--',
                suffix: 'كج',
                label: 'الوزن الحالي',
                icon: Icons.monitor_weight_rounded,
                iconColor: AppColors.warning,
                sub: summary.weightChange != null
                    ? '${summary.isWeightLoss ? '▼' : '▲'} ${summary.weightChange!.abs().toStringAsFixed(1)} كج'
                    : null,
                subColor: summary.isWeightLoss
                    ? AppColors.success
                    : AppColors.danger,
              ),
            ]),
            gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: UiConstants.spaceM,
              crossAxisSpacing: UiConstants.spaceM,
              childAspectRatio: 1.1,
            ),
          ),
        ),

        const SliverToBoxAdapter(
            child: SizedBox(height: UiConstants.spaceXXL)),

        // Workout bar chart
        SliverPadding(
          padding: const EdgeInsets.symmetric(
              horizontal: UiConstants.screenPaddingH),
          sliver: SliverToBoxAdapter(
            child: WorkoutBarChart(
              points: summary.weeklyWorkoutPoints,
            ),
          ),
        ),

        const SliverToBoxAdapter(
            child: SizedBox(height: UiConstants.spaceL)),

        // Weight line chart
        SliverPadding(
          padding: const EdgeInsets.symmetric(
              horizontal: UiConstants.screenPaddingH),
          sliver: SliverToBoxAdapter(
            child: WeightChart(points: summary.weightChartPoints),
          ),
        ),

        const SliverToBoxAdapter(
            child: SizedBox(height: UiConstants.spaceXXL)),

        // Weight history
        SliverPadding(
          padding: const EdgeInsets.symmetric(
              horizontal: UiConstants.screenPaddingH),
          sliver: SliverToBoxAdapter(
            child: WeightHistoryList(
              entries: summary.weightEntries,
              onDelete: (id) => context
                  .read<WeightLogCubit>()
                  .deleteEntry(id)
                  .then((_) => context.read<ProgressCubit>().load(period)),
            ),
          ),
        ),

        const SliverToBoxAdapter(
            child: SizedBox(height: UiConstants.space4XL)),
      ],
    );
  }
}

// ─── Period Selector ──────────────────────────────────────────
class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.onSelect});
  final ProgressPeriod selected;
  final ValueChanged<ProgressPeriod> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(UiConstants.radiusM),
      ),
      child: Row(
        children: ProgressPeriod.values
            .map((p) => Expanded(
                  child: GestureDetector(
                    onTap: () => onSelect(p),
                    child: AnimatedContainer(
                      duration: UiConstants.durationFast,
                      padding: const EdgeInsets.symmetric(
                          vertical: UiConstants.spaceS),
                      decoration: BoxDecoration(
                        color: selected == p
                            ? AppColors.accent
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(UiConstants.radiusS),
                      ),
                      child: Text(
                        p.labelAr,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: selected == p
                              ? AppColors.textOnAccent
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ─── FAB — Add Weight ─────────────────────────────────────────
class _AddWeightFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<WeightLogCubit, WeightLogState>(
      listener: (context, state) {
        if (state is WeightLogSuccess) {
          final period = switch (context.read<ProgressCubit>().state) {
            ProgressLoaded(:final period) => period,
            _ => ProgressPeriod.month,
          };
          context.read<ProgressCubit>().load(period);
          context.read<WeightLogCubit>().reset();
        }
      },
      child: FloatingActionButton.extended(
        onPressed: () => _showAddWeightSheet(context),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textOnAccent,
        icon: const Icon(Icons.monitor_weight_rounded),
        label: const Text('تسجيل الوزن',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _showAddWeightSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.bgSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(UiConstants.radiusXL)),
      ),
      builder: (_) => BlocProvider.value(
        value: ctx.read<WeightLogCubit>(),
        child: const _AddWeightSheet(),
      ),
    );
  }
}

class _AddWeightSheet extends StatefulWidget {
  const _AddWeightSheet();

  @override
  State<_AddWeightSheet> createState() => _AddWeightSheetState();
}

class _AddWeightSheetState extends State<_AddWeightSheet> {
  final _controller = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        UiConstants.screenPaddingH,
        UiConstants.spaceXXL,
        UiConstants.screenPaddingH,
        MediaQuery.of(context).viewInsets.bottom + UiConstants.spaceXXL,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('تسجيل الوزن',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: UiConstants.spaceXXL),

          TextField(
            controller: _controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            textDirection: TextDirection.ltr,
            autofocus: true,
            style: AppTextStyles.headlineLarge
                .copyWith(color: AppColors.accent),
            decoration: const InputDecoration(
              labelText: 'الوزن',
              suffixText: 'كج',
            ),
          ),
          const SizedBox(height: UiConstants.spaceL),

          TextField(
            controller: _noteController,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              labelText: 'ملاحظة (اختياري)',
              hintText: 'كيف تشعر؟',
            ),
          ),
          const SizedBox(height: UiConstants.spaceXXL),

          BlocBuilder<WeightLogCubit, WeightLogState>(
            builder: (context, state) {
              final isLoading = state is WeightLogLoading;
              return SizedBox(
                width: double.infinity,
                height: UiConstants.buttonHeightLarge,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          final w = double.tryParse(_controller.text);
                          if (w == null || w <= 0) return;
                          context.read<WeightLogCubit>().addEntry(
                                w,
                                note: _noteController.text.trim().isEmpty
                                    ? null
                                    : _noteController.text.trim(),
                              );
                          Navigator.of(context).pop();
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textOnAccent),
                        )
                      : const Text('حفظ'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Loading / Error ─────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => const Center(
      child: CircularProgressIndicator(color: AppColors.accent));
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.danger, size: 48),
            const SizedBox(height: UiConstants.spaceM),
            Text(message, style: AppTextStyles.bodyMedium),
            const SizedBox(height: UiConstants.spaceL),
            GestureDetector(
              onTap: () => context.read<ProgressCubit>().load(),
              child: Text('حاول مجدداً',
                  style: AppTextStyles.accentLabel),
            ),
          ],
        ),
      );
}
