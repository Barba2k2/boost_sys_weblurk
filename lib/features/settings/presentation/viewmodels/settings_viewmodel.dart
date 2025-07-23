import 'package:flutter/foundation.dart';

import '../../../../core/utils/command.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/services/volume_service.dart';
import '../../../../core/services/url_launcher_service.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    required SettingsService settingsService,
    required VolumeService volumeService,
    required UrlLauncherService urlLauncherService,
  })  : _settingsService = settingsService,
        _volumeService = volumeService,
        _urlLauncherService = urlLauncherService;

  final SettingsService _settingsService;
  final VolumeService _volumeService;
  final UrlLauncherService _urlLauncherService;

  // Commands para operações
  late final toggleMuteCommand = Command0<void>(_toggleMute);
  late final setVolumeCommand = Command1<void, double>(_setVolume);
  late final launchUrlCommand = Command1<void, String>(_launchUrl);
  late final terminateAppCommand = Command0<void>(_terminateApp);

  // Getters para estado
  double get currentVolume => _volumeService.currentVolume;
  bool get isMuted => _volumeService.isMuted;

  // Método privado para alternar mute
  Future<Result<void>> _toggleMute() async {
    try {
      await _volumeService.toggleMute();
      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao alternar mute: $e'));
    }
  }

  // Método privado para definir volume
  Future<Result<void>> _setVolume(double volume) async {
    try {
      await _volumeService.setVolume(volume);
      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao definir volume: $e'));
    }
  }

  // Método privado para abrir URL
  Future<Result<void>> _launchUrl(String url) async {
    try {
      await _urlLauncherService.launchURL(url);
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao abrir URL: $e'));
    }
  }

  // Método privado para encerrar o app
  Future<Result<void>> _terminateApp() async {
    try {
      await _settingsService.terminateApp();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao encerrar o app: $e'));
    }
  }
}
