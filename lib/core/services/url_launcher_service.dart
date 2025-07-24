import 'dart:io';
import 'package:process_run/process_run.dart';
import '../logger/app_logger.dart';
import '../ui/widgets/messages.dart';
import '../utils/url_validator.dart';

class UrlLauncherService {
  UrlLauncherService({
    required AppLogger logger,
    Shell? shell, // ✅ CORREÇÃO: Permitir injeção de Shell
  })  : _logger = logger,
        _shell = shell ?? Shell(); // ✅ CORREÇÃO: Usar Shell injetado ou criar um novo

  final AppLogger _logger;
  final Shell _shell;

  Future<void> launchURL(String url) async {
    try {
      final validatedUrl = UrlValidator.validateAndSanitizeUrl(url);
      if (validatedUrl == null) {
        _logger.error('URL inválida ou maliciosa detectada: $url');
        Messages.alert('URL inválida ou não permitida');
        return;
      }
      if (Platform.isWindows) {
        await _shell.run('start $validatedUrl');
      } else if (Platform.isMacOS) {
        await _shell.run('open $validatedUrl');
      } else if (Platform.isLinux) {
        await _shell.run('xdg-open $validatedUrl');
      } else {
        throw 'Platform not supported';
      }
    } catch (e) {
      _logger.error('Error launching URL: $e');
      Messages.alert('Erro ao abrir URL');
    }
  }
}