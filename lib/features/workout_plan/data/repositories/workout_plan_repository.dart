import '../../../../core/domain/api_result.dart';
import '../../../../core/domain/app_failure.dart';
import '../../../../core/error/exceptions.dart';
import '../models/workout_plan_entity.dart';
import '../services/workout_plan_service.dart';

abstract interface class WorkoutPlanRepository {
  Future<ApiResult<WorkoutPlan?>> getPlan();
  Future<ApiResult<void>> savePlan(WorkoutPlan plan);
  Future<ApiResult<void>> deletePlan();
}

final class WorkoutPlanRepositoryImpl implements WorkoutPlanRepository {
  WorkoutPlanRepositoryImpl(this._service);

  final WorkoutPlanService _service;

  @override
  Future<ApiResult<WorkoutPlan?>> getPlan() async {
    try {
      return Success(await _service.getPlan());
    } on CacheException catch (e) {
      return Failure(CacheFailure(message: e.message));
    } catch (e) {
      return Failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> savePlan(WorkoutPlan plan) async {
    try {
      await _service.savePlan(plan);
      return const Success(null);
    } on CacheException catch (e) {
      return Failure(CacheFailure(message: e.message));
    } catch (e) {
      return Failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> deletePlan() async {
    try {
      await _service.deletePlan();
      return const Success(null);
    } on CacheException catch (e) {
      return Failure(CacheFailure(message: e.message));
    } catch (e) {
      return Failure(UnexpectedFailure(message: e.toString()));
    }
  }
}
