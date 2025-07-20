import 'package:flutter/material.dart';

import 'app/core/application_config.dart';
import 'app/core/di/injector.dart';
import 'app/core/routes/router_config.dart' as app_router;
import 'app/core/services/update_service.dart';
import 'app/core/ui/widgets/messages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApplicationConfig().consfigureApp();
  await UpdateService.instance.initialize();

  // Configurar injeção de dependências
  await Injector.setup();

  runApp(
    MaterialApp.router(
      routerConfig: app_router.RouterConfig.router,
      title: 'Boost System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      builder: (context, child) {
        // Configurar o contexto global para o Messages
        Messages.setGlobalContext(context);
        return child!;
      },
    ),
  );
}
