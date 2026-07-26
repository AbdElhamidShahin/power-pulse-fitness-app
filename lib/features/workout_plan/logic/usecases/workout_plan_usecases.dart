import '../../../../core/domain/api_result.dart';
import '../../data/models/workout_plan_entity.dart';
import '../../data/repositories/workout_plan_repository.dart';

final class GetWorkoutPlanUseCase {
  const GetWorkoutPlanUseCase(this._repo);
  final WorkoutPlanRepository _repo;
  Future<ApiResult<WorkoutPlan?>> call() => _repo.getPlan();
}

final class SaveWorkoutPlanUseCase {
  const SaveWorkoutPlanUseCase(this._repo);
  final WorkoutPlanRepository _repo;
  Future<ApiResult<void>> call(WorkoutPlan plan) => _repo.savePlan(plan);
}

final class DeleteWorkoutPlanUseCase {
  const DeleteWorkoutPlanUseCase(this._repo);
  final WorkoutPlanRepository _repo;
  Future<ApiResult<void>> call() => _repo.deletePlan();
}
