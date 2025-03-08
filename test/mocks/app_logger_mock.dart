import 'package:mockito/mockito.dart';
import 'package:boost_sys_weblurk/app/core/logger/app_logger.dart';

class MockAppLogger extends Mock implements AppLogger {
  @override
  void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    super.noSuchMethod(
      Invocation.method(#debug, [message, error, stackTrace]),
    );
  }

  @override
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    super.noSuchMethod(
      Invocation.method(#error, [message, error, stackTrace]),
    );
  }

  @override
  void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    super.noSuchMethod(
      Invocation.method(#warning, [message, error, stackTrace]),
    );
  }

  @override
  void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    super.noSuchMethod(
      Invocation.method(#info, [message, error, stackTrace]),
    );
  }

  @override
  void append(dynamic message) {
    super.noSuchMethod(
      Invocation.method(#append, [message]),
    );
  }

  @override
  void closeAppend() {
    super.noSuchMethod(
      Invocation.method(#closeAppend, []),
    );
  }

  @override
  void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    super.noSuchMethod(
      Invocation.method(#fatal, [message, error, stackTrace]),
    );
  }
}
