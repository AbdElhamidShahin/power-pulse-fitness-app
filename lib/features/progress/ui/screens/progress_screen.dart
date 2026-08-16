import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../data/models/progress_entity.dart';
import '../../logic/cubit/progress_cubit.dart';
import '../../logic/cubit/progress_state.dart';
import '../widgets/body_stats_section.dart';
import '../widgets/progress_period_selector.dart';
import '../widgets/progress_stat_card.dart';
import '../widgets/progress_weekly_chart_card.dart';

// RouteObserver عالمي — بيُسجَّل في GoRouter
final RouteObserver<ModalRoute<void>> progressRouteObserver =
RouteObserver<ModalRoute<void>>();

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    context.read<ProgressCubit>().load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) progressRouteObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    progressRouteObserver.unsubscribe(this);
    super.dispose();
  }

  // بيتنادى لما اليوزر يرجع من WorkoutLogger لـ Progress
  @override
  void didPopNext() {
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
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 100.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeaderSection(),
            SizedBox(height: 16.h),
            ProgressPeriodSelector(period: period),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: ProgressStatCard(
                    emoji: '🔥',
                    value: summary.currentStreak.toString(),
                    label: 'يوم متتالي',
                    valueColor: AppColors.warning,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ProgressStatCard(
                    emoji: '🏋️',
                    value: summary.totalWorkouts.toString(),
                    label: 'تمرين',
                    valueColor: AppColors.accent,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: ProgressStatCard(
                    emoji: '⚡',
                    value: summary.totalCaloriesBurned > 999
                        ? '${(summary.totalCaloriesBurned / 1000).toStringAsFixed(0)},${(summary.totalCaloriesBurned % 1000).toInt().toString().padLeft(3, '0')}'
                        : summary.totalCaloriesBurned.toInt().toString(),
                    label: 'إجمالي السعرات',
                    valueColor: AppColors.danger,
                    valueFontSize: 22,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ProgressStatCard(
                    emoji: '⏱',
                    value: '${totalHours}h',
                    label: 'وقت النشاط',
                    valueColor: AppColors.info,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            ProgressWeeklyChartCard(points: summary.weeklyWorkoutPoints),
            SizedBox(height: 14.h),
            BodyStatsSection(summary: summary, weightChange: weightChange),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'رحلتك الرياضية',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8A8A8A),
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'تقدمي 📈',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 28.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

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
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline_rounded,
          color: AppColors.danger,
          size: 48.r,
        ),
        SizedBox(height: 16.h),
        Text(message, style: AppTextStyles.bodyMedium),
        SizedBox(height: 16.h),
        GestureDetector(
          onTap: () => context.read<ProgressCubit>().load(),
          child: Text('حاول مجدداً', style: AppTextStyles.accentLabel),
        ),
      ],
    ),
  );
}
