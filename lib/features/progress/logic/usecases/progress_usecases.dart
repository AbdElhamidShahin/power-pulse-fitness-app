import '../../../../core/domain/api_result.dart';
import '../../data/models/progress_entity.dart';
import '../../data/repositories/progress_repository.dart' ;

final class GetProgressSummaryUseCase {
  const GetProgressSummaryUseCase(this._repo);
  final ProgressRepository _repo;
  Future<ApiResult<ProgressSummary>> call(ProgressPeriod period) =>
      _repo.getSummary(period);
}

final class AddWeightEntryUseCase {
  const AddWeightEntryUseCase(this._repo);
  final ProgressRepository _repo;
  Future<ApiResult<void>> call(WeightEntry entry) =>
      _repo.addWeightEntry(entry);
}

final class DeleteWeightEntryUseCase {
  const DeleteWeightEntryUseCase(this._repo);
  final ProgressRepository _repo;
  Future<ApiResult<void>> call(String id) => _repo.deleteWeightEntry(id);
}

final class LogWorkoutUseCase {
  const LogWorkoutUseCase(this._repo);
  final ProgressRepository _repo;
  Future<ApiResult<void>> call(WorkoutLog log) => _repo.logWorkout(log);
}
