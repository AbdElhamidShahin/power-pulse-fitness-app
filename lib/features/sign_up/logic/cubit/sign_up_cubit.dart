import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../login/data/auth_profile_sync.dart';
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

      // ← ربط البيانات
      await AuthProfileSync.saveFromAuth(
        prefs: _prefs,
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
  // الـ Cubit لا يعرف Supabase — كل الـ listener موجود داخل Repository

  Future<void> signUpWithGoogle() async {
    emit(const SignUpLoading());

    try {
      final result = await _signUpRepository.signInWithGoogle();

      if (isClosed) return;

      // ← ربط البيانات
      await AuthProfileSync.saveFromAuth(
        prefs: _prefs,
        name: result.name,
        email: result.email,
        avatarUrl: result.avatarUrl,
      );

      emit(SignUpSuccess(name: result.name, email: result.email));
    } on AuthException catch (e) {
      emit(SignUpError(_mapError(e.message)));
    } catch (e) {
      final msg = e.toString();
      emit(SignUpError(
        msg.contains('انتهت مهلة') ? msg : 'فشل التسجيل بحساب جوجل 🚨',
      ));
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  String _mapError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('user already registered')) return 'البريد الإلكتروني مستخدم بالفعل ⚠️';
    if (lower.contains('password should be at least')) return 'كلمة المرور ضعيفة جداً 🔒';
    if (lower.contains('invalid email')) return 'البريد الإلكتروني غير صحيح';
    return 'فشل العملية: $message';
  }
}
