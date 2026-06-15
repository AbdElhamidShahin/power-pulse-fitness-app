import '../../../../core/error/failures.dart';
import '../../../../core/services/user_profile_service.dart';

abstract interface class OnboardingRepository {
  Future<ApiResult<void>> saveProfile({
    required String level,
    required String goal,
  });
}

final class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl(this._profileService);

  final UserProfileService _profileService;

  @override
  Future<ApiResult<void>> saveProfile({
    required String level,
    required String goal,
  }) async {
    try {
      await _profileService.completeOnboarding(level: level, goal: goal);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(
        CacheFailure('فشل حفظ بيانات الإعداد: ${e.toString()}'),
      );
    }
  }
}
