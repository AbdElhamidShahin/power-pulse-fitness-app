import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'reset_password_state.dart';

final class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit() : super(const ResetPasswordInitial());

  Future<void> updatePassword({required String password}) async {
    emit(const ResetPasswordLoading());
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: password),
      );
      if (!isClosed) emit(const ResetPasswordSuccess());
    } on AuthException catch (e) {
      if (!isClosed) emit(ResetPasswordError(_mapError(e.message)));
    } catch (_) {
      if (!isClosed) emit(const ResetPasswordError('تعذر تغيير كلمة المرور، حاول مرة أخرى'));
    }
  }

  String _mapError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('same password')) return 'استخدم كلمة مرور مختلفة عن القديمة';
    if (lower.contains('password')) return 'كلمة المرور غير صالحة، استخدم 8 أحرف على الأقل';
    return 'تعذر تغيير كلمة المرور، حاول مرة أخرى';
  }
}
