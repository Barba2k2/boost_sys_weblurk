import '../../features/home/data/services/webview_service.dart';
import '../helpers/audio_helper.dart';
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
      await AudioHelper.initialize();

      _currentVolume = 1.0;
      _originalVolume = 1.0;
      _isInitialized = true;
    } catch (e, s) {
      _logger.error('Erro ao inicializar controle de volume do app', e, s);
      _isVolumeControlAvailable = false;
    }
  }

  Future<void> mute() async {
    if (!_isVolumeControlAvailable || !_isInitialized) {
      return;
    }
    try {
      _originalVolume = await AudioHelper.getCurrentVolume();

      await AudioHelper.setApplicationMute(true);

      _currentVolume = 0.0;
      _isMuted = true;

      await _webViewService.muteWebView();
    } catch (e, s) {
      _logger.error('Erro ao mutar áudio do app', e, s);
    }
  }

  Future<void> unmute() async {
    if (!_isVolumeControlAvailable || !_isInitialized) {
      return;
    }
    try {
      await AudioHelper.setApplicationMute(false);

      _currentVolume = _originalVolume;
      _isMuted = false;

      await _webViewService.unmuteWebView();
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
      return;
    }
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);

      await AudioHelper.setCurrentVolume(clampedVolume);

      if (clampedVolume > 0.0) {
        _isMuted = false;
        _originalVolume = clampedVolume;
      } else {
        _isMuted = true;
      }
      _currentVolume = clampedVolume;

      await _webViewService.setWebViewVolume(clampedVolume);
    } catch (e, s) {
      _logger.error('Erro ao definir volume do app', e, s);
    }
  }

  Future<double> getVolume() async {
    if (!_isVolumeControlAvailable || !_isInitialized) {
      return 0.0;
    }

    try {
      final systemVolume = await AudioHelper.getCurrentVolume();
      _currentVolume = systemVolume;
      return systemVolume;
    } catch (e, s) {
      _logger.error('Erro ao obter volume do sistema', e, s);
      return _currentVolume;
    }
  }

  Future<bool> isSystemMuted() async {
    try {
      return await AudioHelper.isApplicationMuted();
    } catch (e, s) {
      _logger.error('Erro ao verificar mute do sistema', e, s);
      return _isMuted;
    }
  }

  // ✅ NOVO: Método para sincronizar estado de mute com WebView
  Future<void> syncMuteState() async {
    if (!_isVolumeControlAvailable || !_isInitialized) {
      return;
    }

    try {
      if (_isMuted) {
        await _webViewService.muteWebView();
      } else {
        await _webViewService.unmuteWebView();
      }
    } catch (e, s) {
      _logger.error('Erro ao sincronizar estado de mute com WebView', e, s);
    }
  }

  // ✅ NOVO: Método para verificar e corrigir estado de mute
  Future<void> verifyAndFixMuteState() async {
    if (!_isVolumeControlAvailable || !_isInitialized) {
      return;
    }

    try {
      final systemMuted = await AudioHelper.isApplicationMuted();
      final currentVolume = await AudioHelper.getCurrentVolume();

      // Verifica se há inconsistência entre o estado interno e o sistema
      if (_isMuted != systemMuted || (_isMuted && currentVolume > 0.0)) {
        if (_isMuted) {
          // Força o mute se deveria estar mutado
          await AudioHelper.setApplicationMute(true);
          await _webViewService.muteWebView();
        } else {
          // Força o unmute se deveria estar desmutado
          await AudioHelper.setApplicationMute(false);
          await _webViewService.unmuteWebView();
        }
      }
    } catch (e, s) {
      _logger.error('Erro ao verificar e corrigir estado de mute', e, s);
    }
  }

  // ✅ NOVO: Método para verificar e corrigir estado de mute periodicamente
  Future<void> periodicMuteStateCheck() async {
    if (!_isVolumeControlAvailable || !_isInitialized) {
      return;
    }

    try {
      await verifyAndFixMuteState();

      // Verifica também se o WebView está no estado correto
      await _webViewService.verifyAndFixMuteState(_isMuted);
    } catch (e, s) {
      _logger.error('Erro na verificação periódica do estado de mute', e, s);
    }
  }

  bool get isAppMuted => _isMuted;
  double get originalVolume => _originalVolume;
  double get appVolume => _currentVolume;
  bool get isAudioCurrentlyMuted => _isMuted;
}
