import '../../../../core/domain/api_result.dart';
import '../../../../core/domain/app_failure.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../models/exercise_entity.dart';
import '../services/exercise_service.dart';
import '../services/local_exercises_data.dart';

abstract interface class ExerciseRepository {
  Future<ApiResult<List<Exercise>>> getExercises();
  Future<ApiResult<List<Exercise>>> getExercisesByBodyPart(String bodyPart);
  Future<ApiResult<List<Exercise>>>  searchExercises(String name);
  Future<ApiResult<Exercise>>        getExerciseById(String id);
  Future<ApiResult<List<String>>>    getBodyPartList();
  Future<ApiResult<void>>            refreshExercises();
}

final class ExerciseRepositoryImpl implements ExerciseRepository {
  const ExerciseRepositoryImpl({
    required this.remoteService,
    required this.localService,
    required this.networkInfo,
  });

  final ExerciseService      remoteService;
  final ExerciseLocalService localService;
  final NetworkInfo          networkInfo;


  @override
  Future<ApiResult<List<Exercise>>> getExercises() async {
    if (localService.isCached) {
      final cached = localService.getAllExercises();
      if (cached.isNotEmpty) return Success(cached);
    }

    return _fetchAndCache();
  }

  @override
  Future<ApiResult<List<Exercise>>> getExercisesByBodyPart(
      String bodyPart,
      ) async {
    final result = await getExercises();
    return result.fold(
      onFailure: (f) => Failure(f),
      onSuccess: (all) {
        final filtered = all
            .where((e) =>
        e.bodyPart.toLowerCase() == bodyPart.toLowerCase())
            .toList();
        return Success(filtered);
      },
    );
  }

  @override
  Future<ApiResult<List<Exercise>>> searchExercises(String name) async {
    final result = await getExercises();
    return result.fold(
      onFailure: (f) => Failure(f),
      onSuccess: (all) {
        final q = name.toLowerCase().trim();
        final filtered = all
            .where((e) =>
        e.name.toLowerCase().contains(q) ||
            e.target.toLowerCase().contains(q) ||
            e.equipment.toLowerCase().contains(q))
            .toList();
        return Success(filtered);
      },
    );
  }

  @override
  Future<ApiResult<Exercise>> getExerciseById(String id) async {
    final result = await getExercises();
    return result.fold(
      onFailure: (f) => Failure(f),
      onSuccess: (all) {
        try {
          final exercise = all.firstWhere((e) => e.id == id);
          return Success(exercise);
        } catch (_) {
          return const Failure(NotFoundFailure(message: 'Exercise not found'));
        }
      },
    );
  }

  @override
  Future<ApiResult<List<String>>> getBodyPartList() async {
    final result = await getExercises();
    return result.fold(
      onFailure: (f) => Failure(f),
      onSuccess: (all) {
        final parts = all.map((e) => e.bodyPart).toSet().toList()..sort();
        return Success(parts);
      },
    );
  }

  @override
  Future<ApiResult<void>> refreshExercises() async {
    await localService.clearCache();
    final result = await _fetchAndCache();
    return result.fold(
      onFailure: (f) => Failure(f),
      onSuccess: (_) => const Success(null),
    );
  }


  Future<ApiResult<List<Exercise>>> _fetchAndCache() async {
    if (!await networkInfo.isConnected) {
      return const Failure(NetworkFailure());
    }
    try {
      final exercises = await remoteService.fetchAllExercises();
      await localService.saveExercises(exercises);
      return Success(exercises);
    } on ServerException catch (e) {
      return Failure(
          ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const Failure(NetworkFailure());
    } catch (e) {
      return Failure(UnexpectedFailure(message: e.toString()));
    }
  }
}
