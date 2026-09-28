import 'login_result.dart';

abstract interface class LoginRepository {
  Future<LoginResult> login({
    required String email,
    required String password,
  });

  /// تسجيل الدخول بـ Google — يُستدعى من LoginCubit
  Future<void> signInWithGoogle();
}
