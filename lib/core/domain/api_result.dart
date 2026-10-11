import 'app_failure.dart';

sealed class ApiResult<T> {
  const ApiResult();
}

final class Success<T> extends ApiResult<T> {
  const Success(this.data);
  final T data;
}

final class Failure<T> extends ApiResult<T> {
  const Failure(this.failure);
  final AppFailure failure;
}

// ─── Extensions ───────────────────────────────────────────
extension ApiResultX<T> on ApiResult<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
        Success<T>(:final data) => data,
        Failure<T>()            => null,
      };

  AppFailure? get failureOrNull => switch (this) {
        Failure<T>(:final failure) => failure,
        Success<T>()               => null,
      };

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppFailure failure) onFailure,
  }) =>
      switch (this) {
        Success<T>(:final data)       => onSuccess(data),
        Failure<T>(:final failure)    => onFailure(failure),
      };
}
