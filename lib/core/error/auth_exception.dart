final class AppAuthException implements Exception {
  const AppAuthException(this.message);

  final String message;

  @override
  String toString() => 'AppAuthException: $message';
}
