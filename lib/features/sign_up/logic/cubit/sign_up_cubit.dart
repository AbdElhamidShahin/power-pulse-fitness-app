import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/auth/guest_migration_service.dart';
import '../../../../core/auth/user_mode_service.dart';
import '../../../../core/auth/auth_profile_sync.dart';
import '../../data/repo/sign_up_repo.dart';
import 'sign_up_state.dart';

final class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(this._signUpRepository, this._prefs) : super(const SignUpInitial());

  final SignUpRepository _signUpRepository;
  final SharedPreferences _prefs;

  // ─── Email / Password ────────────────────────────────────────────────────

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

      if (result.requiresEmailVerification) {
        emit(SignUpVerificationRequired(email: result.email));
        return;
      }

      await _postSignUpSync(
        uid: result.userId,
        name: result.name,
        email: result.email,
        avatarUrl: result.avatarUrl,
      );

      emit(SignUpSuccess(name: result.name, email: result.email));
    } on AuthException catch (e) {
      emit(SignUpError(_mapError(e.message)));
    } catch (_) {
      emit(const SignUpError('حدث خطأ غير متوقع، حاول مرة أخرى 🚧'));
    }
  }

  // ─── Google Sign-Up ──────────────────────────────────────────────────────

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
    } on AuthException catch (e) {
      emit(SignUpError(_mapError(e.message)));
    } catch (_) {
      emit(const SignUpError('فشل التسجيل بحساب جوجل 🚨'));
    }
  }

  // ─── Post sign-up: migrate guest data to cloud ───────────────────────────

  Future<void> _postSignUpSync({
    required String uid,
    required String name,
    required String email,
    String? avatarUrl,
  }) async {
    if (uid.isNotEmpty) {
      // Migrate existing local guest data to Supabase cloud.
      await GuestMigrationService.migrateGuestDataToCloud(
        prefs: _prefs,
        supabase: Supabase.instance.client,
        uid: uid,
      );
    }

    await AuthProfileSync.saveFromAuth(
      prefs: _prefs,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
    );

    await UserModeService.setAuthenticated(_prefs);
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  String _mapError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('user already registered')) return 'البريد الإلكتروني مستخدم بالفعل ⚠️';
    if (lower.contains('password should be at least')) return 'كلمة المرور ضعيفة جداً 🔒';
    if (lower.contains('invalid email')) return 'البريد الإلكتروني غير صحيح';
    if (lower.contains('rate limit') || lower.contains('too many requests') || lower.contains('over_email_send_rate_limit')) {
      return 'تم تجاوز حد إرسال رسائل التأكيد مؤقتاً. حاول بعد قليل 📧';
    }
    if (lower.contains('email rate limit exceeded')) {
      return 'تم تجاوز حد إرسال رسائل التأكيد. إعداد SMTP للإنتاج مطلوب 📧';
    }
    return 'فشل إنشاء الحساب، حاول مرة أخرى';
  }
}
