import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/auth/guest_migration_service.dart';
import '../../../../core/auth/user_mode_service.dart';
import '../../data/auth_profile_sync.dart';
import '../../data/repo/login_repostry.dart';
import 'login_state.dart';

final class LoginCubit extends Cubit<LoginState> {
  LoginCubit(
    this._loginRepository,
    this._prefs,
    this._firestore,
  ) : super(const LoginInitial());

  final LoginRepository _loginRepository;
  final SharedPreferences _prefs;
  final FirebaseFirestore _firestore;

  // ─── Email / Password ────────────────────────────────────────────────────

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    emit(const LoginLoading());

    try {
      final result = await _loginRepository.login(
        email: email,
        password: password,
      );

      await _postLoginSync(
        uid: result.userId,
        name: result.name,
        email: result.email,
        avatarUrl: result.avatarUrl,
        isNewAccount: false, // Existing account → Firestore wins
      );

      if (isClosed) return;

      emit(LoginSuccess(
        userId: result.userId,
        name: result.name,
        email: result.email,
        avatarUrl: result.avatarUrl,
      ));
    } on FirebaseAuthException catch (e) {
      emit(LoginError(_mapFirebaseError(e.code)));
    } catch (_) {
      emit(const LoginError('حدث خطأ غير متوقع، يرجى المحاولة لاحقاً 🚧'));
    }
  }

  // ─── Google Sign-In ──────────────────────────────────────────────────────

  Future<void> loginWithGoogle() async {
    emit(const LoginLoading());

    try {
      final result = await _loginRepository.signInWithGoogle();

      await _postLoginSync(
        uid: result.userId,
        name: result.name,
        email: result.email,
        avatarUrl: result.avatarUrl,
        isNewAccount: false, // Treat as existing account — Firestore wins
      );

      if (isClosed) return;

      emit(LoginSuccess(
        userId: result.userId,
        name: result.name,
        email: result.email,
        avatarUrl: result.avatarUrl,
      ));
    } on FirebaseAuthException catch (e) {
      emit(LoginError(_mapFirebaseError(e.code)));
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('cancelled') || msg.contains('إلغاء')) {
        emit(const LoginInitial());
      } else {
        emit(const LoginError('فشل تسجيل الدخول بحساب جوجل 🚨'));
      }
    }
  }

  // ─── Post-login sync ─────────────────────────────────────────────────────
  //
  // isNewAccount = false → existing account, Firestore wins (Flow 4).
  // isNewAccount = true  → guest migration, upload to Firestore (Flow 3).
  // The router's _initialLocation() handles Flow 5 (app startup).

  Future<void> _postLoginSync({
    required String uid,
    required String name,
    required String email,
    String? avatarUrl,
    required bool isNewAccount,
  }) async {
    final currentMode = await UserModeService.getMode(_prefs);

    if (isNewAccount && currentMode == UserMode.guest) {
      // Flow 3: Guest → new account — upload local guest data to Firestore.
      // Uses merge so this can't accidentally overwrite cloud data.
      await GuestMigrationService.migrateGuestDataToCloud(
        prefs: _prefs,
        firestore: _firestore,
        uid: uid,
      );
    } else {
      // Flow 4: Existing account sign-in — Firestore is the source of truth.
      // Restore cloud data into local SharedPreferences cache.
      // Do NOT upload local guest data.
      await GuestMigrationService.restoreCloudDataToLocal(
        prefs: _prefs,
        firestore: _firestore,
        uid: uid,
      );
    }

    // Update local profile cache with auth identity data
    await AuthProfileSync.saveFromAuth(
      prefs: _prefs,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
    );

    // Mark authenticated mode
    await UserModeService.setAuthenticated(_prefs);
  }

  // ─── Error mapping ────────────────────────────────────────────────────────

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة 🔑';
      case 'user-disabled':
        return 'هذا الحساب معطّل، يرجى التواصل مع الدعم';
      case 'too-many-requests':
        return 'محاولات كثيرة، يرجى الانتظار قليلاً ⏳';
      case 'network-request-failed':
        return 'تحقق من اتصالك بالإنترنت 🌐';
      case 'google-sign-in-cancelled':
        return 'تم إلغاء تسجيل الدخول بجوجل';
      default:
        return 'فشل تسجيل الدخول ($code)';
    }
  }
}
