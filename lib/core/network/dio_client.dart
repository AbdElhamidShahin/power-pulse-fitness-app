import 'package:dio/dio.dart';
import '../error/failures.dart';

class DioClient {
  DioClient() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 10),
        responseType: ResponseType.json,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(AppInterceptor());
  }

  late final Dio _dio;

  Dio get dio => _dio;
}

// ── Interceptor ───────────────────────────────────────────────────────────────

class AppInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final Failure failure = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const NetworkFailure('انتهت مهلة الاتصال، تحقق من الإنترنت'),
      DioExceptionType.connectionError =>
        const NetworkFailure('تعذّر الاتصال بالخادم'),
      DioExceptionType.badResponse => _mapStatusCode(
          err.response?.statusCode,
          err.response?.statusMessage ?? 'خطأ في الخادم',
        ),
      _ => UnknownFailure('خطأ غير متوقع: ${err.message}'),
    };

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: failure,
        type: err.type,
        message: failure.message,
      ),
    );
  }

  Failure _mapStatusCode(int? code, String message) => switch (code) {
        400 => ValidationFailure('طلب غير صحيح: $message'),
        401 || 403 => const ServerFailure(message: 'غير مصرح بالوصول'),
        404 => const NotFoundFailure(),
        500 =>
          ServerFailure(message: 'خطأ في الخادم ($code)', statusCode: code),
        _ => ServerFailure(message: message, statusCode: code),
      };
}
