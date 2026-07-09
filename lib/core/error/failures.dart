
sealed class Failure {
  const Failure({required this.message});
  final String message;
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, this.statusCode});
  final int? statusCode;
}


class NetworkFailure extends Failure {
  const NetworkFailure() : super(message: 'تحقق من اتصال الإنترنت');
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'لم يتم العثور على البيانات'});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'خطأ في التخزين المحلي'});
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.message = 'حدث خطأ غير متوقع'});
}
