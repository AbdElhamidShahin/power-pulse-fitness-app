import '../../../../core/error/failures.dart';
import '../../../../core/services/user_profile_service.dart';

abstract interface class WorkoutCompletionRepository {
  Future<ApiResult<void>> recordCompletion([DateTime? when]);
}

final class WorkoutCompletionRepositoryImpl
    implements WorkoutCompletionRepository {
  const WorkoutCompletionRepositoryImpl(this._profileService);

  final UserProfileService _profileService;

  @override
  Future<ApiResult<void>> recordCompletion([DateTime? when]) async {
    try {
      await _profileService.recordWorkoutCompleted(when);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(
        CacheFailure('فشل تسجيل إتمام التمرين: ${e.toString()}'),
      );
    }
  }
}
