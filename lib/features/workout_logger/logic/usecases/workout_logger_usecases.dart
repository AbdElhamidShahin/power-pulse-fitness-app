import '../../../../core/domain/api_result.dart';
import '../../data/models/workout_session_entity.dart';
import '../../data/repositories/workout_logger_repository.dart';

final class GetActiveSessionUseCase {
  GetActiveSessionUseCase(this._repo);
  final WorkoutLoggerRepository _repo;
  Future<ApiResult<WorkoutSession?>> call() => _repo.getActiveSession();
}

final class SaveSessionUseCase {
  SaveSessionUseCase(this._repo);
  final WorkoutLoggerRepository _repo;
  Future<ApiResult<void>> call(WorkoutSession session) =>
      _repo.saveSession(session);
}

final class DeleteSessionUseCase {
  DeleteSessionUseCase(this._repo);
  final WorkoutLoggerRepository _repo;
  Future<ApiResult<void>> call(String id) => _repo.deleteSession(id);
}

final class GetAllSessionsUseCase {
  GetAllSessionsUseCase(this._repo);
  final WorkoutLoggerRepository _repo;
  Future<ApiResult<List<WorkoutSession>>> call({int limitDays = 90}) =>
      _repo.getAllSessions(limitDays: limitDays);
}
