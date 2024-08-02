import 'package:flutter/material.dart';

import 'helpers/environments.dart';

class ApplicationConfig {
  Future<void> consfigureApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    await _loadEnvs();
  }

  Future<void> _loadEnvs() => Environments.loadEnvs();
}
