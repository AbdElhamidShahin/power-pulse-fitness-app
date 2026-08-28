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

  // ─── Pending conflict resolution data ────────────────────────────────────
  // Set when a LoginGuestDataConflict is emitted; cleared after resolution.
  String? _pendingUid;
  String? _pendingName;
  String? _pendingEmail;
  String? _pendingAvatarUrl;

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
      // LoginSuccess (or LoginGuestDataConflict) is emitted by _postLoginSync
      // via _finaliseLogin. Do not emit again here.
    } on FirebaseAuthException catch (e) {
      emit(LoginError(_mapFirebaseError(e.code)));
    } catch (e) {
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
      // LoginSuccess (or LoginGuestDataConflict) is emitted by _postLoginSync
      // via _finaliseLogin. Do not emit again here.
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
    } else if (currentMode == UserMode.guest &&
        _prefs.containsKey('user_profile')) {
      // Flow 4 — CONFLICT: guest has local profile data AND is logging into
      // an existing account. Restoring cloud data would silently overwrite
      // the guest's locally-entered profile. Pause and ask the user to choose.
      _pendingUid       = uid;
      _pendingName      = name;
      _pendingEmail     = email;
      _pendingAvatarUrl = avatarUrl;
      emit(LoginGuestDataConflict(
        accountName:  name,
        accountEmail: email,
      ));
      return; // Do NOT proceed — wait for resolveConflict() to be called.
    } else {
      // Flow 4 (no local guest data): safe to restore cloud data directly.
      await GuestMigrationService.restoreCloudDataToLocal(
        prefs: _prefs,
        firestore: _firestore,
        uid: uid,
      );
    }

    await _finaliseLogin(
      uid: uid,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
    );
  }

  /// Called by the UI after the user resolves the guest-data conflict dialog.
  ///
  /// [keepLocal] = true  → discard cloud profile/plan; keep local guest data.
  /// [keepLocal] = false → overwrite local data with cloud data (original behavior).
  Future<void> resolveConflict({required bool keepLocal}) async {
    final uid       = _pendingUid;
    final name      = _pendingName;
    final email     = _pendingEmail;
    final avatarUrl = _pendingAvatarUrl;

    // Clear pending data regardless of outcome.
    _pendingUid = _pendingName = _pendingEmail = _pendingAvatarUrl = null;

    if (uid == null || name == null || email == null) {
      emit(const LoginError('حدث خطأ غير متوقع، يرجى المحاولة لاحقاً 🚧'));
      return;
    }

    emit(const LoginLoading());

    try {
      if (!keepLocal) {
        // User chose to use their account data — restore from Firestore.
        await GuestMigrationService.restoreCloudDataToLocal(
          prefs: _prefs,
          firestore: _firestore,
          uid: uid,
        );
      }
      // keepLocal = true → skip restore; local data is already in place.
      // Either way, finalise the login (write auth identity + set mode).

      await _finaliseLogin(
        uid: uid,
        name: name,
        email: email,
        avatarUrl: avatarUrl,
      );
    } catch (e) {
      emit(const LoginError('حدث خطأ غير متوقع، يرجى المحاولة لاحقاً 🚧'));
    }
  }

  /// Shared final step: write auth identity into the local profile cache and
  /// mark the user as authenticated. Emits LoginSuccess.
  Future<void> _finaliseLogin({
    required String uid,
    required String name,
    required String email,
    String? avatarUrl,
  }) async {
    await AuthProfileSync.saveFromAuth(
      prefs: _prefs,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
    );
    await UserModeService.setAuthenticated(_prefs);

    if (isClosed) return;
    emit(LoginSuccess(
      userId: uid,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
    ));
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
