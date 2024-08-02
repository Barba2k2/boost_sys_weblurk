import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'app/app_module.dart';
import 'app/app_widget.dart';
import 'app/core/application_config.dart';

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  await ApplicationConfig().consfigureApp();

  runApp(
    ModularApp(
      module: AppModule(),
      child: const AppWidget(),
    ),
  );
}
