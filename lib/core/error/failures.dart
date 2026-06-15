
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

// ── Network / HTTP ────────────────────────────────────────────────────────────

final class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'لا يوجد اتصال بالإنترنت'])
      : super(message);
}

final class ServerFailure extends Failure {
  const ServerFailure({
    required String message,
    this.statusCode,
  }) : super(message);

  final int? statusCode;
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'لم يتم العثور على البيانات'])
      : super(message);
}

// ── Local storage ─────────────────────────────────────────────────────────────

final class CacheFailure extends Failure {
  const CacheFailure([String message = 'خطأ في قراءة البيانات المحلية'])
      : super(message);
}

// ── Domain / Validation ───────────────────────────────────────────────────────

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Generic catch-all for truly unexpected exceptions.
final class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'حدث خطأ غير متوقع']) : super(message);
}


sealed class ApiResult<T> {
  const ApiResult();

  factory ApiResult.success(T data) = ApiSuccess<T>;
  factory ApiResult.failure(Failure failure) = ApiFailure<T>;

  T get dataOrThrow => switch (this) {
    ApiSuccess(:final data) => data,
    ApiFailure(:final failure) => throw failure,
  };

  bool get isSuccess => this is ApiSuccess<T>;
  bool get isFailure => this is ApiFailure<T>;
}

final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);
  final T data;
}

final class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.failure);
  final Failure failure;
}
