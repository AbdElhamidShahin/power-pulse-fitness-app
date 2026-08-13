import 'sign_up_result.dart';

abstract interface class SignUpRepository {
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<SignUpResult> signInWithGoogle();
}
