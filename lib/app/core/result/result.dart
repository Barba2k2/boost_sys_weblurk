import 'package:result_dart/result_dart.dart';

/// Encapsulamento para Unit do result_dart
class AppUnit {
  const AppUnit._();
}

const appUnit = AppUnit._();

/// Interface para padronizar o uso de Result no projeto
abstract class AppResult<T> {
  bool get isSuccess;
  bool get isError;
  T? get data;
  Exception? get error;

  AppResult<R> map<R>(R Function(T value) fn);
  AppResult<R> flatMap<R>(AppResult<R> Function(T value) fn);
  ResultDart<Object, Exception> get raw;
}

/// Wrapper para sucesso
class AppSuccess<T> extends AppResult<T> {
  AppSuccess(T value)
      : _raw = value is AppUnit
            ? const Success<Unit, Exception>(unit)
            : Success<Object, Exception>(value as Object);
  final ResultDart<Object, Exception> _raw;

  @override
  bool get isSuccess => _raw.isSuccess();

  @override
  bool get isError => _raw.isError();

  @override
  T? get data =>
      _raw is Success<Unit, Exception> ? appUnit as T : _raw.getOrNull() as T?;

  @override
  Exception? get error => null;

  @override
  AppResult<R> map<R>(R Function(T value) fn) {
    if (isSuccess) {
      try {
        return AppSuccess<R>(fn(data as T));
      } catch (e) {
        return AppFailure(Exception(e.toString()));
      }
    } else {
      return AppFailure(error!);
    }
  }

  @override
  AppResult<R> flatMap<R>(AppResult<R> Function(T value) fn) {
    if (isSuccess) {
      try {
        return fn(data as T);
      } catch (e) {
        return AppFailure(Exception(e.toString()));
      }
    } else {
      return AppFailure(error!);
    }
  }

  @override
  ResultDart<Object, Exception> get raw => _raw;
}

/// Wrapper para erro
class AppFailure<T> extends AppResult<T> {
  AppFailure(this._error) : _raw = Failure<Object, Exception>(_error);
  final Exception _error;
  final ResultDart<Object, Exception> _raw;

  @override
  bool get isSuccess => false;

  @override
  bool get isError => true;

  @override
  T? get data => null;

  @override
  Exception? get error => _error;

  @override
  AppResult<R> map<R>(R Function(T value) fn) => AppFailure<R>(_error);

  @override
  AppResult<R> flatMap<R>(AppResult<R> Function(T value) fn) =>
      AppFailure<R>(_error);

  @override
  ResultDart<Object, Exception> get raw => _raw;
}
