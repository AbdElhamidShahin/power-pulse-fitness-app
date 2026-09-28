sealed class SignUpState {
  const SignUpState();
}

final class SignUpInitial extends SignUpState {
  const SignUpInitial();
}

final class SignUpLoading extends SignUpState {
  const SignUpLoading();
}

final class SignUpSuccess extends SignUpState {
  const SignUpSuccess({
    required this.name,
    required this.email,
  });

  final String name;
  final String email;
}

final class SignUpVerificationRequired extends SignUpState {
  const SignUpVerificationRequired({required this.email});

  final String email;
}

final class SignUpError extends SignUpState {
  const SignUpError(this.errorMessage);

  final String errorMessage;
}
