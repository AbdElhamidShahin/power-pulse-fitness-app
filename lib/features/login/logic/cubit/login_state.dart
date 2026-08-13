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

final class LoginError extends LoginState {
  const LoginError(this.errorMessage);

  final String errorMessage;
}
