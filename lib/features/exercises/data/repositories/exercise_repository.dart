import '../../../../core/domain/api_result.dart';
import '../../../../core/domain/app_failure.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../models/exercise_entity.dart';
import '../services/exercise_service.dart';

/// ExerciseRepository — Repository Layer
/// Single source of truth for exercises
/// Maps exceptions → ApiResult<T>
abstract interface class ExerciseRepository {
  Future<ApiResult<List<Exercise>>> getExercises({int limit, int offset});
  Future<ApiResult<List<Exercise>>> getExercisesByBodyPart(String bodyPart);
  Future<ApiResult<List<Exercise>>> searchExercises(String name);
  Future<ApiResult<Exercise>> getExerciseById(String id);
  Future<ApiResult<List<String>>> getBodyPartList();
}

final class ExerciseRepositoryImpl implements ExerciseRepository {
  const ExerciseRepositoryImpl({
    required this.service,
    required this.networkInfo,
  });

  final ExerciseService service;
  final NetworkInfo networkInfo;

  @override
  Future<ApiResult<List<Exercise>>> getExercises({
    int limit = 20,
    int offset = 0,
  }) =>
      _execute(() => service.getExercises(limit: limit, offset: offset));

  @override
  Future<ApiResult<List<Exercise>>> getExercisesByBodyPart(
    String bodyPart,
  ) =>
      _execute(() => service.getExercisesByBodyPart(bodyPart));

  @override
  Future<ApiResult<List<Exercise>>> searchExercises(String name) =>
      _execute(() => service.searchExercisesByName(name));

  @override
  Future<ApiResult<Exercise>> getExerciseById(String id) =>
      _execute(() => service.getExerciseById(id));

  @override
  Future<ApiResult<List<String>>> getBodyPartList() =>
      _execute(() => service.getBodyPartList());

  // ─── Private helper ─────────────────────────────────────
  Future<ApiResult<T>> _execute<T>(Future<T> Function() call) async {
    if (!await networkInfo.isConnected) {
      return const Failure(NetworkFailure());
    }
    try {
      final data = await call();
      return Success(data);
    } on ServerException catch (e) {
      return Failure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NotFoundException catch (e) {
      return Failure(NotFoundFailure(message: e.message));
    } on NetworkException {
      return const Failure(NetworkFailure());
    } catch (e) {
      return Failure(UnexpectedFailure(message: e.toString()));
    }
  }
}
