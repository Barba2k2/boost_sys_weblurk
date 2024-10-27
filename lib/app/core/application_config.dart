import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'helpers/environments.dart';
import 'services/update_service.dart';

class ApplicationConfig {
  Future<void> consfigureApp() async {
    await _loadEnvs();

    WidgetsFlutterBinding.ensureInitialized();

    if (Platform.isWindows) {
      await _configureWindowManager();
    }

    if (Platform.isAndroid) {
      await _initializeUpdateService();
    }
  }

  Future<void> _loadEnvs() => Environments.loadEnvs();

  Future<void> _configureWindowManager() async {
    WidgetsFlutterBinding.ensureInitialized();

    await windowManager.ensureInitialized();

    windowManager.setSize(
      const Size(1024, 768),
    );

    windowManager.setResizable(false);
  }

  Future<void> _initializeUpdateService() async {
    await UpdateService.instance.initialize();
  }
}
