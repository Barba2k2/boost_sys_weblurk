import '../../features/home/data/services/webview_service.dart';
import '../logger/app_logger.dart';

class VolumeService {
  VolumeService({
    required AppLogger logger,
    required WebViewService webViewService,
  })  : _logger = logger,
        _webViewService = webViewService {
    _initializeVolumeControl();
  }

  final AppLogger _logger;
  final WebViewService _webViewService;

  double _originalVolume = 1.0;
  bool _isInitialized = false;
  bool _isMuted = false;
  double _currentVolume = 1.0;
  bool _isVolumeControlAvailable = true;

  bool get isMuted => _isMuted;
  double get currentVolume => _currentVolume;
  bool get isVolumeControlAvailable => _isVolumeControlAvailable;

  Future<void> _initializeVolumeControl() async {
    try {
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

  Future<void> mute() async {
    if (!_isVolumeControlAvailable || !_isInitialized) {
      _logger.warning('Controle de volume do app não disponível para mutar');
      return;
    }
    try {
      _logger.info('Iniciando processo de mute...');
      _originalVolume = _currentVolume;
      _logger.info('Volume original salvo: $_originalVolume');
      _currentVolume = 0.0;
      _isMuted = true;
      _logger.info(
          'Estado interno atualizado - Volume: $_currentVolume, Muted: $_isMuted');
      await _webViewService.muteWebView();
      _logger.info('muteWebView() concluído');
      _logger.info(
          'Áudio do app mutado com sucesso. Volume anterior: $_originalVolume');
    } catch (e, s) {
      _logger.error('Erro ao mutar áudio do app', e, s);
    }
  }

  Future<void> unmute() async {
    if (!_isVolumeControlAvailable || !_isInitialized) {
      _logger.warning('Controle de volume do app não disponível para desmutar');
      return;
    }
    try {
      _logger.info('Iniciando processo de unmute...');
      _currentVolume = _originalVolume;
      _isMuted = false;
      _logger.info(
          'Estado interno atualizado - Volume: $_currentVolume, Muted: $_isMuted');
      await _webViewService.unmuteWebView();
      _logger.info('unmuteWebView() concluído');
      _logger.info(
          'Áudio do app desmutado com sucesso. Volume restaurado para: $_originalVolume');
    } catch (e, s) {
      _logger.error('Erro ao desmutar áudio do app', e, s);
    }
  }

  Future<void> toggleMute() async {
    if (_isMuted) {
      await unmute();
    } else {
      await mute();
    }
  }

  Future<void> setVolume(double volume) async {
    if (!_isVolumeControlAvailable || !_isInitialized) {
      _logger.warning(
          'Controle de volume do app não disponível para definir volume');
      return;
    }
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      if (clampedVolume > 0.0) {
        _isMuted = false;
        _originalVolume = clampedVolume;
      } else {
        _isMuted = true;
      }
      _currentVolume = clampedVolume;
      await _webViewService.setWebViewVolume(clampedVolume);
      _logger.info('Volume do app definido para: $clampedVolume');
    } catch (e, s) {
      _logger.error('Erro ao definir volume do app', e, s);
    }
  }

  Future<double> getVolume() async {
    if (!_isVolumeControlAvailable || !_isInitialized) {
      return 0.0;
    }
    return _currentVolume;
  }

  bool get isAppMuted => _isMuted;
  double get originalVolume => _originalVolume;
  double get appVolume => _currentVolume;
  bool get isAudioCurrentlyMuted => _isMuted;
}
