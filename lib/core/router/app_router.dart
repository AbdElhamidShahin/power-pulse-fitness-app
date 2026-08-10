import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/exercises/logic/cubit/exercises_cubit.dart';
import '../../features/exercises/ui/screens/exercise_detail_screen.dart';
import '../../features/exercises/ui/screens/exercises_screen.dart';
import '../../features/home/logic/cubit/home_cubit.dart';
import '../../features/home/ui/screens/home_screen.dart';
import '../../features/nutrition/data/models/food_entity.dart';
import '../../features/nutrition/logic/cubit/nutrition_cubit.dart';
import '../../features/nutrition/ui/screens/food_search_screen.dart';
import '../../features/nutrition/ui/screens/nutrition_screen.dart';
import '../../features/onboarding/ui/screens/onboarding_screen.dart';
import '../../features/pedometer/logic/cubit/pedometer_cubit.dart';
import '../../features/profile/logic/cubit/profile_cubit.dart';
import '../../features/profile/logic/cubit/profile_state.dart';
import '../../features/profile/logic/cubit/settings_cubit.dart';
import '../../features/profile/ui/screens/edit_profile_screen.dart';
import '../../features/profile/ui/screens/profile_screen.dart';
import '../../features/progress/logic/cubit/progress_cubit.dart';
import '../../features/progress/ui/screens/progress_screen.dart';
import '../../features/workout_logger/logic/cubit/workout_logger_cubit.dart';
import '../../features/workout_logger/ui/screens/workout_logger_screen.dart';
import '../../features/workout_plan/logic/cubit/workout_plan_cubit.dart';
import '../../features/workout_plan/ui/screens/workout_plan_screen.dart';
import '../../shared/shell/main_shell.dart';
import '../di/injection.dart';

abstract class AppRouter {
  AppRouter._();

  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String exercises = '/exercises';
  static const String nutrition = '/nutrition';
  static const String nutritionSearch = '/nutrition/search';
  static const String progress = '/progress';
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String workoutLogger = '/workout-logger';
  static const String workoutPlan = '/workout-plan';

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
    observers: [nutritionRouteObserver, progressRouteObserver],
    routes: [
      GoRoute(
        path: onboarding,
        builder: (_, __) => BlocProvider(
          create: (_) => sl<ProfileSaveCubit>(),
          child: const OnboardingScreen(),
        ),
      ),

      ShellRoute(
        builder: (context, state, child) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<HomeCubit>()),
            BlocProvider(create: (_) => sl<AppSettingsCubit>()),
            BlocProvider(create: (_) => sl<PedometerCubit>()..start()),
            BlocProvider(create: (_) => sl<WorkoutPlanCubit>()..load()),
          ],
          child: MainShell(child: child),
        ),
        routes: [
          GoRoute(
            path: home,
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: exercises,
            builder: (_, __) => BlocProvider(
              create: (_) => sl<ExercisesCubit>(),
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
                    exerciseId: state.pathParameters['id']!,
                  ),
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
                BlocProvider(create: (_) => sl<ProfileCubit>()..load()),
              ],
              child: const ProgressScreen(),
            ),
          ),
          GoRoute(
            path: profile,
            builder: (_, __) => BlocProvider(
              create: (_) => sl<ProfileCubit>(),
              child: const ProfileScreen(),
            ),
          ),
        ],
      ),

      // ─── Independent Routes ──────────────────────────────────────────────
      GoRoute(
        path: nutritionSearch,
        builder: (context, state) {
          final mealType = state.extra as MealType? ?? MealType.lunch;
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<FoodSearchCubit>()),
              BlocProvider(create: (_) => sl<AddMealCubit>()),
              BlocProvider(create: (_) => sl<NutritionCubit>()),
            ],
            child: FoodSearchScreen(mealType: mealType),
          );
        },
      ),
      GoRoute(
        path: workoutLogger,
        builder: (_, __) => BlocProvider(
          create: (_) => sl<WorkoutLoggerCubit>(),
          child: const WorkoutLoggerScreen(),
        ),
      ),
      GoRoute(
        path: workoutPlan,
        builder: (_, __) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<ExercisesCubit>()..loadInitial()),
            BlocProvider(create: (_) => sl<ExerciseSearchCubit>()),
            BlocProvider(create: (_) => sl<WorkoutPlanCubit>()..load()),
          ],
          child: const WorkoutPlanScreen(),
        ),
      ),
      GoRoute(
        path: profileEdit,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<ProfileSaveCubit>()),
            BlocProvider(create: (_) => sl<ProfileCubit>()),
          ],
          child: const _ProfileEditGate(),
        ),
      ),
    ],
    errorBuilder: (_, state) => const Scaffold(
      body: Center(
        child: Text(
          'الصفحة غير موجودة',
          style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
        ),
      ),
    ),
  );
}

// ─── Profile Edit Gate ────────────────────────────────────────────
class _ProfileEditGate extends StatefulWidget {
  const _ProfileEditGate();

  @override
  State<_ProfileEditGate> createState() => _ProfileEditGateState();
}

class _ProfileEditGateState extends State<_ProfileEditGate> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<ProfileCubit>();
    if (cubit.state is! ProfileLoaded) {
      cubit.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          return BlocProvider(
            create: (_) => sl<ProfileSaveCubit>(),
            child: EditProfileScreen(profile: state.profile),
          );
        }
        if (state is ProfileError) {
          return Scaffold(
            backgroundColor: const Color(0xFF0D0D0D),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: Color(0xFFBFFF00), size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'تعذّر تحميل البيانات',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.read<ProfileCubit>().load(),
                    child: const Text('إعادة المحاولة',
                        style: TextStyle(
                            fontFamily: 'Cairo', color: Color(0xFFBFFF00))),
                  ),
                ],
              ),
            ),
          );
        }
        return const Scaffold(
          backgroundColor: Color(0xFF0D0D0D),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFFBFFF00)),
          ),
        );
      },
    );
  }
}
