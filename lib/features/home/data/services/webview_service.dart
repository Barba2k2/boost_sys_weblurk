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

  @override
  bool get isVolumeControlAvailable => true;

  @override
  void setWebViewControllers(
    WebviewController? controllerA,
    WebviewController? controllerB,
  ) {
    _controllerA = controllerA;
    _controllerB = controllerB;
    _logger.info('WebView controllers configurados');
  }

  @override
  Future<void> muteWebView() async {
    try {
      _logger.info('Mutando WebView...');

      // JavaScript para mutar todos os elementos de áudio e vídeo
      const muteScript = '''
        try {
          // Muta todos os elementos de áudio
          const audioElements = document.querySelectorAll('audio');
          audioElements.forEach(audio => {
            audio.muted = true;
            audio.volume = 0;
          });
          
          // Muta todos os elementos de vídeo
          const videoElements = document.querySelectorAll('video');
          videoElements.forEach(video => {
            video.muted = true;
            video.volume = 0;
          });
          
          // Muta o contexto de áudio se disponível
          if (window.AudioContext || window.webkitAudioContext) {
            const AudioContextClass = window.AudioContext || window.webkitAudioContext;
            if (window.currentAudioContext) {
              window.currentAudioContext.suspend();
            }
          }
          
          // Muta o player do Twitch especificamente
          const twitchPlayer = document.querySelector('[data-a-target="twitch-player"]');
          if (twitchPlayer) {
            const video = twitchPlayer.querySelector('video');
            if (video) {
              video.muted = true;
              video.volume = 0;
            }
          }
          
          // Muta qualquer iframe de vídeo
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
              // Ignora erros de cross-origin
            }
          });
          
          console.log('WebView mutado com sucesso');
        } catch (e) {
          console.error('Erro ao mutar WebView:', e);
        }
      ''';

      // Executa o script em ambos os controllers se disponíveis
      if (_controllerA != null) {
        await _controllerA!.executeScript(muteScript);
      }

      if (_controllerB != null) {
        await _controllerB!.executeScript(muteScript);
      }

      _logger.info('WebView muted com sucesso');
    } catch (e, s) {
      _logger.error('Error muting WebView', e, s);
    }
  }

  @override
  Future<void> unmuteWebView() async {
    try {
      _logger.info('Desmutando WebView...');

      // JavaScript para desmutar todos os elementos de áudio e vídeo
      const unmuteScript = '''
        try {
          // Desmuta todos os elementos de áudio
          const audioElements = document.querySelectorAll('audio');
          audioElements.forEach(audio => {
            audio.muted = false;
            audio.volume = 1;
          });
          
          // Desmuta todos os elementos de vídeo
          const videoElements = document.querySelectorAll('video');
          videoElements.forEach(video => {
            video.muted = false;
            video.volume = 1;
          });
          
          // Resuma o contexto de áudio se disponível
          if (window.AudioContext || window.webkitAudioContext) {
            const AudioContextClass = window.AudioContext || window.webkitAudioContext;
            if (window.currentAudioContext) {
              window.currentAudioContext.resume();
            }
          }
          
          // Desmuta o player do Twitch especificamente
          const twitchPlayer = document.querySelector('[data-a-target="twitch-player"]');
          if (twitchPlayer) {
            const video = twitchPlayer.querySelector('video');
            if (video) {
              video.muted = false;
              video.volume = 1;
            }
          }
          
          // Desmuta qualquer iframe de vídeo
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
              // Ignora erros de cross-origin
            }
          });
          
          console.log('WebView desmutado com sucesso');
        } catch (e) {
          console.error('Erro ao desmutar WebView:', e);
        }
      ''';

      // Executa o script em ambos os controllers se disponíveis
      if (_controllerA != null) {
        await _controllerA!.executeScript(unmuteScript);
      }

      if (_controllerB != null) {
        await _controllerB!.executeScript(unmuteScript);
      }

      _logger.info('WebView unmuted com sucesso');
    } catch (e, s) {
      _logger.error('Error unmuting WebView', e, s);
    }
  }

  @override
  Future<void> setWebViewVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);

      _logger.info('Definindo volume do WebView para: $clampedVolume');

      // JavaScript para definir o volume de todos os elementos de áudio e vídeo
      final volumeScript = '''
        try {
          const targetVolume = $clampedVolume;
          
          // Define volume de todos os elementos de áudio
          const audioElements = document.querySelectorAll('audio');
          audioElements.forEach(audio => {
            audio.volume = targetVolume;
            audio.muted = targetVolume === 0;
          });
          
          // Define volume de todos os elementos de vídeo
          const videoElements = document.querySelectorAll('video');
          videoElements.forEach(video => {
            video.volume = targetVolume;
            video.muted = targetVolume === 0;
          });
          
          // Define volume do player do Twitch especificamente
          const twitchPlayer = document.querySelector('[data-a-target="twitch-player"]');
          if (twitchPlayer) {
            const video = twitchPlayer.querySelector('video');
            if (video) {
              video.volume = targetVolume;
              video.muted = targetVolume === 0;
            }
          }
          
          // Define volume de qualquer iframe de vídeo
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
              // Ignora erros de cross-origin
            }
          });
          
          console.log('Volume do WebView definido para:', targetVolume);
        } catch (e) {
          console.error('Erro ao definir volume do WebView:', e);
        }
      ''';

      // Executa o script em ambos os controllers se disponíveis
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
    _logger.info('WebView service disposed');
  }
}
