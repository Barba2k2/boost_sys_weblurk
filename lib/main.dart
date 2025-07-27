import 'package:flutter/material.dart';

import 'core/application_config.dart';
import 'core/di/injector.dart';
import 'core/routes/router_config.dart';
import 'core/ui/ui_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApplicationConfig().consfigureApp();

  await Injector.setup();

  runApp(
    MaterialApp.router(
      routerConfig: AppRouter.router,
      title: UiConfig.title,
      theme: UiConfig.theme,
    ),
  );
}
