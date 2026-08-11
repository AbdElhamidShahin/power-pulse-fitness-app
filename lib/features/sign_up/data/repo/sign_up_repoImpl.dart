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
      throw Exception(
        'فشل إنشاء الحساب، يرجى المحاولة مرة أخرى',
      );
    }

    return SignUpResult(
      userId: user.id,
      email: user.email ?? email,
      name: name,
      avatarUrl: _getAvatarUrl(user),
      requiresEmailVerification: response.session == null,
    );
  }

  @override
  Future<SignUpResult> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.hotelguide://login-callback',
    );

    // Google OAuth لا يرجع User مباشرة من هذه العملية.
    // SignUpCubit يتعامل مع onAuthStateChange.
    return const SignUpResult(
      userId: '',
      email: '',
      name: '',
      avatarUrl: null,
      requiresEmailVerification: false,
    );
  }

  String? _getAvatarUrl(User user) {
    final metadata = user.userMetadata;

    return metadata?['avatar_url'] as String? ??
        metadata?['picture'] as String?;
  }
}