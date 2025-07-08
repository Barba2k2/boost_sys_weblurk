import 'package:result_dart/result_dart.dart' as rd;

/// Interface para padronizar o uso de Result no projeto
abstract class AppResult<T> {
  bool get isSuccess;
  bool get isError;
  T? get data;
  Exception? get error;
}

/// Wrapper para sucesso
class AppSuccess<T> extends AppResult<T> {
  final T value;
  AppSuccess(this.value);

  @override
  bool get isSuccess => true;

  @override
  bool get isError => false;

  @override
  T? get data => value;

  @override
  Exception? get error => null;
}

/// Wrapper para erro
class AppFailure<T> extends AppResult<T> {
  final Exception exception;
  AppFailure(this.exception);

  @override
  bool get isSuccess => false;

  @override
  bool get isError => true;

  @override
  T? get data => null;

  @override
  Exception? get error => exception;
} 