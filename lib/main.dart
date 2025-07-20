import 'package:flutter/material.dart';

import 'app/app_widget.dart';
import 'app/core/application_config.dart';
import 'app/core/di/dependency_injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApplicationConfig().configureApp();

  // Initialize dependency injection
  di.initialize();

  runApp(const AppWidget());
}
