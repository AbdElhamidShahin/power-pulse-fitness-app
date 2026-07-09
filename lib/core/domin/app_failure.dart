/// Power Pulse — AppFailure
/// Pure Dart — Zero Flutter imports
/// Used across domain + data layers
sealed class AppFailure {
  const AppFailure({required this.message});
  final String message;
}

final class ServerFailure extends AppFailure {
  const ServerFailure({required super.message, this.statusCode});
  final int? statusCode;
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure() : super(message: 'تحقق من اتصال الإنترنت');
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure({super.message = 'لم يتم العثور على البيانات'});
}

final class CacheFailure extends AppFailure {
  const CacheFailure({super.message = 'خطأ في التخزين المحلي'});
}

final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure({super.message = 'حدث خطأ غير متوقع'});
}

/// رسالة الـ Failure بالعربي — للـ UI
String failureMessage(AppFailure failure) => switch (failure) {
      NetworkFailure()    => 'تحقق من اتصال الإنترنت',
      ServerFailure()     => 'خطأ في الخادم، حاول لاحقاً',
      NotFoundFailure()   => failure.message,
      CacheFailure()      => 'خطأ في التخزين المحلي',
      UnexpectedFailure() => 'حدث خطأ غير متوقع',
    };
