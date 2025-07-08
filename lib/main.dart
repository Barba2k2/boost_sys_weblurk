import 'package:flutter/material.dart';

import 'app/app_widget.dart';
import 'app/core/application_config.dart';
import 'app/core/di/di.dart';

Future<void> main() async {
  await ApplicationConfig().consfigureApp();

  // Initialize dependency injection
  di.initialize();

  runApp(const AppWidget());
}
