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
import '../widgets/home_greeting_header.dart';
import '../widgets/quick_actions.dart';
import '../widgets/quick_stats_row.dart';

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
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) => switch (state) {
            HomeInitial() || HomeLoading() => const _LoadingView(),
            HomeError(:final message)      => _ErrorView(message: message),
            HomeLoaded(:final summary)     => RefreshIndicator(
                color: AppColors.accent,
                backgroundColor: AppColors.bgSurface,
                onRefresh: () => context.read<HomeCubit>().refresh(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // ─── Greeting ──────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppConstants.screenPaddingH,
                          AppConstants.spaceL,
                          AppConstants.screenPaddingH,
                          AppConstants.spaceXXL,
                        ),
                        child: HomeGreetingHeader(
                          greeting: summary.greeting,
                          profile: summary.profile,
                        ),
                      ),
                    ),

                    // ─── Calorie Card ──────────────────────
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.screenPaddingH),
                      sliver: SliverToBoxAdapter(
                        child: CalorieSummaryCard(
                          consumed: summary.caloriesConsumed,
                          goal: summary.caloriesGoal,
                          protein: summary.dailyNutrition.totalProtein,
                          carbs: summary.dailyNutrition.totalCarbs,
                          fat: summary.dailyNutrition.totalFat,
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(
                        child: SizedBox(height: AppConstants.spaceL)),

                    // ─── Quick Stats ───────────────────────
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.screenPaddingH),
                      sliver: SliverToBoxAdapter(
                        child: QuickStatsRow(
                          weeklyWorkouts: summary.weeklyWorkouts,
                          todayMinutes: summary.todayWorkoutMinutes,
                          hasWorkedOutToday: summary.hasWorkedOutToday,
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(
                        child: SizedBox(height: AppConstants.spaceXXL)),

                    // ─── CTA — ابدأ التمرين ────────────────
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.screenPaddingH),
                      sliver: SliverToBoxAdapter(
                        child: _WorkoutCTA(
                            hasWorkedOut: summary.hasWorkedOutToday),
                      ),
                    ),

                    const SliverToBoxAdapter(
                        child: SizedBox(height: AppConstants.spaceXXL)),

                    // ─── Quick Actions ─────────────────────
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.screenPaddingH),
                      sliver: const SliverToBoxAdapter(
                          child: QuickActions()),
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

// ─── Workout CTA Card ─────────────────────────────────────────
class _WorkoutCTA extends StatelessWidget {
  const _WorkoutCTA({required this.hasWorkedOut});
  final bool hasWorkedOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceL),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.borderAccent),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.accentDim,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Icon(
              hasWorkedOut
                  ? Icons.check_circle_rounded
                  : Icons.fitness_center_rounded,
              color: AppColors.accent,
              size: AppConstants.iconL,
            ),
          ),
          const SizedBox(width: AppConstants.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasWorkedOut ? 'أحسنت! تمرين رائع' : 'جاهز للتمرين؟',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  hasWorkedOut
                      ? 'يمكنك إضافة تمرين آخر'
                      : 'ابدأ تمرينك الآن',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spaceM),
          GestureDetector(
            onTap: () => context.go('/exercises'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceL,
                vertical: AppConstants.spaceM,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Text(
                'ابدأ',
                style: AppTextStyles.labelLarge
                    .copyWith(color: AppColors.textOnAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Loading ─────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => const Center(
      child: CircularProgressIndicator(color: AppColors.accent));
}

// ─── Error ───────────────────────────────────────────────────
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
