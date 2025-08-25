import 'dart:io';
import '../logger/app_logger.dart';
import '../ui/widgets/messages.dart';
import 'volume_service.dart';

class SettingsService {
  SettingsService({
    required AppLogger logger,
    required VolumeService volumeService,
  })  : _logger = logger,
        _volumeService = volumeService;

  final AppLogger _logger;
  final VolumeService _volumeService;

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

  Future<void> muteAppAudio() async {
    try {
      await _volumeService.toggleMute();
      final status = _volumeService.isMuted ? 'mutado' : 'desmutado';
      Messages.info('Áudio $status');
    } catch (e) {
      _logger.error('Erro ao alternar o áudio do aplicativo: $e');
      Messages.alert('Erro ao alternar o áudio do aplicativo');
    }
  }

  bool get isAudioCurrentlyMuted => _volumeService.isMuted;
}
