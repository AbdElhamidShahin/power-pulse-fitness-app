import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';

// ─── Features ──────────────────────────────────────────────
// سيتم إضافتهم تدريجياً مع كل Phase
// import '../../features/exercises/...';
// import '../../features/nutrition/...';
// import '../../features/progress/...';
// import '../../features/profile/...';

final GetIt sl = GetIt.instance;

/// يتم استدعاؤه مرة واحدة في main()
Future<void> initDependencies() async {
  // ─── External ─────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // ─── Network ──────────────────────────────────────────────
  sl.registerLazySingleton<Dio>(
        () => DioClient.exerciseDb,
    instanceName: 'exerciseDb',
  );
  sl.registerLazySingleton<Dio>(
        () => DioClient.foodFacts,
    instanceName: 'foodFacts',
  );

  // ─── Features ─────────────────────────────────────────────
  // Phase 3: سيتم إضافة كل feature هنا
  // _initExercises();
  // _initNutrition();
  // _initProgress();
  // _initProfile();
}

// ─── Exercises Feature ─────────────────────────────────────
// void _initExercises() {
//   // Data Sources
//   sl.registerLazySingleton<ExerciseRemoteDataSource>(
//     () => ExerciseRemoteDataSourceImpl(sl(instanceName: 'exerciseDb')),
//   );
//   sl.registerLazySingleton<ExerciseLocalDataSource>(
//     () => ExerciseLocalDataSourceImpl(sl()),
//   );
//   // Repository
//   sl.registerLazySingleton<ExerciseRepository>(
//     () => ExerciseRepositoryImpl(
//       remote: sl(), local: sl(), networkInfo: sl(),
//     ),
//   );
//   // Use Cases
//   sl.registerLazySingleton(() => GetExercisesUseCase(sl()));
//   sl.registerLazySingleton(() => GetExerciseByIdUseCase(sl()));
//   sl.registerLazySingleton(() => SearchExercisesUseCase(sl()));
//   // Cubit
//   sl.registerFactory(() => ExercisesCubit(sl(), sl()));
//   sl.registerFactory(() => ExerciseDetailCubit(sl()));
// }
