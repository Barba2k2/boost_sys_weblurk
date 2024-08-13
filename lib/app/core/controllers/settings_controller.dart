import 'dart:io';
import 'package:mobx/mobx.dart';
import '../logger/app_logger.dart';
import '../ui/widgets/messages.dart';

part 'settings_controller.g.dart';

class SettingsController = SettingsControllerBase with _$SettingsController;

abstract class SettingsControllerBase with Store {
  final AppLogger _logger;

  SettingsControllerBase({
    required AppLogger logger,
  })  : _logger = logger;

  // Método para encerrar o aplicativo
  @action
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

  // Método para mutar o áudio do WebView
  @action
  Future<void> muteAppAudio() async {
    try {
      if (Platform.isWindows) {
        Messages.info('Funcionalidade ainda não implementada');
      }
      // else if (Platform.isMacOS) {
      //   await shell.run('osascript -e "set volume output muted true"');
      // } else if (Platform.isLinux) {
      //   await shell.run('amixer -q -D pulse sset Master mute');
      // } else {
      //   throw 'Plataforma não suportada para mutar áudio';
      // }
    } catch (e) {
      _logger.error('Erro ao mutar o áudio do aplicativo: $e');
      Messages.alert('Erro ao mutar o áudio do aplicativo');
    }
  }
}
