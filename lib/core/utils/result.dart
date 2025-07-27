sealed class Result<T> {
  const Result();
  factory Result.ok(T value) = Ok._;
  factory Result.error(Exception error) = Error._;
}

final class Ok<T> extends Result<T> {
  const Ok._(this.value);
  final T value;
}

final class Error<T> extends Result<T> {
  const Error._(this.error);
  final Exception error;
}

extension ResultExtensions<T> on Result<T> {
  bool get isOk => this is Ok<T>;
  bool get isError => this is Error<T>;

  T? get valueOrNull {
    switch (this) {
      case Ok(:final value):
        return value;
      case Error():
        return null;
    }
  }

  Exception? get errorOrNull {
    switch (this) {
      case Ok():
        return null;
      case Error(:final error):
        return error;
    }
  }
}
