import '../../data/models/user_profile_entity.dart';

sealed class ProfileState {
  const ProfileState();
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.profile);

  final UserProfile profile;
}

final class ProfileError extends ProfileState {
  const ProfileError(this.message);

  final String message;
}

// ─────────────────────────────────────────────────────────────
// Save State
// ─────────────────────────────────────────────────────────────

sealed class ProfileSaveState {
  const ProfileSaveState();
}

final class ProfileSaveIdle extends ProfileSaveState {
  const ProfileSaveIdle();
}

final class ProfileSaveLoading extends ProfileSaveState {
  const ProfileSaveLoading();
}

final class ProfileSaveSuccess extends ProfileSaveState {
  const ProfileSaveSuccess();
}

final class ProfileSaveError extends ProfileSaveState {
  const ProfileSaveError(this.message);

  final String message;
}