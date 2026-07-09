import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/constants.dart';
import '../error/exceptions.dart';
import 'api_endpoints.dart';

class DioClient {
  DioClient._();

  static Dio get exerciseDb {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.exerciseDbBaseUrl,
        connectTimeout:const Duration(seconds: AppConfig.apiTimeoutSeconds),
        receiveTimeout: const Duration(seconds: AppConfig.apiTimeoutSeconds),
        headers: {
          'X-RapidAPI-Key': const String.fromEnvironment(
            'RAPIDAPI_KEY',
            defaultValue: 'YOUR_RAPIDAPI_KEY_HERE',
          ),
          'X-RapidAPI-Host': ApiEndpoints.exerciseDbHost,
        },
      ),
    );
    _addInterceptors(dio, name: 'ExerciseDB');
    return dio;
  }

  static Dio get foodFacts {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.foodBaseUrl,
        connectTimeout: const Duration(seconds: AppConfig.apiTimeoutSeconds),
        receiveTimeout: const Duration(seconds: AppConfig.apiTimeoutSeconds),
        headers: {
          'User-Agent': 'PowerPulse/2.0 (Flutter)',
        },
      ),
    );
    _addInterceptors(dio, name: 'FoodFacts');
    return dio;
  }

  static void _addInterceptors(Dio dio, {required String name}) {
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

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, ErrorInterceptorHandler handler) {
          debugPrint('[$name] Error: ${e.type} — ${e.message}');
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
  } catch (_) {
    return 'Server error';
  }
}
