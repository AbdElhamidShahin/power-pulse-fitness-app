import '../../../../core/domain/api_result.dart';
import '../../data/models/exercise_entity.dart';
import '../../data/repositories/exercise_repository.dart';

/// GetExercisesUseCase
final class GetExercisesUseCase {
  const GetExercisesUseCase(this._repository);
  final ExerciseRepository _repository;

  Future<ApiResult<List<Exercise>>> call({
    int limit = 20,
    int offset = 0,
  }) =>
      _repository.getExercises(limit: limit, offset: offset);
}

/// GetExercisesByBodyPartUseCase
final class GetExercisesByBodyPartUseCase {
  const GetExercisesByBodyPartUseCase(this._repository);
  final ExerciseRepository _repository;

  Future<ApiResult<List<Exercise>>> call(String bodyPart) =>
      _repository.getExercisesByBodyPart(bodyPart);
}

/// SearchExercisesUseCase
final class SearchExercisesUseCase {
  const SearchExercisesUseCase(this._repository);
  final ExerciseRepository _repository;

  Future<ApiResult<List<Exercise>>> call(String query) =>
      _repository.searchExercises(query);
}

/// GetExerciseByIdUseCase
final class GetExerciseByIdUseCase {
  const GetExerciseByIdUseCase(this._repository);
  final ExerciseRepository _repository;

  Future<ApiResult<Exercise>> call(String id) =>
      _repository.getExerciseById(id);
}

/// GetBodyPartListUseCase
final class GetBodyPartListUseCase {
  const GetBodyPartListUseCase(this._repository);
  final ExerciseRepository _repository;

  Future<ApiResult<List<String>>> call() => _repository.getBodyPartList();
}
