
class ServerException implements Exception {
  const ServerException({required this.message, this.statusCode});
  final String message;
  final int? statusCode;
}

class NetworkException implements Exception {
  const NetworkException();
}

class NotFoundException implements Exception {
  const NotFoundException({this.message = 'Not found'});
  final String message;
}

class CacheException implements Exception {
  const CacheException({this.message = 'Cache error'});
  final String message;
}
