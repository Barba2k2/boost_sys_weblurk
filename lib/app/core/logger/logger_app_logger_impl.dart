import 'dart:io';

import 'package:logger/logger.dart';

import 'app_logger.dart';

class LoggerAppLoggerImpl implements AppLogger {
  final logger = Logger();
  var messages = <String>[];
  final _logFile = File('logs/app.log');
  final _maxLogSize = 10 * 1024 * 1024;

  LoggerAppLoggerImpl() {
    _initializeLogger();
  }

  Future<void> _initializeLogger() async {
    try {
      final logDir = Directory('logs');
      if (!await logDir.exists()) {
        await logDir.create();
      }

      // Rotacionar logs se necessário
      if (await _logFile.exists()) {
        final size = await _logFile.length();
        if (size > _maxLogSize) {
          final backup = File('logs/app.log.old');
          if (await backup.exists()) {
            await backup.delete();
          }
          await _logFile.rename('logs/app.log.old');
        }
      }
    } catch (e, s) {
      logger.e('Error initializing logger', error: e, stackTrace: s);
    }
  }

  @override
  void append(message) {
    final timestamp = DateTime.now().toIso8601String();
    messages.add('$timestamp: $message');
    _writeToFile('$timestamp: $message');
    _cleanOldLogs();
  }

  Future<void> _writeToFile(String message) async {
    try {
      await _logFile.writeAsString('$message\n', mode: FileMode.append);
    } catch (e, s) {
      logger.e('Error writing to log file', error: e, stackTrace: s);
    }
  }

  void _cleanOldLogs() {
    if (messages.length > 1000) {
      messages = messages.sublist(messages.length - 1000);
    }
  }

  @override
  void closeAppend() {
    info(messages.join('\n'));
    messages = [];
  }

  @override
  void debug(message, [error, StackTrace? stackTrace]) =>
      logger.d(message, error: error, stackTrace: stackTrace);

  @override
  void error(message, [error, StackTrace? stackTrace]) =>
      logger.e(message, error: error, stackTrace: stackTrace);

  @override
  void info(message, [error, StackTrace? stackTrace]) =>
      logger.i(message, error: error, stackTrace: stackTrace);

  @override
  void warning(message, [error, StackTrace? stackTrace]) =>
      logger.w(message, error: error, stackTrace: stackTrace);

  @override
  void fatal(message, [error, StackTrace? stackTrace]) =>
      logger.f(message, error: error, stackTrace: stackTrace);
}
