import 'package:flutter/material.dart';

import 'core/application_config.dart';
import 'core/di/injector.dart';
import 'core/routes/router_config.dart' as app_router;
import 'core/services/update_service.dart';
import 'core/ui/widgets/messages.dart';
import 'core/ui/ui_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApplicationConfig().consfigureApp();
  await UpdateService.instance.initialize();

  // Configurar injeção de dependências
  await Injector.setup();

  runApp(
    MaterialApp.router(
      routerConfig: app_router.RouterConfig.router,
      title: UiConfig.title,
      theme: UiConfig.theme,
      builder: (context, child) {
        // Configurar o contexto global para o Messages
        Messages.setGlobalContext(context);
        return child!;
      },
    ),
  );
}
