import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'sentry_config.dart';

class ErrorHandler {
  static void setupErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      SentryConfig.captureException(
        details.exception,
        details.stack,
      );
    };

    // Captura erros não tratados
    PlatformDispatcher.instance.onError = (error, stack) {
      SentryConfig.captureException(error, stack);
      return true;
    };
  }

  static Future<void> captureError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
  }) async {
    await SentryConfig.addBreadcrumb(
      'Error captured',
      data: {'context': context ?? 'Unknown'},
      category: 'error',
      level: SentryLevel.error,
    );

    await SentryConfig.captureException(error, stackTrace);
  }

  static Future<void> captureInfo(
    String message, {
    Map<String, dynamic>? data,
  }) async {
    await SentryConfig.addBreadcrumb(
      message,
      data: data,
      category: 'info',
    );

    await SentryConfig.captureMessage(message);
  }

  static Future<void> captureWarning(
    String message, {
    Map<String, dynamic>? data,
  }) async {
    await SentryConfig.addBreadcrumb(
      message,
      data: data,
      category: 'warning',
      level: SentryLevel.warning,
    );

    await SentryConfig.captureMessage(
      message,
      level: SentryLevel.warning,
    );
  }
}
