import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/entry/ui/entry_choice_screen.dart';
import '../../features/exercises/logic/cubit/exercises_cubit.dart';
import '../../features/login/logic/cubit/login_cubit.dart';
import '../../features/login/ui/login_screen.dart';
import '../../features/sign_up/logic/cubit/sign_up_cubit.dart';
import '../../features/sign_up/ui/sign_up_screen.dart';
import '../../features/reset_password/ui/reset_password_screen.dart';
import '../../features/exercises/ui/screens/exercise_detail_screen.dart';
import '../../features/exercises/ui/screens/exercises_screen.dart';
import '../../features/home/logic/cubit/home_cubit.dart';
import '../../features/home/ui/screens/home_screen.dart';
import '../../features/nutrition/ui/screens/nutrition_screen.dart';
import '../../features/progress/ui/screens/progress_screen.dart';
import '../../features/nutrition/data/models/food_entity.dart';
import '../../features/nutrition/logic/cubit/nutrition_cubit.dart';
import '../../features/nutrition/ui/screens/food_search_screen.dart';
import '../../features/onboarding/ui/screens/onboarding_screen.dart';
import '../../features/pedometer/logic/cubit/pedometer_cubit.dart';
import '../../features/profile/logic/cubit/profile_cubit.dart';
import '../../features/profile/logic/cubit/settings_cubit.dart';
import '../../features/profile/ui/screens/edit_profile_screen.dart';
import '../../features/profile/ui/widgets/profile_edit_gate.dart';
import '../../features/profile/ui/screens/profile_screen.dart';
import '../../features/progress/logic/cubit/progress_cubit.dart';
import '../../features/workout_logger/logic/cubit/workout_logger_cubit.dart';
import '../../features/workout_logger/ui/screens/workout_logger_screen.dart';
import '../../features/workout_plan/logic/cubit/workout_plan_cubit.dart';
import '../../features/workout_plan/ui/screens/workout_plan_screen.dart';
import '../../shared/shell/main_shell.dart';
import '../di/injection.dart';
import '../startup.dart';
import 'route_observers.dart';

abstract class AppRouter {
  AppRouter._();

  static const String entry      = '/entry';
  static const String login      = '/login';
  static const String signUp     = '/sign-up';
  static const String resetPassword = '/reset-password';
  static const String onboarding = '/onboarding';
  static const String home       = '/home';
  static const String exercises  = '/exercises';
  static const String nutrition  = '/nutrition';
  static const String nutritionSearch = '/nutrition/search';
  static const String progress   = '/progress';
  static const String profile    = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String workoutLogger = '/workout-logger';
  static const String workoutPlan   = '/workout-plan';

  // ─── Startup routing ─────────────────────────────────────────────────────
  //
  // كل الـ I/O (SharedPreferences + Supabase + cloud restore) اتنقل لـ
  // AppStartup.determine() وبيتنفّذ مرة واحدة في main().
  // هنا بنقرا AppStartup.needsEntry فقط (in-memory، synchronous).
  //
  // ملاحظة: `router` هو static final (lazy)، فبيتبني عند أول وصول ليه —
  // وده بعد AppStartup.determine() في main().

  static final GoRouter router = GoRouter(
    initialLocation: AppStartup.passwordRecoveryPending
        ? resetPassword
        : (AppStartup.needsEntry ? entry : home),
    redirect: (context, state) {
      final path = state.uri.path;
      final authRoutes = {login, signUp, resetPassword, entry};
      final needsEntry = AppStartup.needsEntry;
      final isLoggedIn = Supabase.instance.client.auth.currentUser != null;

      // لسه ماختارش (لا حساب ولا ضيف): وجّهه لشاشة الاختيار
      if (needsEntry && !authRoutes.contains(path)) {
        return entry;
      }

      // Password recovery is a valid authenticated route. The recovery
      // session is created from the deep link, so never redirect it to home.
      if (path == resetPassword) {
        return null;
      }

      // BUGFIX: الضيف لازم يقدر يفتح login / sign-up من الإعدادات.
      // قبل كده كان بيتحوّل للرئيسية لأن الشرط كان بيمنع أي مستخدم
      // "مش محتاج entry" من شاشات الـ auth. دلوقتي بس المسجّل فعلاً يتمنع.
      if (isLoggedIn && authRoutes.contains(path)) {
        return home;
      }

      // الضيف اللي اختار يكمّل بيتخطى شاشة الـ entry
      if (!needsEntry && path == entry) {
        return home;
      }

      return null;
    },
    debugLogDiagnostics: kDebugMode,
    observers: [nutritionRouteObserver, progressRouteObserver, homeRouteObserver],
    routes: [
      // ─── Entry choice screen (first launch) ─────────────────
      GoRoute(
        path: entry,
        builder: (_, __) => const EntryChoiceScreen(),
      ),

      GoRoute(
        path: login,
        builder: (_, __) => BlocProvider(
          create: (_) => sl<LoginCubit>(),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: signUp,
        builder: (_, __) => BlocProvider(
          create: (_) => sl<SignUpCubit>(),
          child: const SignUpScreen(),
        ),
      ),
      GoRoute(
        path: resetPassword,
        builder: (_, __) => const ResetPasswordScreen(),
      ),
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
            // BUGFIX: دول singletons — لو اتحطوا بـ create الـ BlocProvider
            // بيقفلهم (close) لما الـ shell يتشال، وبعدها أي emit بيضرب.
            BlocProvider.value(value: sl<AppSettingsCubit>()),
            BlocProvider.value(value: sl<PedometerCubit>()),
            BlocProvider.value(value: sl<WorkoutPlanCubit>()..ensureLoaded()),
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
                    exerciseId: state.pathParameters['id'] ?? '',
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
            BlocProvider(create: (_) => sl<ExercisesCubit>()),
            BlocProvider(create: (_) => sl<ExerciseSearchCubit>()),
            // نفس الـ instance المشترك — عشان الحفظ يظهر في الرئيسية فوراً
            BlocProvider.value(value: sl<WorkoutPlanCubit>()),
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
          child: const ProfileEditGate(),
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

