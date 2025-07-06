abstract class Result<T> {
  const Result();

  factory Result.ok(T value) = Ok._;

  factory Result.error(Exception error) = Error._;

  bool get isSuccess => this is Ok<T>;
  bool get isError => this is Error<T>;
}

final class Ok<T> extends Result<T> {
  const Ok._(this.value);
  final T value;
}

final class Error<T> extends Result<T> {
  Error._(this.error);

  Exception error;
}

extension ResultExtension on Object {
  Result ok() {
    return Result.ok(this);
  }
}

extension ResultException on Exception {
  Result error() {
    return Result.error(this);
  }
}

extension ResultCasting<T> on Result<T> {
  Ok<T> get asOk => this as Ok<T>;
  Error<T> get asError => this as Error<T>;

  // Convenience getters
  T get asSuccess => (this as Ok<T>).value;
  Exception get asErrorValue => (this as Error<T>).error;
}
