class DomainError implements Exception {
  final String message;
  final int code;

  const DomainError({required this.message, required this.code});

  @override
  String toString() => 'DomainError(code: $code, message: $message)';
}

/// Resultado uniforme de las operaciones de la capa de datos (RN-15).
class Result<T> {
  final int status;
  final T? data;
  final DomainError? error;
  final String? errorMessage;

  const Result.success(this.data, {this.status = 200})
      : error = null,
        errorMessage = null;

  const Result._(this.status, this.data, this.error, this.errorMessage);

  factory Result.failure([dynamic statusOrError, dynamic message]) {
    if (statusOrError is DomainError) {
      return Result<T>._(
        statusOrError.code,
        null,
        statusOrError,
        statusOrError.message,
      );
    }

    if (statusOrError is int) {
      final errorObj = message is DomainError
          ? message
          : (message is String
              ? DomainError(message: message, code: statusOrError)
              : DomainError(message: 'Error', code: statusOrError));
      return Result<T>._(
        statusOrError,
        null,
        errorObj,
        errorObj.message,
      );
    }

    final errorText = (statusOrError is String)
        ? statusOrError
        : (message is String ? message : 'Error');
    final errorObj = DomainError(message: errorText, code: 400);
    return Result<T>._(400, null, errorObj, errorText);
  }

  bool get isSuccess => status >= 200 && status < 300;
  bool get isFailure => !isSuccess;
}
