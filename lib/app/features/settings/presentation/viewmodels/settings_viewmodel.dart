import 'package:flutter/foundation.dart';

import '../../../../core/utils/command.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/controllers/settings_controller.dart';
import '../../../../core/controllers/volume_controller.dart';
import '../../../../core/controllers/url_launch_controller.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    required SettingsController settingsController,
    required VolumeController volumeController,
    required UrlLaunchController urlLaunchController,
  })  : _settingsController = settingsController,
        _volumeController = volumeController,
        _urlLaunchController = urlLaunchController;

  final SettingsController _settingsController;
  final VolumeController _volumeController;
  final UrlLaunchController _urlLaunchController;

  // Commands para operações
  late final toggleMuteCommand = Command0<void>(_toggleMute);
  late final setVolumeCommand = Command1<void, double>(_setVolume);
  late final launchUrlCommand = Command1<void, String>(_launchUrl);
  late final terminateAppCommand = Command0<void>(_terminateApp);

  // Getters para estado
  double get currentVolume => _volumeController.currentVolume;
  bool get isMuted => _volumeController.isMuted;

  // Método privado para alternar mute
  Future<Result<void>> _toggleMute() async {
    try {
      await _volumeController.toggleMute();
      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao alternar mute: $e'));
    }
  }

  // Método privado para definir volume
  Future<Result<void>> _setVolume(double volume) async {
    try {
      await _volumeController.setVolume(volume);
      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao definir volume: $e'));
    }
  }

  // Método privado para abrir URL
  Future<Result<void>> _launchUrl(String url) async {
    try {
      await _urlLaunchController.launchURL(url);
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao abrir URL: $e'));
    }
  }

  // Método privado para encerrar o app
  Future<Result<void>> _terminateApp() async {
    try {
      await _settingsController.terminateApp();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao encerrar o app: $e'));
    }
  }
}
