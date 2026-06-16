import '../../../../core/error/failures.dart';
import '../../../../core/models/exercise.dart';
import '../../../../shared/providers/item_provider.dart';

/// Contract: custom workout plan data access.
abstract interface class WorkoutPlanRepository {
  ApiResult<Map<String, List<Exercise>>> getPlans(ItemProvider provider);
  ApiResult<void> addExercise(ItemProvider provider, String day, Exercise exercise);
  ApiResult<void> removeExercise(ItemProvider provider, String day, Exercise exercise);
}

/// Production implementation — delegates to [ItemProvider] (SharedPreferences).
final class WorkoutPlanRepositoryImpl implements WorkoutPlanRepository {
  const WorkoutPlanRepositoryImpl();

  @override
  ApiResult<Map<String, List<Exercise>>> getPlans(ItemProvider provider) {
    try {
      return ApiResult.success(Map.unmodifiable(provider.items));
    } catch (e) {
      return ApiResult.failure(CacheFailure('فشل تحميل الخطة: ${e.toString()}'));
    }
  }

  @override
  ApiResult<void> addExercise(
      ItemProvider provider, String day, Exercise exercise) {
    try {
      provider.addItem(day, exercise);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(CacheFailure('فشل إضافة التمرين: ${e.toString()}'));
    }
  }

  @override
  ApiResult<void> removeExercise(
      ItemProvider provider, String day, Exercise exercise) {
    try {
      provider.removeItem(day, exercise);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(CacheFailure('فشل حذف التمرين: ${e.toString()}'));
    }
  }
}
