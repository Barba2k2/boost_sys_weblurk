import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:process_run/process_run.dart';

import '../logger/app_logger.dart';
import '../ui/widgets/messages/messages.dart';

class UrlLaunchController extends ChangeNotifier {
  UrlLaunchController({
    required AppLogger logger,
  }) : _logger = logger;

  final AppLogger _logger;

  Future<void> launchURL(String url) async {
    try {
      final Shell shell = Shell();
      if (Platform.isWindows) {
        await shell.run('start $url');
      } else if (Platform.isMacOS) {
        await shell.run('open $url');
      } else if (Platform.isLinux) {
        await shell.run('xdg-open $url');
      } else {
        throw 'Platform not supported';
      }
    } catch (e) {
      _logger.error('Error launching URL: $e');
      Messages.alert('Erro ao abrir URL');
    }
  }
}
