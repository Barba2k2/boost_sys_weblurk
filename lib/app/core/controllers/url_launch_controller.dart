import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:process_run/process_run.dart';

import '../logger/app_logger.dart';
import '../ui/widgets/messages.dart';
import '../utils/url_validator.dart';

class UrlLaunchController extends ChangeNotifier {
  UrlLaunchController({
    required AppLogger logger,
  }) : _logger = logger;

  final AppLogger _logger;

  Future<void> launchURL(String url) async {
    try {
      // Valida e sanitiza a URL antes de abrir
      final validatedUrl = UrlValidator.validateAndSanitizeUrl(url);
      if (validatedUrl == null) {
        _logger.error('URL inválida ou maliciosa detectada: $url');
        Messages.alert('URL inválida ou não permitida');
        return;
      }

      final Shell shell = Shell();
      if (Platform.isWindows) {
        await shell.run('start $validatedUrl');
      } else if (Platform.isMacOS) {
        await shell.run('open $validatedUrl');
      } else if (Platform.isLinux) {
        await shell.run('xdg-open $validatedUrl');
      } else {
        throw 'Platform not supported';
      }
    } catch (e) {
      _logger.error('Error launching URL: $e');
      Messages.alert('Erro ao abrir URL');
    }
  }
}
