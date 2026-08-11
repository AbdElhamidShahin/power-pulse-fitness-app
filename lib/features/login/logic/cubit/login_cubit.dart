import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repo/login_repostry.dart';
import 'login_state.dart';

final class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._loginRepository) : super(LoginInitial());

  final LoginRepository _loginRepository;

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    emit(LoginLoading());

    try {
      final result = await _loginRepository.login(
        email: email,
        password: password,
      );

      emit(
        LoginSuccess(
          userId: result.userId,
          name: result.name,
          email: result.email,
          avatarUrl: result.avatarUrl,
        ),
      );
    } on AuthException catch (e) {
      emit(LoginError(_mapError(e.message)));
    } catch (_) {
      emit(
        LoginError(
          'حدث خطأ غير متوقع، يرجى المحاولة لاحقاً 🚧',
        ),
      );
    }
  }

  String _mapError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة 🔑';
    }

    if (message.contains('Email not confirmed')) {
      return 'يرجى تأكيد بريدك الإلكتروني أولاً 📧';
    }

    return 'فشل تسجيل الدخول: $message';
  }
}
