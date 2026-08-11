
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repo/login_result.dart';
import 'login_repostry.dart';

final class LoginRepositoryImpl implements LoginRepository {
const LoginRepositoryImpl(this._supabase);

final SupabaseClient _supabase;

@override
Future<LoginResult> login({
required String email,
required String password,
}) async {
final response = await _supabase.auth.signInWithPassword(
email: email,
password: password,
);

final user = response.user;

if (user == null) {
throw Exception(
'فشل تسجيل الدخول، يرجى المحاولة مرة أخرى',
);
}

final metadata = user.userMetadata ?? const <String, dynamic>{};

final name =
metadata['full_name'] as String? ??
metadata['name'] as String? ??
'مستخدم';

final avatarUrl =
metadata['avatar_url'] as String? ??
metadata['picture'] as String?;

return LoginResult(
userId: user.id,
email: user.email ?? email,
name: name,
avatarUrl: avatarUrl,
);
}
}

