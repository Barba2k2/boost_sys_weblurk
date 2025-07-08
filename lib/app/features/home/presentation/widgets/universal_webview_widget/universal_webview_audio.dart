import 'package:webview_flutter/webview_flutter.dart';
import '../../../../../core/logger/app_logger.dart';

class UniversalWebViewAudio {
  static Future<void> muteAllMedia({
    required WebViewController controller,
    required AppLogger? logger,
  }) async {
    try {
      await controller.runJavaScript(_getMuteJavaScript());
      logger?.info('Áudio do WebView mutado com sucesso');
    } catch (e) {
      logger?.error('Erro ao mutar áudio do WebView: $e');
    }
  }

  static Future<void> unmuteAllMedia({
    required WebViewController controller,
    required AppLogger? logger,
  }) async {
    try {
      await controller.runJavaScript(_getUnmuteJavaScript());
      logger?.info('Áudio do WebView desmutado com sucesso');
    } catch (e) {
      logger?.error('Erro ao desmutar áudio do WebView: $e');
    }
  }

  static String _getMuteJavaScript() {
    return '''
      function muteAllMedia() {
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
        
        const iframes = document.querySelectorAll('iframe');
        iframes.forEach(iframe => {
          try {
            if (iframe.contentWindow) {
              iframe.contentWindow.postMessage('{"method":"setVolume","value":0}', '*');
            }
          } catch(e) {
            console.log('Não foi possível mutar iframe:', e);
          }
        });
        
        if (window.Twitch && window.Twitch.Player) {
          const twitchPlayers = document.querySelectorAll('[data-a-target="twitch-player"]');
          twitchPlayers.forEach(player => {
            if (player.getPlayer) {
              const twitchPlayer = player.getPlayer();
              if (twitchPlayer && twitchPlayer.setVolume) {
                twitchPlayer.setVolume(0);
              }
            }
          });
        }
        
        if (window.YT && window.YT.Player) {
          const ytPlayers = document.querySelectorAll('.ytp-player');
          ytPlayers.forEach(player => {
            if (player.setVolume) {
              player.setVolume(0);
            }
          });
        }
        
        console.log('Todos os elementos de mídia foram mutados');
      }
      
      muteAllMedia();
      
      const observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
          if (mutation.type === 'childList') {
            muteAllMedia();
          }
        });
      });
      
      observer.observe(document.body, {
        childList: true,
        subtree: true
      });
    ''';
  }

  static String _getUnmuteJavaScript() {
    return '''
      function unmuteAllMedia() {
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
        
        const iframes = document.querySelectorAll('iframe');
        iframes.forEach(iframe => {
          try {
            if (iframe.contentWindow) {
              iframe.contentWindow.postMessage('{"method":"setVolume","value":1}', '*');
            }
          } catch(e) {
            console.log('Não foi possível desmutar iframe:', e);
          }
        });
        
        console.log('Todos os elementos de mídia foram desmutados');
      }
      
      unmuteAllMedia();
    ''';
  }
} 