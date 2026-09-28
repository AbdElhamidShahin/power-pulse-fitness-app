import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:power_pulse/core/domain/api_result.dart';

import '../../../../core/domain/app_failure.dart';
import '../../data/models/user_profile_entity.dart';
import '../usecases/profile_usecases.dart';
import 'profile_state.dart';

final class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required GetProfileUseCase getProfile,
  })  : _getProfile = getProfile,
        super(const ProfileInitial());

  final GetProfileUseCase _getProfile;

  Future<void> load() async {
    emit(const ProfileLoading());

    final result = await _getProfile();

    result.fold(
      onSuccess: (profile) {
        emit(ProfileLoaded(profile));
      },
      onFailure: (failure) {
        // _mapFailure أُزيلت — AppFailureX.userMessage
        emit(ProfileError(failure.userMessage));
      },
    );
  }

  void onProfileSaved(UserProfile profile) {
    emit(ProfileLoaded(profile));
  }
}

final class ProfileSaveCubit extends Cubit<ProfileSaveState> {
  ProfileSaveCubit({
    required SaveProfileUseCase saveProfile,
  })  : _saveProfile = saveProfile,
        super(const ProfileSaveIdle());

  final SaveProfileUseCase _saveProfile;

  Future<void> save(UserProfile profile) async {
    emit(const ProfileSaveLoading());

    final result = await _saveProfile(profile);

    result.fold(
      onSuccess: (_) {
        emit(const ProfileSaveSuccess());
      },
      onFailure: (failure) {
        // _mapFailure أُزيلت — AppFailureX.userMessage
        emit(ProfileSaveError(failure.userMessage));
      },
    );
  }

  void reset() {
    emit(const ProfileSaveIdle());
  }
}
