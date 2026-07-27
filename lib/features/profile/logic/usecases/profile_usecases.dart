import '../../../../core/domain/api_result.dart';
import '../../data/models/user_profile_entity.dart';
import '../../data/repositories/profile_repository.dart';

final class GetProfileUseCase {
  const GetProfileUseCase(this._repo);
  final ProfileRepository _repo;
  Future<ApiResult<UserProfile>> call() => _repo.getProfile();
}

final class SaveProfileUseCase {
  const SaveProfileUseCase(this._repo);
  final ProfileRepository _repo;
  Future<ApiResult<void>> call(UserProfile profile) =>
      _repo.saveProfile(profile);
}

final class HasProfileUseCase {
  const HasProfileUseCase(this._repo);
  final ProfileRepository _repo;
  Future<ApiResult<bool>> call() => _repo.hasProfile();
}
