import 'dart:io';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'helpers/environments.dart';
import 'services/update_service.dart';

class ApplicationConfig {
  Future<void> consfigureApp() async {
    WidgetsFlutterBinding.ensureInitialized();

    await _loadEnvs();

    if (Platform.isWindows) {
      await _configureWindowManager();
      await _initializeUpdateService();
    }
  }

  Future<void> _loadEnvs() => Environments.loadEnvs();

  Future<void> _configureWindowManager() async {
    try {
      await windowManager.ensureInitialized();

      windowManager.setSize(
        const Size(1014, 624),
      );

      windowManager.setResizable(false);
    } catch (e, s) {
      log('Error configuring window manager: $e');
      log('StackTrace: $s');
    }
  }

  Future<void> _initializeUpdateService() async {
    await UpdateService.instance.initialize();
  }
}
