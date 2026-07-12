import '../../../../core/domain/api_result.dart';
import '../../data/models/food_entity.dart';
import '../../data/repositories/nutrition_repository.dart';

final class SearchFoodUseCase {
  const SearchFoodUseCase(this._repo);
  final NutritionRepository _repo;
  Future<ApiResult<List<FoodItem>>> call(String query, {int page = 1}) =>
      _repo.searchFood(query, page: page);
}

final class GetFoodByBarcodeUseCase {
  const GetFoodByBarcodeUseCase(this._repo);
  final NutritionRepository _repo;
  Future<ApiResult<FoodItem?>> call(String barcode) =>
      _repo.getFoodByBarcode(barcode);
}

final class GetDailyNutritionUseCase {
  const GetDailyNutritionUseCase(this._repo);
  final NutritionRepository _repo;
  Future<ApiResult<DailyNutrition>> call(DateTime date) =>
      _repo.getDailyNutrition(date);
}

final class AddMealEntryUseCase {
  const AddMealEntryUseCase(this._repo);
  final NutritionRepository _repo;
  Future<ApiResult<void>> call(MealEntry entry) =>
      _repo.addMealEntry(entry);
}

final class DeleteMealEntryUseCase {
  const DeleteMealEntryUseCase(this._repo);
  final NutritionRepository _repo;
  Future<ApiResult<void>> call(String entryId) =>
      _repo.deleteMealEntry(entryId);
}

final class SaveCalorieGoalUseCase {
  const SaveCalorieGoalUseCase(this._repo);
  final NutritionRepository _repo;
  Future<ApiResult<void>> call(double goal) =>
      _repo.saveCalorieGoal(goal);
}
