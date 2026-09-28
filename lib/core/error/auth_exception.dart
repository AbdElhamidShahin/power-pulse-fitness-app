/// خطأ خاص بطبقة Authentication — بدل ما Supabase AuthException تتسرب للـ Cubit
final class AppAuthException implements Exception {
  const AppAuthException(this.message);

  final String message;

  @override
  String toString() => 'AppAuthException: $message';
}
