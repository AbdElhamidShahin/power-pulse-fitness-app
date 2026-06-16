import '../../../../core/error/failures.dart';
import '../../../../shared/models/exercise.dart';
import '../service/exercise_service.dart';

abstract interface class ExerciseRepository {
  Future<ApiResult<List<Exercise>>> getExercises(String pageId);
}

final class ExerciseRepositoryImpl implements ExerciseRepository {
  ExerciseRepositoryImpl(this._service);

  final ExerciseService _service;

  Map<String, List<Exercise>>? _cache;

  @override
  Future<ApiResult<List<Exercise>>> getExercises(String pageId) async {
    try {
      _cache ??= await _service.loadAll();
      final exercises = _cache![pageId] ?? [];
      return ApiResult.success(exercises);
    } catch (e) {
      return ApiResult.failure(
        CacheFailure('فشل تحميل تمارين $pageId: ${e.toString()}'),
      );
    }
  }
}
