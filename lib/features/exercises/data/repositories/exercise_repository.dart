import '../../../../core/domain/api_result.dart';
import '../../../../core/domain/app_failure.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../models/exercise_entity.dart';
import '../services/exercise_service.dart';
import '../services/local_exercises_data.dart';

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
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return Success(LocalExercisesData.exercises);
      }
      final result = await service.getExercises(limit: limit, offset: offset);
      return Success(result);
    } catch (_) {
      // API مش متاح — نرجع البيانات المحلية
      return Success(LocalExercisesData.exercises);
    }
  }

  @override
  Future<ApiResult<List<Exercise>>> getExercisesByBodyPart(String bodyPart) async {
    try {
      if (!await networkInfo.isConnected) {
        return Success(LocalExercisesData.byBodyPart(bodyPart));
      }
      final result = await service.getExercisesByBodyPart(bodyPart);
      return Success(result);
    } catch (_) {
      return Success(LocalExercisesData.byBodyPart(bodyPart));
    }
  }

  @override
  Future<ApiResult<List<Exercise>>> searchExercises(String name) async {
    try {
      if (!await networkInfo.isConnected) {
        return Success(LocalExercisesData.search(name));
      }
      final result = await service.searchExercisesByName(name);
      return Success(result);
    } catch (_) {
      return Success(LocalExercisesData.search(name));
    }
  }

  @override
  Future<ApiResult<Exercise>> getExerciseById(String id) async {
    try {
      if (!await networkInfo.isConnected) {
        final local = LocalExercisesData.byId(id);
        if (local != null) return Success(local);
        return const Failure(NotFoundFailure(message: 'التمرين غير موجود'));
      }
      final result = await service.getExerciseById(id);
      return Success(result);
    } catch (_) {
      final local = LocalExercisesData.byId(id);
      if (local != null) return Success(local);
      return const Failure(NotFoundFailure(message: 'التمرين غير موجود'));
    }
  }

  @override
  Future<ApiResult<List<String>>> getBodyPartList() async {
    try {
      if (!await networkInfo.isConnected) {
        return Success(LocalExercisesData.bodyParts);
      }
      final result = await service.getBodyPartList();
      return Success(result);
    } catch (_) {
      // API مش متاح (403/429) — نرجع القائمة المحلية
      return Success(LocalExercisesData.bodyParts);
    }
  }
}
