import '../../../../core/domain/api_result.dart';
import '../../../../core/domain/app_failure.dart';
import '../../../../core/error/exceptions.dart';
import '../models/workout_session_entity.dart';
import '../services/workout_logger_service.dart';

abstract interface class WorkoutLoggerRepository {
  Future<ApiResult<WorkoutSession?>> getActiveSession();
  Future<ApiResult<void>> saveSession(WorkoutSession session);
  Future<ApiResult<void>> deleteSession(String id);
  Future<ApiResult<List<WorkoutSession>>> getAllSessions({int limitDays});
}

final class WorkoutLoggerRepositoryImpl implements WorkoutLoggerRepository {
  WorkoutLoggerRepositoryImpl(this._service);
  final WorkoutLoggerService _service;

  @override
  Future<ApiResult<WorkoutSession?>> getActiveSession() async {
    try {
      return Success(await _service.getActiveSession());
    } on CacheException catch (e) {
      return Failure(CacheFailure(message: e.message));
    } catch (e) {
      return Failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> saveSession(WorkoutSession session) async {
    try {
      await _service.saveSession(session);
      return const Success(null);
    } on CacheException catch (e) {
      return Failure(CacheFailure(message: e.message));
    } catch (e) {
      return Failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> deleteSession(String id) async {
    try {
      await _service.deleteSession(id);
      return const Success(null);
    } on CacheException catch (e) {
      return Failure(CacheFailure(message: e.message));
    } catch (e) {
      return Failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<WorkoutSession>>> getAllSessions({
    int limitDays = 90,
  }) async {
    try {
      return Success(await _service.getAllSessions(limitDays: limitDays));
    } on CacheException catch (e) {
      return Failure(CacheFailure(message: e.message));
    } catch (e) {
      return Failure(UnexpectedFailure(message: e.toString()));
    }
  }
}
