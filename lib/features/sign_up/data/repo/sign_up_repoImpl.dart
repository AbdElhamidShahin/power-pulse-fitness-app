import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../repo/sign_up_repo.dart';
import '../repo/sign_up_result.dart';

final class SignUpRepositoryImpl implements SignUpRepository {
  SignUpRepositoryImpl(this._auth, this._googleSignIn);

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

// ... inside SignUpRepositoryImpl
  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'null-user',
        message: 'فشل إنشاء الحساب، يرجى المحاولة مرة أخرى',
      );
    }

    // Update display name
    await user.updateDisplayName(name);

    return SignUpResult(
      userId: user.uid,
      email: user.email ?? email,
      name: name,
      avatarUrl: user.photoURL,
      requiresEmailVerification: false,
    );
  }
  @override
  Future<SignUpResult> signInWithGoogle() async {
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

    // Create a new Firebase credential
    final oauthCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase
    final userCredential = await _auth.signInWithCredential(oauthCredential);
    final user = userCredential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'null-user',
        message: 'فشل التسجيل بجوجل',
      );
    }

    return SignUpResult(
      userId: user.uid,
      email: user.email ?? googleUser.email,
      name: user.displayName ?? googleUser.displayName ?? 'مستخدم جديد',
      avatarUrl: user.photoURL ?? googleUser.photoUrl,
      requiresEmailVerification: false, // Google accounts are pre-verified
    );
  }
}
