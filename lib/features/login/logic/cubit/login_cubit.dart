import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/auth/guest_migration_service.dart';
import '../../../../core/auth/user_mode_service.dart';
import '../../data/auth_profile_sync.dart';
import '../../data/repo/login_repostry.dart';
import 'login_state.dart';

final class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._loginRepository, this._prefs) : super(const LoginInitial()) {
    _listenToAuthChanges();
  }

  final LoginRepository _loginRepository;
  final SharedPreferences _prefs;

  StreamSubscription<AuthState>? _authSubscription;
  bool _googleSignInInitiated = false;

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
      );

      if (isClosed) return;

      emit(LoginSuccess(
        userId: result.userId,
        name: result.name,
        email: result.email,
        avatarUrl: result.avatarUrl,
      ));
    } on AuthException catch (e) {
      emit(LoginError(_mapError(e.message)));
    } catch (_) {
      emit(const LoginError('حدث خطأ غير متوقع، يرجى المحاولة لاحقاً 🚧'));
    }
  }

  // ─── Google Sign-In ──────────────────────────────────────────────────────

  Future<void> loginWithGoogle() async {
    emit(const LoginLoading());
    _googleSignInInitiated = true;

    try {
      await _loginRepository.signInWithGoogle();
      // النتيجة تيجي عبر _listenToAuthChanges
    } on AuthException catch (e) {
      _googleSignInInitiated = false;
      emit(LoginError(_mapError(e.message)));
    } catch (_) {
      _googleSignInInitiated = false;
      emit(const LoginError('فشل تسجيل الدخول بحساب جوجل 🚨'));
    }
  }

  void _listenToAuthChanges() {
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
          if (!_googleSignInInitiated) return;
          if (data.event != AuthChangeEvent.signedIn) return;

          final user = data.session?.user;
          if (user == null || isClosed) return;

          final name = user.userMetadata?['full_name'] as String? ??
              user.userMetadata?['name'] as String? ??
              user.userMetadata?['display_name'] as String? ??
              'مستخدم';
          final avatarUrl = user.userMetadata?['avatar_url'] as String? ??
              user.userMetadata?['picture'] as String?;

          _googleSignInInitiated = false;

          await _postLoginSync(
            uid: user.id,
            name: name,
            email: user.email ?? '',
            avatarUrl: avatarUrl,
          );

          if (!isClosed) {
            emit(LoginSuccess(
              userId: user.id,
              name: name,
              email: user.email ?? '',
              avatarUrl: avatarUrl,
            ));
          }
        });
  }

  // ─── Post-login: migrate guest data OR restore cloud data ────────────────

  Future<void> _postLoginSync({
    required String uid,
    required String name,
    required String email,
    String? avatarUrl,
  }) async {
    final supabase = Supabase.instance.client;
    final currentMode = await UserModeService.getMode(_prefs);

    if (currentMode == UserMode.guest) {
      // Flow 3: Guest → Account migration
      // Upload local guest data to Supabase, then switch to authenticated mode.
      await GuestMigrationService.migrateGuestDataToCloud(
        prefs: _prefs,
        supabase: supabase,
        uid: uid,
      );
    } else {
      // Flow 4: Existing account sign-in
      // Firestore/Supabase is the source of truth — restore cloud data.
      await GuestMigrationService.restoreCloudDataToLocal(
        prefs: _prefs,
        supabase: supabase,
        uid: uid,
      );
    }

    // Save/update profile from auth data (preserves existing fields if present)
    await AuthProfileSync.saveFromAuth(
      prefs: _prefs,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
    );

    // Mark as authenticated
    await UserModeService.setAuthenticated(_prefs);
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  String _mapError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة 🔑';
    }
    if (message.contains('Email not confirmed')) {
      return 'يرجى تأكيد بريدك الإلكتروني أولاً 📧';
    }
    return 'فشل تسجيل الدخول: $message';
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}
