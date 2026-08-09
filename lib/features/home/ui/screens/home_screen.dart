import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../pedometer/ui/widgets/step_counter_card.dart';
import '../../logic/cubit/home_cubit.dart';
import '../../logic/cubit/home_state.dart';
import '../widgets/active_time_card.dart';
import '../widgets/calories_card.dart';
import '../widgets/daily_goals_card.dart';
import '../widgets/home_error_view.dart';
import '../widgets/home_greeting_header.dart';
import '../widgets/home_loading_view.dart';
import '../widgets/quick_access_grid.dart';
import '../widgets/section_label.dart';
import '../widgets/streak_card.dart';
import '../widgets/today_workout_card.dart';

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
            HomeInitial() || HomeLoading() => const HomeLoadingView(),
            HomeError(:final message) => HomeErrorView(message: message),
            HomeLoaded(:final summary) => RefreshIndicator(
              color: AppColors.accent,
              onRefresh: () => context.read<HomeCubit>().refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 100.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GreetingHeader(
                      greeting: summary.greeting,
                      name: summary.profile.name,
                    ),
                    SizedBox(height: 16.h),
                    StreakCard(streak: summary.currentStreak),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: ActiveTimeCard(
                            minutes: summary.todayWorkoutMinutes,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: CaloriesCard(
                            calories: summary.caloriesConsumed,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    DailyGoalsCard(
                      calories: summary.caloriesConsumed,
                      caloriesGoal: summary.caloriesGoal,
                      protein: summary.dailyNutrition.totalProtein,
                      minutes: summary.todayWorkoutMinutes.toDouble(),
                    ),
                    SizedBox(height: 12.h),
                    // ── عداد الخطوات ───────────────────────
                    const StepCounterCard(),
                    SizedBox(height: 20.h),
                    const SectionLabel(label: 'الوصول السريع'),
                    SizedBox(height: 12.h),
                    const QuickAccessGrid(),
                    SizedBox(height: 20.h),
                    const SectionLabel(label: 'تمرين اليوم'),
                    SizedBox(height: 12.h),
                    const TodayWorkoutCard(),
                  ],
                ),
              ),
            ),
          },
        ),
      ),
    );
  }
}
