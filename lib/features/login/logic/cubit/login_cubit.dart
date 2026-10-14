import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/auth/guest_migration_service.dart';
import '../../../../core/auth/user_mode_service.dart';
import '../../../../core/auth/auth_profile_sync.dart';
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

  // ─── Password reset ─────────────────────────────────────────────────────

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

  Future<void> _postLoginSync({
    required String uid,
    required String name,
    required String email,
    String? avatarUrl,
  }) async {
    final supabase = Supabase.instance.client;
    final currentMode = await UserModeService.getMode(_prefs);
    final previousUid = _prefs.getString('last_authenticated_uid');

    if (currentMode != UserMode.guest &&
        previousUid != null &&
        previousUid != uid) {
      await GuestMigrationService.clearLocalUserData(_prefs);
    }

    try {
      await GuestMigrationService.restoreCloudDataToLocal(
        //استرجاع البيانات من supabase
        prefs: _prefs,
        supabase: supabase,
        uid: uid,
        preferCloud: true,
      );
      if (currentMode == UserMode.guest) {
        await GuestMigrationService.migrateGuestDataToCloud(
          prefs: _prefs,
          supabase: supabase,
          uid: uid,
        );
      }
    } catch (_) {}

    await AuthProfileSync.saveFromAuth(
      // حفظ بيانات prfile
      prefs: _prefs,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
    );

    // Mark as authenticated
    await UserModeService.setAuthenticated(_prefs);
    await _prefs.setString('last_authenticated_uid', uid);
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  String _mapError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة 🔑';
    }
    if (message.contains('Email not confirmed')) {
      return 'يرجى تأكيد بريدك الإلكتروني أولاً 📧';
    }
    final lower = message.toLowerCase();
    if (lower.contains('rate limit') ||
        lower.contains('too many requests') ||
        lower.contains('over_email_send_rate_limit')) {
      return 'تم تجاوز حد إرسال الرسائل مؤقتاً. حاول بعد قليل 📧';
    }
    if (lower.contains('invalid email')) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return 'فشل تسجيل الدخول: حاول مرة أخرى';
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}
