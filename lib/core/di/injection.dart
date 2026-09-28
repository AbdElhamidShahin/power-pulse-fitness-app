import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/login/data/repo/login_repoImpl.dart';
import '../../features/login/data/repo/login_repostry.dart';
import '../../features/login/logic/cubit/login_cubit.dart';

import '../../features/sign_up/data/repo/sign_up_repo.dart';
import '../../features/sign_up/data/repo/sign_up_repoImpl.dart';
import '../../features/sign_up/logic/cubit/sign_up_cubit.dart';

import '../../features/exercises/data/services/exercise_service.dart';
import '../../features/exercises/data/services/local_exercises_data.dart';
import '../../features/exercises/data/repositories/exercise_repository.dart';
import '../../features/exercises/logic/usecases/exercise_usecases.dart';
import '../../features/exercises/logic/cubit/exercises_cubit.dart';

import '../../features/nutrition/data/repositories/nutrition_repository_impl.dart';
import '../../features/nutrition/data/services/nutrition_service.dart';
import '../../features/nutrition/data/services/nutrition_local_service.dart';
import '../../features/nutrition/data/repositories/nutrition_repository.dart';
import '../../features/nutrition/logic/cubit/nutrition_cubit.dart';

import '../../features/profile/logic/cubit/settings_cubit.dart';
import '../../features/profile/data/services/profile_local_service.dart';
import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/profile/logic/usecases/profile_usecases.dart';
import '../../features/profile/logic/cubit/profile_cubit.dart';

import '../../features/progress/data/services/progress_local_service.dart';
import '../../features/progress/data/repositories/progress_repository.dart';
import '../../features/progress/logic/usecases/progress_usecases.dart';
import '../../features/progress/logic/cubit/progress_cubit.dart';

import '../../features/home/logic/cubit/home_cubit.dart';

import '../../features/workout_logger/data/services/workout_logger_service.dart';
import '../../features/workout_logger/data/repositories/workout_logger_repository.dart';
import '../../features/workout_logger/logic/usecases/workout_logger_usecases.dart';
import '../../features/workout_logger/logic/cubit/workout_logger_cubit.dart';

import '../../features/workout_plan/data/services/workout_plan_service.dart';
import '../../features/workout_plan/data/repositories/workout_plan_repository.dart';
import '../../features/workout_plan/logic/usecases/workout_plan_usecases.dart';
import '../../features/workout_plan/logic/cubit/workout_plan_cubit.dart';

import '../../features/pedometer/data/pedometer_service.dart';
import '../../features/pedometer/logic/cubit/pedometer_cubit.dart';

import '../notifications/notification_service.dart';

import '../network/dio_client.dart';
import '../network/network_info.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  sl.registerSingleton<SharedPreferences>(prefs);

  sl.registerSingleton<Connectivity>(
    Connectivity(),
  );

  sl.registerLazySingleton<Dio>(
        () => DioClient.exerciseDb,
    instanceName: 'exerciseDb',
  );

  sl.registerLazySingleton<Dio>(
        () => DioClient.foodFacts,
    instanceName: 'foodFacts',
  );

  sl.registerLazySingleton<NetworkInfo>(
        () => NetworkInfoImpl(
      sl<Connectivity>(),
    ),
  );

  _initAuth();
  _initExercises();
  _initNutrition();
  _initProgress();
  _initProfile();
  _initHome();
  _initWorkoutLogger();
  _initWorkoutPlan();
  _initSettings();

  await _initPedometer();
  await _initNotifications();
}

void _initAuth() {
  final supabase = Supabase.instance.client;

  sl.registerLazySingleton<LoginRepository>(
        () => LoginRepositoryImpl(supabase),
  );

  sl.registerFactory<LoginCubit>(
        () => LoginCubit(
      sl<LoginRepository>(),
      sl<SharedPreferences>(),
    ),
  );

  sl.registerLazySingleton<SignUpRepository>(
        () => SignUpRepositoryImpl(supabase),
  );

  sl.registerFactory<SignUpCubit>(
        () => SignUpCubit(
      sl<SignUpRepository>(),
      sl<SharedPreferences>(),
    ),
  );
}

void _initExercises() {
  sl.registerLazySingleton<ExerciseService>(
        () => ExerciseServiceImpl(
      sl<Dio>(instanceName: 'exerciseDb'),
    ),
  );

  sl.registerLazySingleton<ExerciseLocalService>(
        () => ExerciseLocalServiceImpl(
      sl<SharedPreferences>(),
    ),
  );

  sl.registerLazySingleton<ExerciseRepository>(
        () => ExerciseRepositoryImpl(
      remoteService: sl(),
      localService: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton(
        () => GetExercisesUseCase(sl()),
  );

  sl.registerLazySingleton(
        () => GetExercisesByBodyPartUseCase(sl()),
  );

  sl.registerLazySingleton(
        () => SearchExercisesUseCase(sl()),
  );

  sl.registerLazySingleton(
        () => GetExerciseByIdUseCase(sl()),
  );

  sl.registerLazySingleton(
        () => GetBodyPartListUseCase(sl()),
  );

  sl.registerLazySingleton(
        () => RefreshExercisesUseCase(sl()),
  );

  sl.registerFactory(
        () => ExercisesCubit(
      getExercises: sl(),
      getByBodyPart: sl(),
      getBodyParts: sl(),
      searchExercises: sl(),
    ),
  );

  sl.registerFactory(
        () => ExerciseSearchCubit(sl()),
  );

  sl.registerFactory(
        () => ExerciseDetailCubit(sl()),
  );
}

void _initNutrition() {
  sl.registerLazySingleton<NutritionService>(
        () => NutritionServiceImpl(
      sl<Dio>(instanceName: 'foodFacts'),
    ),
  );

  sl.registerLazySingleton<NutritionLocalService>(
        () => NutritionLocalServiceImpl(
      sl<SharedPreferences>(),
    ),
  );

  sl.registerLazySingleton<NutritionRepository>(
        () => NutritionRepositoryImpl(
      remoteService: sl(),
      localService: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerFactory(
        () => NutritionCubit(
      sl<NutritionRepository>(),
    ),
  );

  sl.registerFactory(
        () => FoodSearchCubit(
      sl<NutritionRepository>(),
    ),
  );

  sl.registerFactory(
        () => AddMealCubit(
      sl<NutritionRepository>(),
    ),
  );
}

void _initProgress() {
  sl.registerLazySingleton<ProgressLocalService>(
        () => ProgressLocalServiceImpl(
      sl<SharedPreferences>(),
    ),
  );

  sl.registerLazySingleton<ProgressRepository>(
        () => ProgressRepositoryImpl(
      localService: sl(),
    ),
  );

  sl.registerLazySingleton(
        () => GetProgressSummaryUseCase(sl()),
  );

  sl.registerLazySingleton(
        () => AddWeightEntryUseCase(sl()),
  );

  sl.registerLazySingleton(
        () => DeleteWeightEntryUseCase(sl()),
  );

  sl.registerLazySingleton(
        () => LogWorkoutUseCase(sl()),
  );

  sl.registerFactory(
        () => ProgressCubit(
      getSummary: sl(),
    ),
  );

  sl.registerFactory(
        () => WeightLogCubit(
      addWeight: sl(),
      deleteWeight: sl(),
    ),
  );
}

void _initProfile() {
  sl.registerLazySingleton<ProfileLocalService>(
        () => ProfileLocalServiceImpl(
      sl<SharedPreferences>(),
    ),
  );

  sl.registerLazySingleton<ProfileRepository>(
        () => ProfileRepositoryImpl(
      localService: sl(),
    ),
  );

  sl.registerLazySingleton(
        () => GetProfileUseCase(sl()),
  );

  sl.registerLazySingleton(
        () => SaveProfileUseCase(sl()),
  );

  sl.registerLazySingleton(
        () => HasProfileUseCase(sl()),
  );

  sl.registerFactory(
        () => ProfileCubit(
      getProfile: sl<GetProfileUseCase>(),
    ),
  );

  sl.registerFactory(
        () => ProfileSaveCubit(
      saveProfile: sl<SaveProfileUseCase>(),
    ),
  );
}

void _initHome() {
  sl.registerFactory(
        () => HomeCubit(
      getProfile: sl(),
      nutritionRepo: sl(),
      getProgressSummary: sl(),
    ),
  );
}

void _initSettings() {
  sl.registerLazySingleton(
        () => AppSettingsCubit(
      sl<SharedPreferences>(),
    ),
  );
}

void _initWorkoutPlan() {
  sl.registerLazySingleton<WorkoutPlanService>(
        () => WorkoutPlanServiceImpl(
      sl<SharedPreferences>(),
    ),
  );

  sl.registerLazySingleton<WorkoutPlanRepository>(
        () => WorkoutPlanRepositoryImpl(
      sl<WorkoutPlanService>(),
    ),
  );

  sl.registerLazySingleton(
        () => GetWorkoutPlanUseCase(sl()),
  );

  sl.registerLazySingleton(
        () => SaveWorkoutPlanUseCase(sl()),
  );

  sl.registerLazySingleton(
        () => DeleteWorkoutPlanUseCase(sl()),
  );

  sl.registerLazySingleton(
        () => WorkoutPlanCubit(
      getPlan: sl(),
      savePlan: sl(),
      deletePlan: sl(),
    ),
  );
}

void _initWorkoutLogger() {
  sl.registerLazySingleton<WorkoutLoggerService>(
        () => WorkoutLoggerServiceImpl(
      sl<SharedPreferences>(),
    ),
  );

  sl.registerLazySingleton<WorkoutLoggerRepository>(
        () => WorkoutLoggerRepositoryImpl(
      sl<WorkoutLoggerService>(),
    ),
  );

  sl.registerLazySingleton(
        () => GetActiveSessionUseCase(sl()),
  );

  sl.registerLazySingleton(
        () => SaveSessionUseCase(sl()),
  );

  sl.registerLazySingleton(
        () => DeleteSessionUseCase(sl()),
  );

  sl.registerLazySingleton(
        () => GetAllSessionsUseCase(sl()),
  );

  sl.registerFactory(
        () => WorkoutLoggerCubit(
      getActiveSession: sl(),
      saveSession: sl(),
      deleteSession: sl(),
      logWorkout: sl(),
      searchExercises: sl(),
      getExercises: sl(),
    ),
  );
}

Future<void> _initPedometer() async {
  sl.registerLazySingleton<PedometerService>(
        () => PedometerService(
      sl<SharedPreferences>(),
    ),
  );

  sl.registerLazySingleton<PedometerCubit>(
        () => PedometerCubit(
      service: sl<PedometerService>(),
    ),
  );
}

Future<void> _initNotifications() async {
  await NotificationService.instance.init();
}
