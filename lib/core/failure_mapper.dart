import 'error/failures.dart';
import 'error/exceptions.dart';

/// تحويل Exception → Failure
/// بيتستخدم في كل repository
Failure mapExceptionToFailure(Exception e) {
  return switch (e) {
    NetworkException()  => const NetworkFailure(),
    NotFoundException() => NotFoundFailure(message: e.message),
    CacheException()   => CacheFailure(message: e.message),
    ServerException()  => ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ),
    _ => const UnexpectedFailure(),
  };
}

/// رسالة الـ Failure بالعربي
String failureMessage(Failure failure) {
  return switch (failure) {
    NetworkFailure()    => 'تحقق من اتصال الإنترنت',
    ServerFailure()     => 'خطأ في الخادم، حاول لاحقاً',
    NotFoundFailure()   => failure.message,
    CacheFailure()      => 'خطأ في التخزين المحلي',
    UnexpectedFailure() => 'حدث خطأ غير متوقع',
  };
}
