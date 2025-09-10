import 'dart:async';
import '../../../../core/logger/app_logger.dart';
import '../../../../core/ui/widgets/webview_controller_interface.dart';

abstract class WebViewService {
  bool get isVolumeControlAvailable;
  Future<void> muteWebView();
  Future<void> unmuteWebView();
  Future<void> setWebViewVolume(double volume);
  Future<void> verifyAndFixMuteState(bool shouldBeMuted);
  Future<void> forceAutoplay();
  void setWebViewControllers(
    WebViewControllerInterface? controllerA,
    WebViewControllerInterface? controllerB,
  );
  void dispose();
}

class WebViewServiceImpl implements WebViewService {
  WebViewServiceImpl({
    required AppLogger logger,
  }) : _logger = logger;

  final AppLogger _logger;
  WebViewControllerInterface? _controllerA;
  WebViewControllerInterface? _controllerB;
  bool _isMuted = false;

  @override
  bool get isVolumeControlAvailable => true;

  @override
  void setWebViewControllers(
    WebViewControllerInterface? controllerA,
    WebViewControllerInterface? controllerB,
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

  /// Força o autoplay do player Twitch
  @override
  Future<void> forceAutoplay() async {
    try {
      const autoplayScript = '''
        try {
          // Força autoplay para todos os vídeos
          const videoElements = document.querySelectorAll('video');
          videoElements.forEach(video => {
            if (video.paused) {
              video.autoplay = true;
              video.muted = false; // Desmuta se necessário
              
              // Tenta dar play
              video.play().catch(e => {
                console.log('[Autoplay] Erro ao dar play no vídeo:', e);
                // Se falhar sem som, tenta com som desligado
                video.muted = true;
                video.play().catch(e2 => console.log('[Autoplay] Erro mesmo mutado:', e2));
              });
            }
          });
          
          // Específico para Twitch player
          const twitchPlayer = document.querySelector('[data-a-target="twitch-player"]');
          if (twitchPlayer) {
            const video = twitchPlayer.querySelector('video');
            if (video && video.paused) {
              console.log('[Twitch Player] Forçando autoplay...');
              video.autoplay = true;
              
              // Tenta dar play
              video.play().then(() => {
                console.log('[Twitch Player] Autoplay iniciado com sucesso');
              }).catch(e => {
                console.log('[Twitch Player] Erro ao iniciar autoplay:', e);
                // Fallback: tenta com mute temporário
                video.muted = true;
                video.play().then(() => {
                  // Após 2 segundos, volta o som
                  setTimeout(() => {
                    video.muted = false;
                  }, 2000);
                }).catch(e2 => console.log('[Twitch Player] Erro mesmo mutado:', e2));
              });
            }
          }
          
          // Força autoplay em iframes (se necessário)
          const iframes = document.querySelectorAll('iframe');
          iframes.forEach(iframe => {
            try {
              const iframeDoc = iframe.contentDocument || iframe.contentWindow.document;
              const iframeVideos = iframeDoc.querySelectorAll('video');
              iframeVideos.forEach(video => {
                if (video.paused) {
                  video.autoplay = true;
                  video.play().catch(e => console.log('[Iframe] Erro autoplay:', e));
                }
              });
            } catch (e) {
              // Cross-origin iframe, ignorar
            }
          });
          
          // Observer para novos vídeos que podem ser carregados dinamicamente
          const observer = new MutationObserver(function(mutations) {
            mutations.forEach(function(mutation) {
              mutation.addedNodes.forEach(function(node) {
                if (node.tagName === 'VIDEO') {
                  const video = node;
                  video.autoplay = true;
                  if (video.paused) {
                    video.play().catch(e => console.log('[Observer] Erro autoplay:', e));
                  }
                }
              });
            });
          });
          
          observer.observe(document.body, {
            childList: true,
            subtree: true
          });
          
        } catch (e) {
          console.error('[Autoplay Script] Erro geral:', e);
        }
      ''';

      if (_controllerA != null) {
        await _controllerA!.executeScript(autoplayScript);
      }

      if (_controllerB != null) {
        await _controllerB!.executeScript(autoplayScript);
      }
    } catch (e, s) {
      _logger.error('Error forcing autoplay', e, s);
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
