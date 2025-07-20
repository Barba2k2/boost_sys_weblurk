import 'dart:io';
import 'package:flutter/foundation.dart';
import '../logger/app_logger.dart';
import '../ui/widgets/messages.dart';
import 'volume_controller.dart';

class SettingsController extends ChangeNotifier {
  SettingsController({
    required AppLogger logger,
    required VolumeController volumeController,
  })  : _logger = logger,
        _volumeController = volumeController {
    // Escutar mudanças no VolumeController
    _volumeController.addListener(() => notifyListeners());
  }

  final AppLogger _logger;
  final VolumeController _volumeController;

  bool get isAudioMuted => _volumeController.isMuted;

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

  // Método para alternar o áudio (mutar/desmutar)
  Future<void> muteAppAudio() async {
    try {
      if (!_volumeController.isVolumeControlAvailable) {
        Messages.info('Controle de volume não disponível nesta plataforma');
        return;
      }

      await _volumeController.toggleMute();

      final status = _volumeController.isMuted ? 'mutado' : 'desmutado';
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
