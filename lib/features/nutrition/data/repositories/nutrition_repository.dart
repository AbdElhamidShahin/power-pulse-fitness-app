import '../../../../core/domain/api_result.dart';
import '../../../../core/domain/app_failure.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../models/food_entity.dart';
import '../services/nutrition_service.dart';
import '../services/nutrition_local_service.dart';

abstract interface class NutritionRepository {
  Future<ApiResult<List<FoodItem>>> searchFood(String query, {int page});
  Future<ApiResult<FoodItem?>> getFoodByBarcode(String barcode);
  Future<ApiResult<DailyNutrition>> getDailyNutrition(DateTime date);
  Future<ApiResult<void>> addMealEntry(MealEntry entry);
  Future<ApiResult<void>> deleteMealEntry(String entryId, DateTime date);
  Future<ApiResult<double>> getCalorieGoal();
  Future<ApiResult<void>> saveCalorieGoal(double goal);
  Future<ApiResult<double>> getWaterLiters(DateTime date);
  Future<ApiResult<void>> saveWaterLiters(double liters, DateTime date);
}

