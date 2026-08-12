import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../repo/login_result.dart';
import 'login_repostry.dart';

final class LoginRepositoryImpl implements LoginRepository {
  LoginRepositoryImpl(this._auth, this._googleSignIn);

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'null-user',
        message: 'فشل تسجيل الدخول، يرجى المحاولة مرة أخرى',
      );
    }

    return LoginResult(
      userId: user.uid,
      email: user.email ?? email,
      name: user.displayName ?? 'مستخدم',
      avatarUrl: user.photoURL,
    );
  }

  @override
  Future<LoginResult> signInWithGoogle() async {
    // Trigger the Google Sign In flow
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'google-sign-in-cancelled',
        message: 'تم إلغاء تسجيل الدخول بجوجل',
      );
    }

    // Obtain the auth details
    final googleAuth = await googleUser.authentication;

    // Create a new credential
    final oauthCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google credential
    final userCredential = await _auth.signInWithCredential(oauthCredential);
    final user = userCredential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'null-user',
        message: 'فشل تسجيل الدخول بجوجل',
      );
    }

    return LoginResult(
      userId: user.uid,
      email: user.email ?? googleUser.email,
      name: user.displayName ?? googleUser.displayName ?? 'مستخدم',
      avatarUrl: user.photoURL ?? googleUser.photoUrl,
    );
  }
}
