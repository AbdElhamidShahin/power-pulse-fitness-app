import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/auth/guest_migration_service.dart';
import '../../../../core/auth/user_mode_service.dart';
import '../../../login/data/auth_profile_sync.dart';
import '../../data/repo/sign_up_repo.dart';
import 'sign_up_state.dart';

final class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(
    this._signUpRepository,
    this._prefs,
    this._firestore,
  ) : super(const SignUpInitial());

  final SignUpRepository _signUpRepository;
  final SharedPreferences _prefs;
  final FirebaseFirestore _firestore;


  Future<void> signUpUser({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      emit(const SignUpError('كلمة المرور وتأكيدها غير متطابقين ❌'));
      return;
    }

    emit(const SignUpLoading());

    try {
      final result = await _signUpRepository.signUp(
        email: email,
        password: password,
        name: name,
      );

      if (isClosed) return;
   await _postSignUpSync(
        uid: result.userId,
        name: result.name,
        email: result.email,
        avatarUrl: result.avatarUrl,
      );

      emit(SignUpSuccess(name: result.name, email: result.email));
    } on FirebaseAuthException catch (e) {
      emit(SignUpError(_mapFirebaseError(e.code)));
    } catch (_) {
      emit(const SignUpError('حدث خطأ غير متوقع، حاول مرة أخرى 🚧'));
    }
  }


  Future<void> signUpWithGoogle() async {
    emit(const SignUpLoading());

    try {
      final result = await _signUpRepository.signInWithGoogle();

      if (isClosed) return;

  await _postSignUpSync(
        uid: result.userId,
        name: result.name,
        email: result.email,
        avatarUrl: result.avatarUrl,
      );

      emit(SignUpSuccess(name: result.name, email: result.email));
    } on FirebaseAuthException catch (e) {
      emit(SignUpError(_mapFirebaseError(e.code)));
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('cancelled') || msg.contains('إلغاء')) {
        emit(const SignUpInitial());
      } else {
        emit(SignUpError(
          msg.contains('انتهت مهلة') ? msg : 'فشل التسجيل بحساب جوجل 🚨',
        ));
      }
    }
  }


  Future<void> _postSignUpSync({
    required String uid,
    required String name,
    required String email,
    String? avatarUrl,
  }) async {
 await GuestMigrationService.migrateGuestDataToCloud(
      prefs: _prefs,
      firestore: _firestore,
      uid: uid,
    );

  await AuthProfileSync.saveFromAuth(
      prefs: _prefs,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
    );

    await UserModeService.setAuthenticated(_prefs);
  }


  String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل ⚠️';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً 🔒';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'operation-not-allowed':
        return 'هذه الطريقة غير مفعّلة، يرجى التواصل مع الدعم';
      case 'network-request-failed':
        return 'تحقق من اتصالك بالإنترنت 🌐';
      case 'google-sign-in-cancelled':
        return 'تم إلغاء التسجيل بجوجل';
      default:
        return 'فشل العملية ($code)';
    }
  }
}
