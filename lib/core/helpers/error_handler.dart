import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../services/sentry_service.dart';

class ErrorHandler {
  static void setupErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      SentryService.captureException(
        details.exception,
        stackTrace: details.stack,
        hint: 'Flutter Error',
      );
    };

    // Captura erros não tratados
    PlatformDispatcher.instance.onError = (error, stack) {
      SentryService.captureException(
        error, 
        stackTrace: stack,
        hint: 'Platform Error',
      );
      return true;
    };
  }

  static Future<void> captureError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
  }) async {
    SentryService.addBreadcrumb(
      'Error captured',
      data: {'context': context ?? 'Unknown'},
      category: 'error',
      level: SentryLevel.error,
    );

    SentryService.captureException(
      error, 
      stackTrace: stackTrace,
      hint: context,
    );
  }

  static Future<void> captureInfo(
    String message, {
    Map<String, dynamic>? data,
  }) async {
    SentryService.addBreadcrumb(
      message,
      data: data,
      category: 'info',
    );

    SentryService.captureMessage(
      message,
      extra: data,
    );
  }

  static Future<void> captureWarning(
    String message, {
    Map<String, dynamic>? data,
  }) async {
    SentryService.addBreadcrumb(
      message,
      data: data,
      category: 'warning',
      level: SentryLevel.warning,
    );

    SentryService.captureMessage(
      message,
      level: SentryLevel.warning,
      extra: data,
    );
  }
}
