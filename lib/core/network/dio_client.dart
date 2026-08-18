import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../error/exceptions.dart';
import 'api_endpoints.dart';

class DioClient {
  DioClient._();
//exercise
  static Dio get exerciseDb {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.exerciseDbBaseUrl,
        connectTimeout: const Duration(seconds: AppConstants.apiTimeoutSeconds),
        receiveTimeout: const Duration(seconds: AppConstants.apiTimeoutSeconds),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );
    _addInterceptors(dio, name: 'ExercisesCDN');
    return dio;
  }

  // ─── Open Food Facts instance ──────────────────────────────
  static Dio get foodFacts {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.foodBaseUrl,
        connectTimeout: const Duration(seconds: AppConstants.apiTimeoutSeconds),
        receiveTimeout: const Duration(seconds: AppConstants.apiTimeoutSeconds),
        headers: {
          'User-Agent': 'PowerPulse/2.0 (Flutter)',
        },
      ),
    );
    _addInterceptors(dio, name: 'FoodFacts');
    return dio;
  }

  // ─── Interceptors ─────────────────────────────────────────
  static void _addInterceptors(Dio dio, {required String name}) {
    // Debug logger
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          requestBody: false,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (o) => debugPrint('[$name] $o'),
        ),
      );
    }

    // Error handler — logs in debug only; never exposes user data
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, ErrorInterceptorHandler handler) {
          if (kDebugMode) {
            debugPrint('[$name] Error: ${e.type} — ${e.message}');
          }
          handler.next(e);
        },
      ),
    );
  }
}

Exception mapDioException(DioException e) {
  return switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.connectionError =>
      const NetworkException(),
    DioExceptionType.badResponse => ServerException(
        message: _extractMessage(e.response),
        statusCode: e.response?.statusCode,
      ),
    _ => ServerException(message: e.message ?? 'Unexpected error'),
  };
}

String _extractMessage(Response? response) {
  try {
    final data = response?.data;
    if (data is Map) {
      return data['message']?.toString() ??
          data['error']?.toString() ??
          'Server error';
    }
    return 'Server error ${response?.statusCode}';
  } catch (e) {
    return 'Server error';
  }
}
