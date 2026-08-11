import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repo/sign_up_repo.dart';
import 'sign_up_state.dart';

final class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(this._signUpRepository)
      : super(SignUpInitial()) {
    _listenToAuthChanges();
  }

  final SignUpRepository _signUpRepository;

  StreamSubscription<AuthState>? _authSubscription;

  bool _signUpInitiated = false;

  void _listenToAuthChanges() {
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen(
              (data) async {
            if (!_signUpInitiated) return;

            if (data.event != AuthChangeEvent.signedIn) {
              return;
            }

            final user = data.session?.user;

            if (user == null || isClosed) return;

            final name =
                user.userMetadata?['full_name'] as String? ??
                    user.userMetadata?['name'] as String? ??
                    user.userMetadata?['display_name'] as String? ??
                    'مستخدم جديد';

            final email = user.email ?? '';

            _signUpInitiated = false;

            if (!isClosed) {
              emit(
                SignUpSuccess(
                  name: name,
                  email: email,
                ),
              );
            }
          },
        );
  }

  Future<void> signUpUser({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      emit(
        SignUpError(
          'كلمة المرور وتأكيدها غير متطابقين ❌',
        ),
      );
      return;
    }

    emit(SignUpLoading());

    try {
      final result = await _signUpRepository.signUp(
        email: email,
        password: password,
        name: name,
      );

      if (result.requiresEmailVerification) {
        emit(
          SignUpVerificationRequired(
            email: result.email,
          ),
        );
        return;
      }

      emit(
        SignUpSuccess(
          name: result.name,
          email: result.email,
        ),
      );
    } on AuthException catch (e) {
      emit(SignUpError(_mapError(e.message)));
    } catch (_) {
      emit(
        SignUpError(
          'حدث خطأ غير متوقع، حاول مرة أخرى 🚧',
        ),
      );
    }
  }

  Future<void> signUpWithGoogle() async {
    emit(SignUpLoading());

    _signUpInitiated = true;

    try {
      await _signUpRepository.signInWithGoogle();
    } on AuthException catch (e) {
      _signUpInitiated = false;
      emit(SignUpError(_mapError(e.message)));
    } catch (_) {
      _signUpInitiated = false;
      emit(
        SignUpError(
          'فشل تسجيل الدخول بحساب جوجل 🚨',
        ),
      );
    }
  }

  String _mapError(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('user already registered')) {
      return 'البريد الإلكتروني مستخدم بالفعل ⚠️';
    }

    if (lower.contains('password should be at least')) {
      return 'كلمة المرور ضعيفة جداً 🔒';
    }

    if (lower.contains('invalid email')) {
      return 'البريد الإلكتروني غير صحيح';
    }

    return 'فشل العملية: $message';
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}