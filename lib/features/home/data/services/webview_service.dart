import 'dart:async';
import 'package:webview_windows/webview_windows.dart';
import '../../../../core/logger/app_logger.dart';

abstract class WebViewService {
  bool get isVolumeControlAvailable;
  Future<void> muteWebView();
  Future<void> unmuteWebView();
  Future<void> setWebViewVolume(double volume);
  Future<void> verifyAndFixMuteState(bool shouldBeMuted);
  void setWebViewControllers(
    dynamic controllerA,
    dynamic controllerB,
  );
  void dispose();
}

class WebViewServiceImpl implements WebViewService {
  WebViewServiceImpl({
    required AppLogger logger,
  }) : _logger = logger;

  final AppLogger _logger;
  dynamic _controllerA;
  dynamic _controllerB;
  bool _isMuted = false;
  double _currentVolume = 1.0;

  @override
  bool get isVolumeControlAvailable => true;

  @override
  void setWebViewControllers(
    dynamic controllerA,
    dynamic controllerB,
  ) {
    _controllerA = controllerA;
    _controllerB = controllerB;
  }

  Future<void> _executeScript(dynamic controller, String script) async {
    try {
      if (controller == null) {
        return;
      }

      if (controller is WebviewController) {
        await controller.executeScript(script);
      } else {
        // Para InAppWebViewController (macOS)
        await controller.evaluateJavascript(source: script);
      }
    } catch (e) {
      _logger.error('Erro ao executar script no WebView', e);
    }
  }

  @override
  Future<void> muteWebView() async {
    try {
      const muteScript = '''
        try {
          // Mutar todos os elementos de áudio
          const audioElements = document.querySelectorAll('audio');
          audioElements.forEach(audio => {
            audio.muted = true;
            audio.volume = 0;
            audio.pause();
          });
          
          // Mutar todos os elementos de vídeo
          const videoElements = document.querySelectorAll('video');
          videoElements.forEach(video => {
            video.muted = true;
            video.volume = 0;
          });
          
          // Suspender AudioContext se existir
          if (window.AudioContext || window.webkitAudioContext) {
            const AudioContextClass = window.AudioContext || window.webkitAudioContext;
            if (window.currentAudioContext) {
              window.currentAudioContext.suspend();
            }
          }
          
          // Mutar player específico do Twitch
          const twitchPlayer = document.querySelector('[data-a-target="twitch-player"]');
          if (twitchPlayer) {
            const video = twitchPlayer.querySelector('video');
            if (video) {
              video.muted = true;
              video.volume = 0;
            }
          }
          
          // Mutar vídeos em iframes
          const iframes = document.querySelectorAll('iframe');
          iframes.forEach(iframe => {
            try {
              const iframeDoc = iframe.contentDocument || iframe.contentWindow.document;
              const iframeVideos = iframeDoc.querySelectorAll('video');
              iframeVideos.forEach(video => {
                video.muted = true;
                video.volume = 0;
              });
            } catch (e) {
              // Ignorar erros de CORS
            }
          });
          
          // Mutar elementos com data-a-target específicos do Twitch
          const twitchElements = document.querySelectorAll('[data-a-target]');
          twitchElements.forEach(element => {
            const videos = element.querySelectorAll('video');
            videos.forEach(video => {
              video.muted = true;
              video.volume = 0;
            });
          });
          
          // Definir estado global de mute
          window.isWebViewMuted = true;
          
        } catch (e) {
          console.error('Erro ao mutar WebView:', e);
        }
      ''';

      if (_controllerA != null) {
        await _executeScript(_controllerA, muteScript);
      }

      if (_controllerB != null) {
        await _executeScript(_controllerB, muteScript);
      }

      _isMuted = true;
    } catch (e, s) {
      _logger.error('Error muting WebView', e, s);
    }
  }

  @override
  Future<void> unmuteWebView() async {
    try {
      const unmuteScript = '''
        try {
          // Desmutar todos os elementos de áudio
          const audioElements = document.querySelectorAll('audio');
          audioElements.forEach(audio => {
            audio.muted = false;
            audio.volume = 1;
          });
          
          // Desmutar todos os elementos de vídeo
          const videoElements = document.querySelectorAll('video');
          videoElements.forEach(video => {
            video.muted = false;
            video.volume = 1;
          });
          
          // Resumir AudioContext se existir
          if (window.AudioContext || window.webkitAudioContext) {
            const AudioContextClass = window.AudioContext || window.webkitAudioContext;
            if (window.currentAudioContext) {
              window.currentAudioContext.resume();
            }
          }
          
          // Desmutar player específico do Twitch
          const twitchPlayer = document.querySelector('[data-a-target="twitch-player"]');
          if (twitchPlayer) {
            const video = twitchPlayer.querySelector('video');
            if (video) {
              video.muted = false;
              video.volume = 1;
            }
          }
          
          // Desmutar vídeos em iframes
          const iframes = document.querySelectorAll('iframe');
          iframes.forEach(iframe => {
            try {
              const iframeDoc = iframe.contentDocument || iframe.contentWindow.document;
              const iframeVideos = iframeDoc.querySelectorAll('video');
              iframeVideos.forEach(video => {
                video.muted = false;
                video.volume = 1;
              });
            } catch (e) {
              // Ignorar erros de CORS
            }
          });
          
          // Desmutar elementos com data-a-target específicos do Twitch
          const twitchElements = document.querySelectorAll('[data-a-target]');
          twitchElements.forEach(element => {
            const videos = element.querySelectorAll('video');
            videos.forEach(video => {
              video.muted = false;
              video.volume = 1;
            });
          });
          
          // Definir estado global de mute
          window.isWebViewMuted = false;
          
        } catch (e) {
          console.error('Erro ao desmutar WebView:', e);
        }
      ''';

      if (_controllerA != null) {
        await _executeScript(_controllerA, unmuteScript);
      }

      if (_controllerB != null) {
        await _executeScript(_controllerB, unmuteScript);
      }

      _isMuted = false;
    } catch (e, s) {
      _logger.error('Error unmuting WebView', e, s);
    }
  }

  @override
  Future<void> setWebViewVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      _currentVolume = clampedVolume;
      _isMuted = clampedVolume == 0.0;

      final volumeScript = '''
        try {
          const targetVolume = $clampedVolume;
          
          // Definir volume para todos os elementos de áudio
          const audioElements = document.querySelectorAll('audio');
          audioElements.forEach(audio => {
            audio.volume = targetVolume;
            audio.muted = targetVolume === 0;
          });
          
          // Definir volume para todos os elementos de vídeo
          const videoElements = document.querySelectorAll('video');
          videoElements.forEach(video => {
            video.volume = targetVolume;
            video.muted = targetVolume === 0;
          });
          
          // Definir volume para player específico do Twitch
          const twitchPlayer = document.querySelector('[data-a-target="twitch-player"]');
          if (twitchPlayer) {
            const video = twitchPlayer.querySelector('video');
            if (video) {
              video.volume = targetVolume;
              video.muted = targetVolume === 0;
            }
          }
          
          // Definir volume para vídeos em iframes
          const iframes = document.querySelectorAll('iframe');
          iframes.forEach(iframe => {
            try {
              const iframeDoc = iframe.contentDocument || iframe.contentWindow.document;
              const iframeVideos = iframeDoc.querySelectorAll('video');
              iframeVideos.forEach(video => {
                video.volume = targetVolume;
                video.muted = targetVolume === 0;
              });
            } catch (e) {
              // Ignorar erros de CORS
            }
          });
          
          // Definir volume para elementos com data-a-target específicos do Twitch
          const twitchElements = document.querySelectorAll('[data-a-target]');
          twitchElements.forEach(element => {
            const videos = element.querySelectorAll('video');
            videos.forEach(video => {
              video.volume = targetVolume;
              video.muted = targetVolume === 0;
            });
          });
          
          // Atualizar estado global
          window.isWebViewMuted = targetVolume === 0;
          window.currentWebViewVolume = targetVolume;
          
        } catch (e) {
          console.error('Erro ao definir volume do WebView:', e);
        }
      ''';

      if (_controllerA != null) {
        await _executeScript(_controllerA, volumeScript);
      }

      if (_controllerB != null) {
        await _executeScript(_controllerB, volumeScript);
      }
    } catch (e, s) {
      _logger.error('Error setting WebView volume', e, s);
    }
  }

  @override
  void dispose() {
    _controllerA = null;
    _controllerB = null;
  }

  @override
  Future<void> verifyAndFixMuteState(bool shouldBeMuted) async {
    try {
      if (shouldBeMuted && !_isMuted) {
        await muteWebView();
      } else if (!shouldBeMuted && _isMuted) {
        await unmuteWebView();
      }
    } catch (e, s) {
      _logger.error('Erro ao verificar e corrigir estado de mute', e, s);
    }
  }
}
