import '../../../../core/error/failures.dart';
import '../../../../core/network/food_service.dart';

class FoodNutrition {
  const FoodNutrition({
    required this.label,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final String label;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
}


class FoodDataService {
  const FoodDataService(this._foodService);

  final FoodService _foodService;

  Future<FoodNutrition> getDetails(String query) async {
    try {
      final raw = await _foodService.getFoodDetails(query);
      return FoodNutrition(
        label:    raw['label']    ?? '',
        calories: double.tryParse(raw['calories'] ?? '0') ?? 0,
        protein:  double.tryParse(raw['protein']  ?? '0') ?? 0,
        carbs:    double.tryParse(raw['carbs']    ?? '0') ?? 0,
        fat:      double.tryParse(raw['fat']      ?? '0') ?? 0,
      );
    } on ServerFailure {
      rethrow;
    } on NetworkFailure {
      rethrow;
    } catch (e) {
      throw const NotFoundFailure('لم يتم العثور على بيانات لهذا الطعام');
    }
  }
}
