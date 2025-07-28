import 'package:sentry_flutter/sentry_flutter.dart';

class SentryConfig {
  static const String _dsn = 'https://580a020e1bae72626f33e68ae69ea9be@o4509748376371200.ingest.us.sentry.io/4509748377747456';

  static Future<void> init() async {
    await SentryFlutter.init(
      (options) {
        options.dsn = _dsn;
        options.tracesSampleRate = 1.0;
        options.enableAutoSessionTracking = true;
        options.attachStacktrace = true;
        options.debug = false;
        options.environment = _getEnvironment();
        options.release = _getRelease();
      },
    );
  }

  static String _getEnvironment() {
    // Você pode configurar isso baseado em variáveis de ambiente
    return const String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'development',
    );
  }

  static String _getRelease() {
    // Você pode configurar isso baseado na versão do app
    return const String.fromEnvironment('VERSION', defaultValue: '1.0.0');
  }

  static Future<void> captureException(
    dynamic exception,
    dynamic stackTrace,
  ) async {
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
    );
  }

  static Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
  }) async {
    await Sentry.captureMessage(
      message,
      level: level,
    );
  }

  static Future<void> addBreadcrumb(
    String message, {
    Map<String, dynamic>? data,
    String? category,
    SentryLevel level = SentryLevel.info,
  }) async {
    await Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        data: data,
        category: category,
        level: level,
      ),
    );
  }
}
