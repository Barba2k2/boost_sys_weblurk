import 'dart:io';
import 'package:mobx/mobx.dart';
import '../logger/app_logger.dart';
import '../ui/widgets/messages.dart';
import 'volume_controller.dart';

part 'settings_controller.g.dart';

class SettingsController = SettingsControllerBase with _$SettingsController;

abstract class SettingsControllerBase with Store {
  SettingsControllerBase({
    required AppLogger logger,
    required VolumeController volumeController,
  })  : _logger = logger,
        _volumeController = volumeController;

  final AppLogger _logger;
  final VolumeController _volumeController;

  @observable
  bool isAudioMuted = false;

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

  // Método para alternar o áudio (mutar/desmutar)
  @action
  Future<void> muteAppAudio() async {
    try {
      if (!_volumeController.isVolumeControlAvailable) {
        Messages.info('Controle de volume não disponível nesta plataforma');
        return;
      }

      await _volumeController.toggleMute();
      isAudioMuted = _volumeController.isMuted;

      final status = isAudioMuted ? 'mutado' : 'desmutado';
      Messages.info('Áudio $status');

      _logger.info('Áudio alternado para: $status');
    } catch (e) {
      _logger.error('Erro ao alternar o áudio do aplicativo: $e');
      Messages.alert('Erro ao alternar o áudio do aplicativo');
    }
  }

  // Método para obter o status atual do áudio
  bool get isAudioCurrentlyMuted => _volumeController.isMuted;
}
