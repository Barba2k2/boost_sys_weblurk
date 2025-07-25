// lib/features/home/data/services/webview_service.dart
import 'dart:async';
import 'package:webview_windows/webview_windows.dart';
import '../../../../core/logger/app_logger.dart';

abstract class WebViewService {
  bool get isVolumeControlAvailable;
  Future<void> muteWebView();
  Future<void> unmuteWebView();
  Future<void> setWebViewVolume(double volume);
  void setWebViewControllers(
    WebviewController? controllerA,
    WebviewController? controllerB,
  );
  void dispose();
}

class WebViewServiceImpl implements WebViewService {
  WebViewServiceImpl({
    required AppLogger logger,
  }) : _logger = logger;

  final AppLogger _logger;
  WebviewController? _controllerA;
  WebviewController? _controllerB;
  bool _isMuted = false;
  double _currentVolume = 1.0;

  @override
  bool get isVolumeControlAvailable => true;

  @override
  void setWebViewControllers(
    WebviewController? controllerA,
    WebviewController? controllerB,
  ) {
    _controllerA = controllerA;
    _controllerB = controllerB;
  }

  @override
  Future<void> muteWebView() async {
    try {
      const muteScript = '''
        try {
          const audioElements = document.querySelectorAll('audio');
          audioElements.forEach(audio => {
            audio.muted = true;
            audio.volume = 0;
          });
          
          const videoElements = document.querySelectorAll('video');
          videoElements.forEach(video => {
            video.muted = true;
            video.volume = 0;
          });
          
          if (window.AudioContext || window.webkitAudioContext) {
            const AudioContextClass = window.AudioContext || window.webkitAudioContext;
            if (window.currentAudioContext) {
              window.currentAudioContext.suspend();
            }
          }
          
          const twitchPlayer = document.querySelector('[data-a-target="twitch-player"]');
          if (twitchPlayer) {
            const video = twitchPlayer.querySelector('video');
            if (video) {
              video.muted = true;
              video.volume = 0;
            }
          }
          
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
            }
          });
          
        } catch (e) {
          console.error('Erro ao mutar WebView:', e);
        }
      ''';

      if (_controllerA != null) {
        await _controllerA!.executeScript(muteScript);
      }

      if (_controllerB != null) {
        await _controllerB!.executeScript(muteScript);
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
          const audioElements = document.querySelectorAll('audio');
          audioElements.forEach(audio => {
            audio.muted = false;
            audio.volume = 1;
          });
          
          const videoElements = document.querySelectorAll('video');
          videoElements.forEach(video => {
            video.muted = false;
            video.volume = 1;
          });
          
          if (window.AudioContext || window.webkitAudioContext) {
            const AudioContextClass = window.AudioContext || window.webkitAudioContext;
            if (window.currentAudioContext) {
              window.currentAudioContext.resume();
            }
          }
          
          const twitchPlayer = document.querySelector('[data-a-target="twitch-player"]');
          if (twitchPlayer) {
            const video = twitchPlayer.querySelector('video');
            if (video) {
              video.muted = false;
              video.volume = 1;
            }
          }
          
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
            }
          });
          
        } catch (e) {
          console.error('Erro ao desmutar WebView:', e);
        }
      ''';

      if (_controllerA != null) {
        await _controllerA!.executeScript(unmuteScript);
      }

      if (_controllerB != null) {
        await _controllerB!.executeScript(unmuteScript);
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

      final volumeScript = '''
        try {
          const targetVolume = $clampedVolume;
          
          const audioElements = document.querySelectorAll('audio');
          audioElements.forEach(audio => {
            audio.volume = targetVolume;
            audio.muted = targetVolume === 0;
          });
          
          const videoElements = document.querySelectorAll('video');
          videoElements.forEach(video => {
            video.volume = targetVolume;
            video.muted = targetVolume === 0;
          });
          
          const twitchPlayer = document.querySelector('[data-a-target="twitch-player"]');
          if (twitchPlayer) {
            const video = twitchPlayer.querySelector('video');
            if (video) {
              video.volume = targetVolume;
              video.muted = targetVolume === 0;
            }
          }
          
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
            }
          });
          
        } catch (e) {
          console.error('Erro ao definir volume do WebView:', e);
        }
      ''';

      if (_controllerA != null) {
        await _controllerA!.executeScript(volumeScript);
      }

      if (_controllerB != null) {
        await _controllerB!.executeScript(volumeScript);
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
}
