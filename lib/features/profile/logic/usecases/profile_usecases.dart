import '../../../../core/domain/api_result.dart';
import '../../data/models/user_profile_entity.dart';
import '../../data/repositories/profile_repository.dart';

final class GetProfileUseCase {
  const GetProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<ApiResult<UserProfile>> call() {
    return _repository.getProfile();
  }
}

final class SaveProfileUseCase {
  const SaveProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<ApiResult<void>> call(UserProfile profile) {
    return _repository.saveProfile(profile);
  }
}

final class HasProfileUseCase {
  const HasProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<ApiResult<bool>> call() {
    return _repository.hasProfile();
  }
}