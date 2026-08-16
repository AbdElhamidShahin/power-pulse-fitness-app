import 'sign_up_result.dart';

abstract interface class SignUpRepository {
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String name,
  });

  /// Sign in/up with Google — returns the result directly (no OAuth redirect needed on mobile).
  Future<SignUpResult> signInWithGoogle();
}
