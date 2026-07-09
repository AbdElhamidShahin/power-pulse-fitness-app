import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  sl.registerLazySingleton<Dio>(
        () => DioClient.exerciseDb,
    instanceName: 'exerciseDb',
  );
  sl.registerLazySingleton<Dio>(
        () => DioClient.foodFacts,
    instanceName: 'foodFacts',
  );


}
