import '../../../../core/domain/api_result.dart';
import '../../data/models/exercise_entity.dart';
import '../../data/repositories/exercise_repository.dart';

final class GetExercisesUseCase {
  const GetExercisesUseCase(this._repository);
  final ExerciseRepository _repository;

  Future<ApiResult<List<Exercise>>> call({
    int limit = 20,
    int offset = 0,
  }) async {
    final result = await _repository.getExercises();
    return result.fold(
      onFailure: (f) => Failure(f),
      onSuccess: (all) {
        final page = all.skip(offset).take(limit).toList();
        return Success(page);
      },
    );
  }
}

final class GetExercisesByBodyPartUseCase {
  const GetExercisesByBodyPartUseCase(this._repository);
  final ExerciseRepository _repository;

  Future<ApiResult<List<Exercise>>> call(String bodyPart) =>
      _repository.getExercisesByBodyPart(bodyPart);
}

final class SearchExercisesUseCase {
  const SearchExercisesUseCase(this._repository);
  final ExerciseRepository _repository;

  Future<ApiResult<List<Exercise>>> call(String query) =>
      _repository.searchExercises(query);
}

final class GetExerciseByIdUseCase {
  const GetExerciseByIdUseCase(this._repository);
  final ExerciseRepository _repository;

  Future<ApiResult<Exercise>> call(String id) =>
      _repository.getExerciseById(id);
}

final class GetBodyPartListUseCase {
  const GetBodyPartListUseCase(this._repository);
  final ExerciseRepository _repository;

  Future<ApiResult<List<String>>> call() => _repository.getBodyPartList();
}

final class RefreshExercisesUseCase {
  const RefreshExercisesUseCase(this._repository);
  final ExerciseRepository _repository;

  Future<ApiResult<void>> call() => _repository.refreshExercises();
}
