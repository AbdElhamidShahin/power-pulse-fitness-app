import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

      // ← ربط البيانات: احفظ Profile في SharedPreferences
      await AuthProfileSync.saveFromAuth(
        prefs: _prefs,
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

          // ← ربط البيانات
          await AuthProfileSync.saveFromAuth(
            prefs: _prefs,
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
