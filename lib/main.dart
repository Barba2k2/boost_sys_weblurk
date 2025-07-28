import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/material.dart';

import 'core/application_config.dart';
import 'core/di/injector.dart';
import 'core/helpers/error_handler.dart';
import 'core/helpers/sentry_config.dart';
import 'core/routes/router_config.dart';
import 'core/ui/ui_config.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApplicationConfig().consfigureApp();

  await Injector.setup();

  await SentryConfig.init();
  ErrorHandler.setupErrorHandling();
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://580a020e1bae72626f33e68ae69ea9be@o4509748376371200.ingest.us.sentry.io/4509748377747456';
      // Adds request headers and IP for users, for more info visit:
      // https://docs.sentry.io/platforms/dart/guides/flutter/data-management/data-collected/
      options.sendDefaultPii = true;
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // Configure Session Replay
      options.replay.sessionSampleRate = 0.1;
      options.replay.onErrorSampleRate = 1.0;
    },
    appRunner: () => runApp(SentryWidget(child: const MyApp())),
  );
  // TODO: Remove this line after sending the first sample event to sentry.
  await Sentry.captureException(StateError('This is a sample exception.'));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = ClarityConfig(
      projectId: 'sm5um989kp',
      logLevel: LogLevel.None,
    );

    return ClarityWidget(
      app: MaterialApp.router(
        routerConfig: AppRouter.router,
        title: UiConfig.title,
        theme: UiConfig.theme,
      ),
      clarityConfig: config,
    );
  }
}
