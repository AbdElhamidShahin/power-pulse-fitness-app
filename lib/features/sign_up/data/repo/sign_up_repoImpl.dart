import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../repo/sign_up_repo.dart';
import '../repo/sign_up_result.dart';

final class SignUpRepositoryImpl implements SignUpRepository {
  const SignUpRepositoryImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'full_name': name,
      },
    );

    final user = response.user;

    if (user == null) {
      throw Exception('فشل إنشاء الحساب، يرجى المحاولة مرة أخرى');
    }

    return SignUpResult(
      userId: user.id,
      email: user.email ?? email,
      name: name,
      avatarUrl: _getAvatarUrl(user),
      requiresEmailVerification: response.session == null,
    );
  }

  /// يبدأ Google OAuth ثم ينتظر AuthChangeEvent.signedIn من Supabase.
  /// كل منطق الـ listener هنا داخل الـ Repository — الـ Cubit مش بيعرف Supabase.
  @override
  Future<SignUpResult> signInWithGoogle() async {
    final completer = Completer<SignUpResult>();

    StreamSubscription<AuthState>? sub;

    sub = _supabase.auth.onAuthStateChange.listen((data) async {
      if (data.event != AuthChangeEvent.signedIn) return;

      final user = data.session?.user;
      if (user == null) {
        completer.completeError(Exception('فشل الحصول على بيانات المستخدم'));
        await sub?.cancel();
        return;
      }

      final name =
          user.userMetadata?['full_name'] as String? ??
              user.userMetadata?['name'] as String? ??
              user.userMetadata?['display_name'] as String? ??
              'مستخدم جديد';

      completer.complete(
        SignUpResult(
          userId: user.id,
          email: user.email ?? '',
          name: name,
          avatarUrl: _getAvatarUrl(user),
          requiresEmailVerification: false,
        ),
      );

      await sub?.cancel();
    });

    // ابدأ OAuth — النتيجة تيجي عبر الـ listener فوق
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.hotelguide://login-callback',
    );

    // انتظر النتيجة أو timeout بعد 2 دقيقة
    return completer.future.timeout(
      const Duration(minutes: 2),
      onTimeout: () {
        sub?.cancel();
        throw Exception('انتهت مهلة تسجيل الدخول بجوجل، يرجى المحاولة مرة أخرى');
      },
    );
  }

  String? _getAvatarUrl(User user) {
    final metadata = user.userMetadata;
    return metadata?['avatar_url'] as String? ?? metadata?['picture'] as String?;
  }
}
