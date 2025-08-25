import '../../features/home/data/services/webview_service.dart';
import '../logger/app_logger.dart';

class VolumeService {
  VolumeService({
    required AppLogger logger,
    required WebViewService webViewService,
  })  : _logger = logger,
        _webViewService = webViewService;

  final AppLogger _logger;
  final WebViewService _webViewService;

  bool _isMuted = false;
  double _currentVolume = 1.0;

  bool get isMuted => _isMuted;
  double get currentVolume => _currentVolume;

  Future<void> mute() async {
    try {
      _currentVolume = 0.0;
      _isMuted = true;

      await _webViewService.muteWebView();
    } catch (e, s) {
      _logger.error('Erro ao mutar áudio do WebView', e, s);
    }
  }

  Future<void> unmute() async {
    try {
      _currentVolume = 1.0;
      _isMuted = false;

      await _webViewService.unmuteWebView();
    } catch (e, s) {
      _logger.error('Erro ao desmutar áudio do WebView', e, s);
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
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);

      if (clampedVolume > 0.0) {
        _isMuted = false;
      } else {
        _isMuted = true;
      }
      _currentVolume = clampedVolume;

      await _webViewService.setWebViewVolume(clampedVolume);
    } catch (e, s) {
      _logger.error('Erro ao definir volume do WebView', e, s);
    }
  }

  Future<double> getVolume() async {
    return _currentVolume;
  }

  Future<bool> isSystemMuted() async {
    return _isMuted;
  }

  Future<void> syncMuteState() async {
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

  Future<void> verifyAndFixMuteState() async {
    try {
      await _webViewService.verifyAndFixMuteState(_isMuted);
    } catch (e, s) {
      _logger.error('Erro ao verificar e corrigir estado de mute', e, s);
    }
  }

  Future<void> periodicMuteStateCheck() async {
    try {
      await verifyAndFixMuteState();
    } catch (e, s) {
      _logger.error('Erro na verificação periódica do estado de mute', e, s);
    }
  }

  bool get isAppMuted => _isMuted;
  double get appVolume => _currentVolume;
  bool get isAudioCurrentlyMuted => _isMuted;
}
