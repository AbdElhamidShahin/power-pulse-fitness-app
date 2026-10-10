import '../../../../core/domain/api_result.dart';
import '../../../../core/domain/app_failure.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_profile_entity.dart';
import '../services/profile_local_service.dart';

abstract interface class ProfileRepository {
  Future<ApiResult<UserProfile>> getProfile();

  Future<ApiResult<void>> saveProfile(UserProfile profile);

  Future<ApiResult<bool>> hasProfile();
}

final class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({
    required this.localService,
  });

  final ProfileLocalService localService;

  @override
  Future<ApiResult<UserProfile>> getProfile() async {
    try {
      final profile = await localService.getProfile();

      return Success(
        profile ?? kDefaultProfile,
      );
    } on CacheException catch (e) {
      return Failure(
        CacheFailure(message: e.message),
      );
    } catch (e) {
      return Failure(
        UnexpectedFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<ApiResult<void>> saveProfile(
      UserProfile profile,
      ) async {
    try {
      await localService.saveProfile(profile);

      return const Success(null);
    } on CacheException catch (e) {
      return Failure(
        CacheFailure(message: e.message),
      );
    } catch (e) {
      return Failure(
        UnexpectedFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<ApiResult<bool>> hasProfile() async {
    try {
      final hasProfile = await localService.hasProfile();

      return Success(hasProfile);
    } catch (e) {
      return Failure(
        UnexpectedFailure(message: e.toString()),
      );
    }
  }
}