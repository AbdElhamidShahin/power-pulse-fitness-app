import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:power_pulse/core/domain/api_result.dart';

import '../../../../core/domain/app_failure.dart';
import '../../data/models/user_profile_entity.dart';
import '../usecases/profile_usecases.dart';
import 'profile_state.dart';

/// ProfileCubit — تحميل الملف الشخصي
final class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required GetProfileUseCase getProfile})
      : _getProfile = getProfile,
        super(const ProfileInitial());

  final GetProfileUseCase _getProfile;

  Future<void> load() async {
    emit(const ProfileLoading());
    final result = await _getProfile();
    result.fold(
      onSuccess: (profile) => emit(ProfileLoaded(profile)),
      onFailure: (f) => emit(ProfileError(_map(f))),
    );
  }

  /// تحديث الـ state بعد حفظ ناجح
  void onProfileSaved(UserProfile updated) =>
      emit(ProfileLoaded(updated));

  String _map(AppFailure f) => switch (f) {
        CacheFailure()      => 'خطأ في قراءة البيانات',
        UnexpectedFailure() => 'حدث خطأ غير متوقع',
        _                   => 'حدث خطأ',
      };
}

/// ProfileSaveCubit — حفظ / تعديل الملف الشخصي
final class ProfileSaveCubit extends Cubit<ProfileSaveState> {
  ProfileSaveCubit({required SaveProfileUseCase saveProfile})
      : _saveProfile = saveProfile,
        super(const ProfileSaveIdle());

  final SaveProfileUseCase _saveProfile;

  Future<void> save(UserProfile profile) async {
    emit(const ProfileSaveLoading());
    final result = await _saveProfile(profile);
    result.fold(
      onSuccess: (_) => emit(const ProfileSaveSuccess()),
      onFailure: (f) => emit(ProfileSaveError(_map(f))),
    );
  }

  void reset() => emit(const ProfileSaveIdle());

  String _map(AppFailure f) => switch (f) {
        CacheFailure() => 'خطأ في حفظ البيانات',
        _              => 'حدث خطأ غير متوقع',
      };
}
