import 'dart:async';

import 'package:webview_windows/webview_windows.dart';

import '../../core/exceptions/failure.dart';
import '../../core/logger/app_logger.dart';
import './windows_web_view_service.dart';
import '../../core/utils/url_validator.dart';

class WindowsWebViewServiceImpl implements WindowsWebViewService {
  WindowsWebViewServiceImpl({
    required AppLogger logger,
  }) : _logger = logger {
    _startActivityMonitoring();
  }

  final AppLogger _logger;
  WebviewController? _controller;
  DateTime? _lastReload;
  DateTime? _lastActivity;
  final _healthController = StreamController<bool>.broadcast();
  Timer? _activityCheckTimer;

  // Controle de volume do WebView
  double _currentVolume = 1.0;
  double _savedVolume = 1.0;

  static const _minReloadInterval = Duration(seconds: 30);
  static const _inactivityThreshold = Duration(minutes: 10);

  @override
  Stream<bool> get healthStatus => _healthController.stream;

  void _startActivityMonitoring() {
    _activityCheckTimer?.cancel();
    _activityCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkActivity();
    });
  }

  void _checkActivity() async {
    final now = DateTime.now();
    if (_lastActivity != null) {
      final inactiveTime = now.difference(_lastActivity!);

      if (inactiveTime > _inactivityThreshold) {
        final isAlive = await isResponding();

        if (!isAlive) {
          _healthController.add(false);
        } else {
          _lastActivity = now;
          _healthController.add(true);
        }
      }
    } else {
      _lastActivity = now;
    }
  }

  @override
  WebviewController? get controller => _controller;

  @override
  bool get isInitialized => _controller != null;

  @override
  Future<void> initializeWebView(WebviewController controller) async {
    try {
      // Armazenamos o controller, mas NÃO registramos listeners aqui
      // porque o widget já está registrando seus próprios listeners
      _controller = controller;

      // Apenas usamos o controller para operações, não para eventos
      _lastActivity = DateTime.now();
      _healthController.add(true);
      _logger.info('WebView inicializado com sucesso');
    } catch (e, s) {
      _logger.error('Erro ao inicializar WebView', e, s);
      _healthController.add(false);
      _controller = null;
      throw Failure(message: 'Erro ao inicializar WebView');
    }
  }

  @override
  Future<void> loadUrl(String url) async {
    if (_controller == null) {
      _healthController.add(false);
      throw Failure(message: 'WebView não inicializado');
    }

    // Valida e sanitiza a URL antes de carregar
    final validatedUrl = UrlValidator.validateAndSanitizeUrl(url);
    if (validatedUrl == null) {
      _logger.error('URL inválida ou maliciosa detectada: $url');
      _healthController.add(false);
      throw Failure(message: 'URL inválida ou não permitida');
    }

    try {
      _logger.info('Carregando URL: $validatedUrl');

      // Operação simples, sem usar completer ou listeners adicionais
      await _controller!.loadUrl(validatedUrl);

      _lastActivity = DateTime.now();
      _healthController.add(true);
      _logger.info('URL carregada com sucesso: $validatedUrl');
    } catch (e, s) {
      _logger.error('Erro ao carregar URL: $validatedUrl', e, s);
      _healthController.add(false);
      throw Failure(message: 'Erro ao carregar URL: ${e.toString()}');
    }
  }

  @override
  Future<void> reload() async {
    if (_controller == null) {
      _healthController.add(false);
      throw Failure(message: 'WebView não inicializado');
    }

    try {
      final now = DateTime.now();
      if (_lastReload != null &&
          now.difference(_lastReload!) < _minReloadInterval) {
        _logger.warning('Recarregamento muito frequente, aguardando...');
        await Future.delayed(
          _minReloadInterval - now.difference(_lastReload!),
        );
      }

      _logger.info('Recarregando WebView...');

      // Operação simples de reload sem completer ou listeners adicionais
      await _controller!.reload();

      _lastReload = DateTime.now();
      _lastActivity = DateTime.now();
      _healthController.add(true);
      _logger.info('WebView recarregado com sucesso');
    } catch (e, s) {
      _logger.error('Erro ao recarregar WebView: ${e.toString()}', e, s);
      _healthController.add(false);
      throw Failure(message: 'Erro ao recarregar página: ${e.toString()}');
    }
  }

  @override
  Future<bool> isResponding() async {
    if (_controller == null) {
      _healthController.add(false);
      return false;
    }

    try {
      // Tentativa de executar JavaScript simples para verificar se o webview responde
      // _logger.info('Verificando se WebView está respondendo...');

      await _controller!.executeScript('1 + 1');

      _lastActivity = DateTime.now();
      _healthController.add(true);
      // _logger.info('WebView está respondendo');
      return true;
    } catch (e) {
      _logger.warning('WebView não está respondendo: ${e.toString()}');
      _healthController.add(false);
      return false;
    }
  }

  @override
  Future<void> muteWebView() async {
    if (_controller == null) {
      _logger.warning('WebView não inicializado para mutar');
      return;
    }

    try {
      _logger.info('Iniciando muteWebView...');
      _savedVolume = _currentVolume;
      _currentVolume = 0.0;
      _logger.info(
          'Estado do WebView atualizado - Volume: $_currentVolume, Saved: $_savedVolume');

      // JavaScript para mutar todos os elementos de áudio/vídeo
      const muteScript = '''
        (function() {
          console.log('Executando script de mute...');
          
          // Muta todos os vídeos
          const videos = document.querySelectorAll('video');
          console.log('Vídeos encontrados:', videos.length);
          videos.forEach((video, index) => {
            video.muted = true;
            video.volume = 0;
            console.log('Vídeo ' + (index + 1) + ' mutado');
          });
          
          // Muta todos os áudios
          const audios = document.querySelectorAll('audio');
          console.log('Áudios encontrados:', audios.length);
          audios.forEach((audio, index) => {
            audio.muted = true;
            audio.volume = 0;
            console.log('Áudio ' + (index + 1) + ' mutado');
          });
          
          // Muta elementos de áudio/vídeo em iframes (se possível)
          const iframes = document.querySelectorAll('iframe');
          console.log('Iframes encontrados:', iframes.length);
          iframes.forEach((iframe, index) => {
            try {
              const iframeDoc = iframe.contentDocument || iframe.contentWindow.document;
              const iframeVideos = iframeDoc.querySelectorAll('video');
              const iframeAudios = iframeDoc.querySelectorAll('audio');
              
              console.log('Iframe ' + (index + 1) + ': ' + iframeVideos.length + ' vídeos, ' + iframeAudios.length + ' áudios');
              
              iframeVideos.forEach((video, vIndex) => {
                video.muted = true;
                video.volume = 0;
                console.log('Vídeo ' + (vIndex + 1) + ' do iframe ' + (index + 1) + ' mutado');
              });
              
              iframeAudios.forEach((audio, aIndex) => {
                audio.muted = true;
                audio.volume = 0;
                console.log('Áudio ' + (aIndex + 1) + ' do iframe ' + (index + 1) + ' mutado');
              });
            } catch (e) {
              console.log('Iframe ' + (index + 1) + ': Cross-origin, não foi possível acessar');
            }
          });
          
          console.log('Script de mute concluído');
          return 'WebView mutado - Vídeos: ' + videos.length + ', Áudios: ' + audios.length + ', Iframes: ' + iframes.length;
        })();
      ''';

      _logger.info('Executando script JavaScript de mute...');
      final result = await _controller!.executeScript(muteScript);
      _logger.info('Script de mute executado com resultado: $result');
      _logger.info('WebView mutado com sucesso');
    } catch (e, s) {
      _logger.error('Erro ao mutar WebView', e, s);
    }
  }

  @override
  Future<void> unmuteWebView() async {
    if (_controller == null) {
      _logger.warning('WebView não inicializado para desmutar');
      return;
    }

    try {
      _currentVolume = _savedVolume;

      // JavaScript para desmutar todos os elementos de áudio/vídeo
      final unmuteScript = '''
        (function() {
          const volume = $_savedVolume;
          
          // Desmuta todos os vídeos
          const videos = document.querySelectorAll('video');
          videos.forEach(video => {
            video.muted = false;
            video.volume = volume;
          });
          
          // Desmuta todos os áudios
          const audios = document.querySelectorAll('audio');
          audios.forEach(audio => {
            audio.muted = false;
            audio.volume = volume;
          });
          
          // Desmuta elementos de áudio/vídeo em iframes (se possível)
          const iframes = document.querySelectorAll('iframe');
          iframes.forEach(iframe => {
            try {
              const iframeDoc = iframe.contentDocument || iframe.contentWindow.document;
              const iframeVideos = iframeDoc.querySelectorAll('video');
              const iframeAudios = iframeDoc.querySelectorAll('audio');
              
              iframeVideos.forEach(video => {
                video.muted = false;
                video.volume = volume;
              });
              
              iframeAudios.forEach(audio => {
                audio.muted = false;
                audio.volume = volume;
              });
            } catch (e) {
              // Cross-origin iframe, não podemos acessar
            }
          });
          
          return 'WebView desmutado com volume: ' + volume;
        })();
      ''';

      await _controller!.executeScript(unmuteScript);
      _logger.info('WebView desmutado com sucesso. Volume: $_savedVolume');
    } catch (e, s) {
      _logger.error('Erro ao desmutar WebView', e, s);
    }
  }

  @override
  Future<void> setWebViewVolume(double volume) async {
    if (_controller == null) {
      _logger.warning('WebView não inicializado para definir volume');
      return;
    }

    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      _currentVolume = clampedVolume;

      if (clampedVolume > 0.0) {
        _savedVolume = clampedVolume;
      }

      // JavaScript para definir volume em todos os elementos de áudio/vídeo
      final volumeScript = '''
        (function() {
          const volume = $clampedVolume;
          
          // Define volume em todos os vídeos
          const videos = document.querySelectorAll('video');
          videos.forEach(video => {
            video.volume = volume;
            video.muted = volume === 0;
          });
          
          // Define volume em todos os áudios
          const audios = document.querySelectorAll('audio');
          audios.forEach(audio => {
            audio.volume = volume;
            audio.muted = volume === 0;
          });
          
          // Define volume em elementos de áudio/vídeo em iframes (se possível)
          const iframes = document.querySelectorAll('iframe');
          iframes.forEach(iframe => {
            try {
              const iframeDoc = iframe.contentDocument || iframe.contentWindow.document;
              const iframeVideos = iframeDoc.querySelectorAll('video');
              const iframeAudios = iframeDoc.querySelectorAll('audio');
              
              iframeVideos.forEach(video => {
                video.volume = volume;
                video.muted = volume === 0;
              });
              
              iframeAudios.forEach(audio => {
                audio.volume = volume;
                audio.muted = volume === 0;
              });
            } catch (e) {
              // Cross-origin iframe, não podemos acessar
            }
          });
          
          return 'Volume do WebView definido para: ' + volume;
        })();
      ''';

      await _controller!.executeScript(volumeScript);
      _logger.info('Volume do WebView definido para: $clampedVolume');
    } catch (e, s) {
      _logger.error('Erro ao definir volume do WebView', e, s);
    }
  }

  @override
  Future<double> getWebViewVolume() async {
    return _currentVolume;
  }

  void notifyActivity() {
    _lastActivity = DateTime.now();
    _healthController.add(true);
  }

  @override
  void dispose() {
    _activityCheckTimer?.cancel();

    try {
      // Não fazemos dispose do controller aqui, deixamos o widget fazer isso
      _controller = null;
      _logger.info('WebView service disposed');
    } catch (e, s) {
      _logger.error('Erro ao fazer dispose do WebView service', e, s);
    } finally {
      _controller = null;
      _healthController.close();
    }
  }
}
