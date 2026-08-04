import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/home/logic/cubit/home_cubit.dart';
import '../../features/home/ui/screens/home_screen.dart';
import '../../features/exercises/logic/cubit/exercises_cubit.dart';
import '../../features/exercises/ui/screens/exercises_screen.dart';
import '../../features/exercises/ui/screens/exercise_detail_screen.dart';
import '../../features/nutrition/data/models/food_entity.dart';
import '../../features/nutrition/logic/cubit/nutrition_cubit.dart';
import '../../features/nutrition/ui/screens/nutrition_screen.dart';
import '../../features/nutrition/ui/screens/food_search_screen.dart';
import '../../features/profile/logic/cubit/settings_cubit.dart';
import '../../features/progress/logic/cubit/progress_cubit.dart';
import '../../features/progress/ui/screens/progress_screen.dart';
import '../../features/profile/logic/cubit/profile_cubit.dart';
import '../../features/profile/logic/cubit/profile_state.dart';
import '../../features/profile/ui/screens/profile_screen.dart';
import '../../features/profile/ui/screens/edit_profile_screen.dart';
import '../../features/onboarding/ui/screens/onboarding_screen.dart';
import '../../features/workout_logger/logic/cubit/workout_logger_cubit.dart';
import '../../features/workout_logger/ui/screens/workout_logger_screen.dart';
import '../../features/workout_plan/logic/cubit/workout_plan_cubit.dart';
import '../../features/workout_plan/ui/screens/workout_plan_screen.dart';
import '../../shared/shell/main_shell.dart';
import '../di/injection.dart';

abstract class AppRouter {
  AppRouter._();

  static const String onboarding    = '/onboarding';
  static const String home          = '/home';
  static const String exercises     = '/exercises';
  static const String nutrition     = '/nutrition';
  static const String nutritionSearch = '/nutrition/search';
  static const String progress      = '/progress';
  static const String profile       = '/profile';
  static const String profileEdit   = '/profile/edit';
  static const String workoutLogger = '/workout-logger';
  static const String workoutPlan   = '/workout-plan';

  static Future<String> _initialLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final hasProfile = prefs.containsKey('user_profile');
    return hasProfile ? home : onboarding;
  }

  static final GoRouter router = GoRouter(
    initialLocation: home,
    redirect: (context, state) async {
      final initial = await _initialLocation();
      if (state.uri.path == home && initial == onboarding) {
        return onboarding;
      }
      return null;
    },
    debugLogDiagnostics: true,
    routes: [
      // ─── Onboarding ────────────────────────────────────────
      GoRoute(
        path: onboarding,
        builder: (_, __) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<ProfileSaveCubit>()),
          ],
          child: const OnboardingScreen(),
        ),
      ),

      // ─── Main Shell ────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: home,
            builder: (_, __) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => sl<HomeCubit>()),
                BlocProvider(create: (_) => sl<WorkoutPlanCubit>()..load()),
              ],
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: exercises,
            builder: (_, __) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => sl<ExercisesCubit>()),
                BlocProvider(create: (_) => sl<ExerciseSearchCubit>()),
              ],
              child: const ExercisesScreen(),
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (_) => sl<ExerciseDetailCubit>()),
                    BlocProvider(create: (_) => sl<WorkoutLoggerCubit>()),
                  ],
                  child: ExerciseDetailScreen(
                      exerciseId: state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: nutrition,
            builder: (_, __) => BlocProvider(
              create: (_) => sl<NutritionCubit>(),
              child: const NutritionScreen(),
            ),
          ),
          GoRoute(
            path: progress,
            builder: (_, __) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => sl<ProgressCubit>()),
                BlocProvider(create: (_) => sl<WeightLogCubit>()),
              ],
              child: const ProgressScreen(),
            ),
          ),
          GoRoute(
            path: profile,
            builder: (_, __) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => sl<ProfileCubit>()),
                BlocProvider.value(value: sl<AppSettingsCubit>()),
              ],
              child: const ProfileScreen(),
            ),
          ),
        ],
      ),

      // ─── خارج الـ Shell ────────────────────────────────────
      GoRoute(
        path: nutritionSearch,
        builder: (context, state) {
          final mealType = state.extra as MealType? ?? MealType.lunch;
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<FoodSearchCubit>()),
              BlocProvider(create: (_) => sl<AddMealCubit>()),
              // NutritionCubit خارج الـ ShellRoute فبنعمل instance جديد
              BlocProvider(create: (_) => sl<NutritionCubit>()),
            ],
            child: FoodSearchScreen(mealType: mealType),
          );
        },
      ),

      GoRoute(
        path: workoutLogger,
        builder: (_, __) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<WorkoutLoggerCubit>()),
            BlocProvider.value(value: sl<WorkoutPlanCubit>()),
          ],
          child: const WorkoutLoggerScreen(),
        ),
      ),

      GoRoute(
        path: workoutPlan,
        builder: (_, __) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: sl<WorkoutPlanCubit>()),
            BlocProvider(create: (_) => sl<ExercisesCubit>()..loadInitial()),
            BlocProvider(create: (_) => sl<ExerciseSearchCubit>()),
          ],
          child: const WorkoutPlanScreen(),
        ),
      ),

      GoRoute(
        path: profileEdit,
        builder: (context, state) {
          final profileCubit = sl<ProfileCubit>();
          final profileState = profileCubit.state;
          final profile = profileState is ProfileLoaded
              ? profileState.profile
              : null;
          if (profile == null) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFBFFF00)),
              ),
            );
          }
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<ProfileSaveCubit>()),
              BlocProvider.value(value: profileCubit),
            ],
            child: EditProfileScreen(profile: profile),
          );
        },
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(
        child: Text('الصفحة غير موجودة',
            style: const TextStyle(fontFamily: 'Cairo', color: Colors.white)),
      ),
    ),
  );
}
