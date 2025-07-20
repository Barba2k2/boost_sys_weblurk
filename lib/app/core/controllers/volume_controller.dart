import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../features/home/data/services/webview_service.dart';
import '../logger/app_logger.dart';

class VolumeController extends ChangeNotifier {
  VolumeController({
    required AppLogger logger,
    required WebViewService webViewService,
  })  : _logger = logger,
        _webViewService = webViewService {
    _initializeVolumeControl();
  }

  final AppLogger _logger;
  final WebViewService _webViewService;

  double _originalVolume = 1.0; // Volume padrão do app
  bool _isInitialized = false;

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  double _currentVolume = 1.0; // Volume atual do app (0.0 a 1.0)
  double get currentVolume => _currentVolume;

  bool _isVolumeControlAvailable = true; // Sempre disponível para o app
  bool get isVolumeControlAvailable => _isVolumeControlAvailable;

  /// Inicializa o controle de volume do app
  Future<void> _initializeVolumeControl() async {
    try {
      // Inicializa com volume máximo
      _currentVolume = 1.0;
      _originalVolume = 1.0;
      _isInitialized = true;

      _logger.info(
          'Controle de volume do app inicializado. Volume atual: $_currentVolume');
    } catch (e, s) {
      _logger.error('Erro ao inicializar controle de volume do app', e, s);
      _isVolumeControlAvailable = false;
    }
  }

  /// Muta o áudio do app (define volume para 0)
  Future<void> mute() async {
    if (!_isVolumeControlAvailable || !_isInitialized) {
      _logger.warning('Controle de volume do app não disponível para mutar');
      return;
    }

    try {
      _logger.info('Iniciando processo de mute...');

      // Salva o volume atual antes de mutar
      _originalVolume = _currentVolume;
      _logger.info('Volume original salvo: $_originalVolume');

      // Define o volume do app para 0 (mudo)
      _currentVolume = 0.0;
      _isMuted = true;
      notifyListeners();
      _logger.info(
          'Estado interno atualizado - Volume: $_currentVolume, Muted: $_isMuted');

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
  Future<void> unmute() async {
    if (!_isVolumeControlAvailable || !_isInitialized) {
      _logger.warning('Controle de volume do app não disponível para desmutar');
      return;
    }

    try {
      _logger.info('Iniciando processo de unmute...');

      // Restaura o volume anterior
      _currentVolume = _originalVolume;
      _isMuted = false;
      notifyListeners();
      _logger.info(
          'Estado interno atualizado - Volume: $_currentVolume, Muted: $_isMuted');

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
  Future<void> toggleMute() async {
    if (_isMuted) {
      await unmute();
    } else {
      await mute();
    }
  }

  /// Define um volume específico para o app (0.0 a 1.0)
  Future<void> setVolume(double volume) async {
    if (!_isVolumeControlAvailable || !_isInitialized) {
      _logger.warning(
          'Controle de volume do app não disponível para definir volume');
      return;
    }

    try {
      // Garante que o volume está entre 0.0 e 1.0
      final clampedVolume = volume.clamp(0.0, 1.0);

      _currentVolume = clampedVolume;

      // Se o volume for maior que 0, considera como desmutado
      if (clampedVolume > 0.0) {
        _isMuted = false;
        _originalVolume = clampedVolume;
      } else {
        _isMuted = true;
      }

      notifyListeners();

      // Define o volume no WebView também
      await _webViewService.setWebViewVolume(clampedVolume);

      _logger.info('Volume do app definido para: $clampedVolume');
    } catch (e, s) {
      _logger.error('Erro ao definir volume do app', e, s);
    }
  }

  /// Obtém o volume atual do app
  Future<double> getVolume() async {
    if (!_isVolumeControlAvailable || !_isInitialized) {
      return 0.0;
    }

    return _currentVolume;
  }

  /// Verifica se o áudio do app está mutado
  bool get isAppMuted => _isMuted;

  /// Obtém o volume original do app (antes de mutar)
  double get originalVolume => _originalVolume;

  /// Obtém o volume atual do app
  double get appVolume => _currentVolume;

  /// Verifica se o áudio está atualmente mutado (para compatibilidade)
  bool get isAudioCurrentlyMuted => _isMuted;

  @override
  void dispose() {
    _logger.info('VolumeController do app disposto');
    super.dispose();
  }
}
