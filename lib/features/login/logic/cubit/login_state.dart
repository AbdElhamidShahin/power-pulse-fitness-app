sealed class LoginState {
  const LoginState();
}

final class LoginInitial extends LoginState {
  const LoginInitial();
}

final class LoginLoading extends LoginState {
  const LoginLoading();
}

final class LoginSuccess extends LoginState {
  const LoginSuccess({
    required this.userId,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  final String userId;
  final String name;
  final String email;
  final String? avatarUrl;
}

/// Emitted when a guest with local profile data logs into an existing account
/// that has data in Firestore. The user must choose whether to keep their
/// local guest data or replace it with the account's cloud data.
/// Call LoginCubit.resolveConflict(keepLocal: true/false) to proceed.
final class LoginGuestDataConflict extends LoginState {
  const LoginGuestDataConflict({
    required this.accountName,
    required this.accountEmail,
  });

  /// Display name from the Firebase account (shown in the dialog).
  final String accountName;
  final String accountEmail;
}

final class LoginError extends LoginState {
  const LoginError(this.errorMessage);

  final String errorMessage;
}
