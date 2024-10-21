import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'helpers/environments.dart';

class ApplicationConfig {
  Future<void> consfigureApp() async {
    await _loadEnvs();

    Platform.isWindows
        ? await _configureWindowManager()
        : WidgetsFlutterBinding.ensureInitialized();

    // await _configureWindowManager();
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
}
