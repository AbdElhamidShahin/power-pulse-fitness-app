import '../../../../core/error/failures.dart';
import '../../../../core/services/user_profile_service.dart';
import 'home_data.dart';

abstract interface class HomeRepository {
  ApiResult<HomeData> getHomeData();
}

final class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._profileService);

  final UserProfileService _profileService;

  @override
  ApiResult<HomeData> getHomeData() {
    try {
      final streak       = _profileService.currentStreak;
      final trainedToday = _profileService.trainedToday;
      final atRisk       = _profileService.daysSinceLastWorkout == 1 && !trainedToday;

      return ApiResult.success(HomeData(
        streak: streak,
        trainedToday: trainedToday,
        atRisk: atRisk,
        thisWeekHistory: _profileService.thisWeekHistory,
        startWeekday: _profileService.startWeekday,
      ));
    } catch (e) {
      return ApiResult.failure(
        CacheFailure('فشل تحميل بيانات الصفحة الرئيسية: ${e.toString()}'),
      );
    }
  }
}
