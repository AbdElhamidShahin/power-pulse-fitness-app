
final class LoginResult {
const LoginResult({
required this.userId,
required this.email,
required this.name,
this.avatarUrl,
});

final String userId;
final String email;
final String name;
final String? avatarUrl;
}

