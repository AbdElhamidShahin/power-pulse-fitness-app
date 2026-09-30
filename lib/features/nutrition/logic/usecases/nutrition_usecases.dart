import '../../../../core/domain/api_result.dart';
import '../../data/models/food_entity.dart';
import '../../data/repositories/nutrition_repository.dart';

/// UseCase: جلب تغذية يوم معيّن.
/// أُنشئت في Step 4 لإزالة انتهاك P1:
/// HomeCubit كان بيستورد NutritionRepository مباشرة (cross-feature).
final class GetDailyNutritionUseCase {
  const GetDailyNutritionUseCase(this._repo);
  final NutritionRepository _repo;

  Future<ApiResult<DailyNutrition>> call(DateTime date) =>
      _repo.getDailyNutrition(date);
}
