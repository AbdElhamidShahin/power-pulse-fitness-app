import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/pp_button.dart';
import '../../logic/cubit/home_cubit.dart';
import '../../logic/cubit/home_state.dart';
import '../widgets/calorie_summary_card.dart';
import '../widgets/daily_goals_card.dart';
import '../widgets/home_greeting_header.dart';
import '../widgets/quick_actions.dart';
import '../widgets/stats_row.dart';
import '../widgets/streak_progress_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) => switch (state) {
            HomeInitial() || HomeLoading() => const _LoadingView(),
            HomeError(:final message) => _ErrorView(message: message),
            HomeLoaded(:final summary) => RefreshIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.bgSurface,
              onRefresh: () => context.read<HomeCubit>().refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [

                  // ─── Greeting ──────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.screenPaddingH,
                      AppConstants.spaceL,
                      AppConstants.screenPaddingH,
                      AppConstants.spaceXXL,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: HomeGreetingHeader(
                        greeting: summary.greeting,
                        profile: summary.profile,
                      ),
                    ),
                  ),

                  // ─── Streak + Progress Ring ─────────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.screenPaddingH, 0,
                      AppConstants.screenPaddingH,
                      AppConstants.spaceM,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: StreakProgressCard(
                        currentStreak: summary.currentStreak,
                        dailyProgress: summary.weeklyWorkouts > 0
                            ? (summary.todayWorkoutMinutes / 60).clamp(0.0, 1.0)
                            : 0.0,
                      ),
                    ),
                  ),

                  // ─── Calories + Active Time ─────────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.screenPaddingH, 0,
                      AppConstants.screenPaddingH,
                      AppConstants.spaceM,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: StatsRow(
                        caloriesBurned: summary.caloriesConsumed.toInt(),
                        activeMinutes: summary.todayWorkoutMinutes,
                      ),
                    ),
                  ),

                  // ─── Daily Goals (Rings) ────────────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.screenPaddingH, 0,
                      AppConstants.screenPaddingH,
                      AppConstants.spaceM,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: DailyGoalsCard(
                        moveCurrent: summary.caloriesConsumed.toInt(),
                        moveGoal: summary.caloriesGoal.toInt(),
                        exerciseCurrent: summary.todayWorkoutMinutes,
                        exerciseGoal: 60,
                        standCurrent: summary.weeklyWorkouts,
                        standGoal: 12,
                      ),
                    ),
                  ),

                  // ─── Workout CTA ────────────────────────
                  if (!summary.hasWorkedOutToday)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.screenPaddingH, 0,
                        AppConstants.screenPaddingH,
                        AppConstants.spaceM,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _WorkoutHeroCTA(
                          onTap: () => context.go('/workout-logger'),
                        ),
                      ),
                    ),

                  // ─── Quick Access Grid ──────────────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.screenPaddingH, 0,
                      AppConstants.screenPaddingH,
                      AppConstants.spaceM,
                    ),
                    sliver: const SliverToBoxAdapter(child: QuickActions()),
                  ),

                  const SliverToBoxAdapter(
                      child: SizedBox(height: AppConstants.space4XL)),
                ],
              ),
            ),
          },
        ),
      ),
    );
  }
}

// ─── Workout Hero CTA ─────────────────────────────────────────
class _WorkoutHeroCTA extends StatelessWidget {
  const _WorkoutHeroCTA({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceXL),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A2A00), Color(0xFF0D1A00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          border: Border.all(color: AppColors.borderAccent, width: 1.5),
        ),
        child: Row(
          children: [
            // زر play
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.textOnAccent,
                size: 32,
              ),
            ),
            const SizedBox(width: AppConstants.spaceL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ابدأ تمرينك الآن 💪',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textOnDark)),
                  const SizedBox(height: 2),
                  Text('لم تتمرن اليوم بعد — الآن الوقت المثالي',
                      style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.accent, size: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Loading ──────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(color: AppColors.accent));
}

// ─── Error ────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppConstants.spaceXXL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.danger, size: 48),
          const SizedBox(height: AppConstants.spaceM),
          Text(message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: AppConstants.spaceXL),
          PPButton(
            label: 'حاول مجدداً',
            size: PPButtonSize.medium,
            onPressed: () => context.read<HomeCubit>().load(),
          ),
        ],
      ),
    ),
  );
}
