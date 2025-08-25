import 'package:sentry_flutter/sentry_flutter.dart';

import 'sentry_config.dart';

mixin SentryMixin {
  Future<void> captureError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? extras,
  }) async {
    await SentryConfig.addBreadcrumb(
      'Error in ${runtimeType.toString()}',
      data: {
        'context': context ?? 'Unknown',
        'extras': extras,
      },
      category: 'viewmodel_error',
      level: SentryLevel.error,
    );

    await SentryConfig.captureException(error, stackTrace);
  }

  Future<void> captureInfo(
    String message, {
    Map<String, dynamic>? data,
  }) async {
    await SentryConfig.addBreadcrumb(
      message,
      data: data,
      category: 'viewmodel_info',
    );

    await SentryConfig.captureMessage(message);
  }

  Future<void> captureWarning(
    String message, {
    Map<String, dynamic>? data,
  }) async {
    await SentryConfig.addBreadcrumb(
      message,
      data: data,
      category: 'viewmodel_warning',
      level: SentryLevel.warning,
    );

    await SentryConfig.captureMessage(
      message,
      level: SentryLevel.warning,
    );
  }

  Future<void> setUserContext({
    String? id,
    String? email,
    String? username,
    Map<String, dynamic>? extras,
  }) async {
    await Sentry.configureScope(
      (scope) {
        scope.setUser(
          SentryUser(
            id: id,
            email: email,
            username: username,
          ),
        );
      },
    );
  }

  Future<void> setTag(String key, String value) async {
    await Sentry.configureScope(
      (scope) {
        scope.setTag(key, value);
      },
    );
  }
}
