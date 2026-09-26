import 'api_failure.dart';

/// A minimal Result type so repositories never throw across their public
/// API — every call resolves to either data or a typed [ApiFailure].
sealed class ApiResult<T> {
  const ApiResult();

  factory ApiResult.success(T data) = ApiSuccess<T>;
  factory ApiResult.failure(ApiFailure failure) = ApiError<T>;

  bool get isSuccess => this is ApiSuccess<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(ApiFailure failure) failure,
  }) {
    final self = this;
    if (self is ApiSuccess<T>) return success(self.data);
    if (self is ApiError<T>) return failure(self.failure);
    throw StateError('Unreachable');
  }
}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

class ApiError<T> extends ApiResult<T> {
  final ApiFailure failure;
  const ApiError(this.failure);
}
