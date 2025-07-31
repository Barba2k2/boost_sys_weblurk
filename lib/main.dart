import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'core/application_config.dart';
import 'core/di/injector.dart';
import 'core/helpers/error_handler.dart';
import 'core/routes/router_config.dart';
import 'core/ui/ui_config.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://580a020e1bae72626f33e68ae69ea9be@o4509748376371200.ingest.us.sentry.io/4509748377747456';
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
    appRunner: () async {
      await ApplicationConfig().consfigureApp();
      await windowManager.ensureInitialized();
      WindowOptions windowOptions = const WindowOptions(
        size: Size(1014, 624),
        center: true,
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
      await Injector.setup();
      ErrorHandler.setupErrorHandling();
      runApp(const Weblurk());
    },
  );
}

class Weblurk extends StatelessWidget {
  const Weblurk({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      title: UiConfig.title,
      theme: UiConfig.theme,
    );
  }
}
