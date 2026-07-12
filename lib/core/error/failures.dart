/// Power Pulse — Failures
/// كل أنواع الأخطاء في التطبيق
sealed class Failure {
  const Failure({required this.message});
  final String message;
}

/// خطأ في الشبكة أو السيرفر
class ServerFailure extends Failure {
  const ServerFailure({required super.message, this.statusCode});
  final int? statusCode;
}

/// مفيش إنترنت
class NetworkFailure extends Failure {
  const NetworkFailure() : super(message: 'تحقق من اتصال الإنترنت');
}

/// البيانات مش موجودة
class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'لم يتم العثور على البيانات'});
}

/// خطأ في التخزين المحلي
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'خطأ في التخزين المحلي'});
}

/// خطأ غير متوقع
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.message = 'حدث خطأ غير متوقع'});
}
