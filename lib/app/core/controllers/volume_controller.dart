import 'dart:async';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';

import '../../service/webview/windows_web_view_service.dart';
import '../logger/app_logger.dart';

part 'volume_controller.g.dart';

class VolumeController = VolumeControllerBase with _$VolumeController;

abstract class VolumeControllerBase with Store {
  VolumeControllerBase({
    required AppLogger logger,
  }) : _logger = logger {
    _initializeVolumeControl();
  }

  final AppLogger _logger;
  double _originalVolume = 1.0; // Volume padrão do app
  bool _isInitialized = false;

  @observable
  bool isMuted = false;

  @observable
  double currentVolume = 1.0; // Volume atual do app (0.0 a 1.0)

  @observable
  bool isVolumeControlAvailable = true; // Sempre disponível para o app

  // Getter para o serviço do WebView
  WindowsWebViewService get _webViewService =>
      Modular.get<WindowsWebViewService>();

  /// Inicializa o controle de volume do app
  Future<void> _initializeVolumeControl() async {
    try {
      // Inicializa com volume máximo
      currentVolume = 1.0;
      _originalVolume = 1.0;
      _isInitialized = true;

      _logger.info(
          'Controle de volume do app inicializado. Volume atual: $currentVolume');
    } catch (e, s) {
      _logger.error('Erro ao inicializar controle de volume do app', e, s);
      isVolumeControlAvailable = false;
    }
  }

  /// Muta o áudio do app (define volume para 0)
  @action
  Future<void> mute() async {
    if (!isVolumeControlAvailable || !_isInitialized) {
      _logger.warning('Controle de volume do app não disponível para mutar');
      return;
    }

    try {
      _logger.info('Iniciando processo de mute...');

      // Salva o volume atual antes de mutar
      _originalVolume = currentVolume;
      _logger.info('Volume original salvo: $_originalVolume');

      // Define o volume do app para 0 (mudo)
      currentVolume = 0.0;
      isMuted = true;
      _logger.info(
          'Estado interno atualizado - Volume: $currentVolume, Muted: $isMuted');

      // Muta o WebView também
      _logger.info('Chamando muteWebView()...');
      await _webViewService.muteWebView();
      _logger.info('muteWebView() concluído');

      _logger.info(
          'Áudio do app mutado com sucesso. Volume anterior: $_originalVolume');
    } catch (e, s) {
      _logger.error('Erro ao mutar áudio do app', e, s);
    }
  }

  /// Desmuta o áudio do app (restaura o volume anterior)
  @action
  Future<void> unmute() async {
    if (!isVolumeControlAvailable || !_isInitialized) {
      _logger.warning('Controle de volume do app não disponível para desmutar');
      return;
    }

    try {
      _logger.info('Iniciando processo de unmute...');

      // Restaura o volume anterior
      currentVolume = _originalVolume;
      isMuted = false;
      _logger.info(
          'Estado interno atualizado - Volume: $currentVolume, Muted: $isMuted');

      // Desmuta o WebView também
      _logger.info('Chamando unmuteWebView()...');
      await _webViewService.unmuteWebView();
      _logger.info('unmuteWebView() concluído');

      _logger.info(
          'Áudio do app desmutado com sucesso. Volume restaurado para: $_originalVolume');
    } catch (e, s) {
      _logger.error('Erro ao desmutar áudio do app', e, s);
    }
  }

  /// Alterna entre mutado e desmutado
  @action
  Future<void> toggleMute() async {
    if (isMuted) {
      await unmute();
    } else {
      await mute();
    }
  }

  /// Define um volume específico para o app (0.0 a 1.0)
  @action
  Future<void> setVolume(double volume) async {
    if (!isVolumeControlAvailable || !_isInitialized) {
      _logger.warning(
          'Controle de volume do app não disponível para definir volume');
      return;
    }

    try {
      // Garante que o volume está entre 0.0 e 1.0
      final clampedVolume = volume.clamp(0.0, 1.0);

      currentVolume = clampedVolume;

      // Se o volume for maior que 0, considera como desmutado
      if (clampedVolume > 0.0) {
        isMuted = false;
        _originalVolume = clampedVolume;
      } else {
        isMuted = true;
      }

      // Define o volume no WebView também
      await _webViewService.setWebViewVolume(clampedVolume);

      _logger.info('Volume do app definido para: $clampedVolume');
    } catch (e, s) {
      _logger.error('Erro ao definir volume do app', e, s);
    }
  }

  /// Obtém o volume atual do app
  @action
  Future<double> getVolume() async {
    if (!isVolumeControlAvailable || !_isInitialized) {
      return 0.0;
    }

    return currentVolume;
  }

  /// Verifica se o áudio do app está mutado
  bool get isAppMuted => isMuted;

  /// Obtém o volume original do app (antes de mutar)
  double get originalVolume => _originalVolume;

  /// Obtém o volume atual do app
  double get appVolume => currentVolume;

  /// Verifica se o áudio está atualmente mutado (para compatibilidade)
  bool get isAudioCurrentlyMuted => isMuted;

  /// Dispose do controlador
  void dispose() {
    // Não há listeners externos para remover
    _logger.info('VolumeController do app disposto');
  }
}
