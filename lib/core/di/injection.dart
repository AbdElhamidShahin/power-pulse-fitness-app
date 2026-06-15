import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../network/food_service.dart';
import '../services/user_profile_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDi() async {
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  getIt.registerLazySingleton<DioClient>(() => DioClient());

  getIt.registerSingleton<UserProfileService>(UserProfileService.instance);

  getIt.registerLazySingleton<FoodService>(
    () => FoodService(getIt<DioClient>().dio),
  );
}
