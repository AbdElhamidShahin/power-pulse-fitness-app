final class SignUpResult {
  const SignUpResult({
    required this.userId,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.requiresEmailVerification,
  });

  final String userId;
  final String email;
  final String name;
  final String? avatarUrl;
  final bool requiresEmailVerification;
}