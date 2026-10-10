import '../../../../core/domain/api_result.dart';
import '../../../../core/domain/app_failure.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../models/food_entity.dart';
import '../services/nutrition_service.dart';
import '../services/nutrition_local_service.dart';
import 'nutrition_repository.dart';

final class NutritionRepositoryImpl implements NutritionRepository {
  const NutritionRepositoryImpl({
    required this.remoteService,
    required this.localService,
    required this.networkInfo,
  });

  final NutritionService remoteService;
  final NutritionLocalService localService;
  final NetworkInfo networkInfo;


  @override
  Future<ApiResult<List<FoodItem>>> searchFood(
      String query, {
        int page = 1,
      }) async {
    if (!await networkInfo.isConnected) {
      return const Failure(NetworkFailure());
    }
    try {
      final results = await remoteService.searchFood(query, page: page);
      return Success(results);
    } on ServerException catch (e) {
      return Failure(ServerFailure(message: e.message));
    } on NetworkException {
      return const Failure(NetworkFailure());
    } catch (e) {
      return Failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<FoodItem?>> getFoodByBarcode(String barcode) async {
    if (!await networkInfo.isConnected) {
      return const Failure(NetworkFailure());
    }
    try {
      final item = await remoteService.getFoodByBarcode(barcode);
      return Success(item);
    } on ServerException catch (e) {
      return Failure(ServerFailure(message: e.message));
    } catch (e) {
      return Failure(UnexpectedFailure(message: e.toString()));
    }
  }


  @override
  Future<ApiResult<DailyNutrition>> getDailyNutrition(DateTime date) async {
    try {
      final results = await Future.wait([
        localService.getMealEntries(date),
        localService.getCalorieGoal(),
        localService.getWaterLiters(date),
      ]);

      return Success(DailyNutrition(
        date: date,
        entries: results[0] as List<MealEntry>,
        calorieGoal: results[1] as double,
        waterLiters: results[2] as double,
      ));
    } on CacheException catch (e) {
      return Failure(CacheFailure(message: e.message));
    } catch (e) {
      return Failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> addMealEntry(MealEntry entry) async {
    try {
      await localService.addMealEntry(entry);
      return const Success(null);
    } on CacheException catch (e) {
      return Failure(CacheFailure(message: e.message));
    } catch (e) {
      return Failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> deleteMealEntry(String entryId, DateTime date) async {
    try {
      await localService.deleteMealEntry(entryId, date);
      return const Success(null);
    } on CacheException catch (e) {
      return Failure(CacheFailure(message: e.message));
    } catch (e) {
      return Failure(UnexpectedFailure(message: e.toString()));
    }
  }


  @override
  Future<ApiResult<double>> getCalorieGoal() async {
    try {
      return Success(await localService.getCalorieGoal());
    } on CacheException catch (e) {
      return Failure(CacheFailure(message: e.message));
    } catch (e) {
      return Failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> saveCalorieGoal(double goal) async {
    try {
      await localService.saveCalorieGoal(goal);
      return const Success(null);
    } on CacheException catch (e) {
      return Failure(CacheFailure(message: e.message));
    } catch (e) {
      return Failure(UnexpectedFailure(message: e.toString()));
    }
  }


  @override
  Future<ApiResult<double>> getWaterLiters(DateTime date) async {
    try {
      return Success(await localService.getWaterLiters(date));
    } on CacheException catch (e) {
      return Failure(CacheFailure(message: e.message));
    } catch (e) {
      return Failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> saveWaterLiters(double liters, DateTime date) async {
    try {
      await localService.saveWaterLiters(liters, date);
      return const Success(null);
    } on CacheException catch (e) {
      return Failure(CacheFailure(message: e.message));
    } catch (e) {
      return Failure(UnexpectedFailure(message: e.toString()));
    }
  }
}
