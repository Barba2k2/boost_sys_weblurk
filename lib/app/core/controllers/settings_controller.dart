import 'dart:io';
import 'package:flutter/foundation.dart';
import '../logger/app_logger.dart';
import '../ui/widgets/messages/messages.dart';

class SettingsController extends ChangeNotifier {
  SettingsController({
    required AppLogger logger,
  }) : _logger = logger;

  final AppLogger _logger;

  // Método para encerrar o aplicativo
  Future<void> terminateApp() async {
    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        exit(0);
      } else {
        throw 'Plataforma não suportada para encerramento do app';
      }
    } catch (e) {
      _logger.error('Erro ao encerrar o aplicativo: $e');
      Messages.alert('Erro ao encerrar o aplicativo');
    }
  }
}
