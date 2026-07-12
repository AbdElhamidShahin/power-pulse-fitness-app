import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../network/network_info.dart';

import '../../features/exercises/data/services/exercise_service.dart';
import '../../features/exercises/data/repositories/exercise_repository.dart';
import '../../features/exercises/logic/usecases/exercise_usecases.dart';
import '../../features/exercises/logic/cubit/exercises_cubit.dart';

import '../../features/nutrition/data/services/nutrition_service.dart';
import '../../features/nutrition/data/services/nutrition_local_service.dart';
import '../../features/nutrition/data/repositories/nutrition_repository.dart';
import '../../features/nutrition/logic/usecases/nutrition_usecases.dart';
import '../../features/nutrition/logic/cubit/nutrition_cubit.dart';

import '../../features/progress/data/services/progress_local_service.dart';
import '../../features/progress/data/repositories/progress_repository.dart';
import '../../features/progress/logic/usecases/progress_usecases.dart';
import '../../features/progress/logic/cubit/progress_cubit.dart';

import '../../features/profile/data/services/profile_local_service.dart';
import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/profile/logic/usecases/profile_usecases.dart';
import '../../features/profile/logic/cubit/profile_cubit.dart';

import '../../features/home/logic/cubit/home_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerSingleton<Connectivity>(Connectivity());

  sl.registerLazySingleton<Dio>(
      () => DioClient.exerciseDb, instanceName: 'exerciseDb');
  sl.registerLazySingleton<Dio>(
      () => DioClient.foodFacts, instanceName: 'foodFacts');
  sl.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(sl<Connectivity>()));

  _initExercises();
  _initNutrition();
  _initProgress();
  _initProfile();
  _initHome();
}

void _initExercises() {
  sl.registerLazySingleton<ExerciseService>(
      () => ExerciseServiceImpl(sl<Dio>(instanceName: 'exerciseDb')));
  sl.registerLazySingleton<ExerciseRepository>(
      () => ExerciseRepositoryImpl(service: sl(), networkInfo: sl()));
  sl.registerLazySingleton(() => GetExercisesUseCase(sl()));
  sl.registerLazySingleton(() => GetExercisesByBodyPartUseCase(sl()));
  sl.registerLazySingleton(() => SearchExercisesUseCase(sl()));
  sl.registerLazySingleton(() => GetExerciseByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetBodyPartListUseCase(sl()));
  sl.registerFactory(() => ExercisesCubit(
      getExercises: sl(), getByBodyPart: sl(), getBodyParts: sl()));
  sl.registerFactory(() => ExerciseSearchCubit(sl()));
  sl.registerFactory(() => ExerciseDetailCubit(sl()));
}

void _initNutrition() {
  sl.registerLazySingleton<NutritionService>(
      () => NutritionServiceImpl(sl<Dio>(instanceName: 'foodFacts')));
  sl.registerLazySingleton<NutritionLocalService>(
      () => NutritionLocalServiceImpl(sl<SharedPreferences>()));
  sl.registerLazySingleton<NutritionRepository>(() => NutritionRepositoryImpl(
      remoteService: sl(), localService: sl(), networkInfo: sl()));
  sl.registerLazySingleton(() => SearchFoodUseCase(sl()));
  sl.registerLazySingleton(() => GetFoodByBarcodeUseCase(sl()));
  sl.registerLazySingleton(() => GetDailyNutritionUseCase(sl()));
  sl.registerLazySingleton(() => AddMealEntryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteMealEntryUseCase(sl()));
  sl.registerLazySingleton(() => SaveCalorieGoalUseCase(sl()));
  sl.registerFactory(() => NutritionCubit(
      getDailyNutrition: sl(), addMealEntry: sl(), deleteMealEntry: sl()));
  sl.registerFactory(() => FoodSearchCubit(sl()));
  sl.registerFactory(() => AddMealCubit(sl()));
}

void _initProgress() {
  sl.registerLazySingleton<ProgressLocalService>(
      () => ProgressLocalServiceImpl(sl<SharedPreferences>()));
  sl.registerLazySingleton<ProgressRepository>(
      () => ProgressRepositoryImpl(localService: sl()));
  sl.registerLazySingleton(() => GetProgressSummaryUseCase(sl()));
  sl.registerLazySingleton(() => AddWeightEntryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteWeightEntryUseCase(sl()));
  sl.registerLazySingleton(() => LogWorkoutUseCase(sl()));
  sl.registerFactory(() => ProgressCubit(getSummary: sl()));
  sl.registerFactory(() => WeightLogCubit(addWeight: sl(), deleteWeight: sl()));
}

void _initProfile() {
  sl.registerLazySingleton<ProfileLocalService>(
      () => ProfileLocalServiceImpl(sl<SharedPreferences>()));
  sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(localService: sl()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => SaveProfileUseCase(sl()));
  sl.registerLazySingleton(() => HasProfileUseCase(sl()));
  sl.registerFactory(() => ProfileCubit(getProfile: sl()));
  sl.registerFactory(() => ProfileSaveCubit(saveProfile: sl()));
}

void _initHome() {
  sl.registerFactory(() => HomeCubit(
        getProfile:         sl(),
        getDailyNutrition:  sl(),
        getProgressSummary: sl(),
      ));
}
