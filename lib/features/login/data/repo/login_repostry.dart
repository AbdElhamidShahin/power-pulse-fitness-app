import 'login_result.dart';

abstract interface class LoginRepository {
  Future<LoginResult> login({
    required String email,
    required String password,
  });

  /// Sign in with Google — returns the result directly (no OAuth redirect needed on mobile).
  Future<LoginResult> signInWithGoogle();
}
