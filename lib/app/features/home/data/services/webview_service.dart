import 'dart:async';

import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/exceptions/failure.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../core/utils/url_validator.dart';

abstract class WebViewService {
  Future<void> initializeWebView(WebViewController controller);
  Future<void> loadUrl(String url);
  Future<void> reload();
  Future<bool> isResponding();
  Future<void> muteWebView();
  Future<void> unmuteWebView();
  Future<void> setWebViewVolume(double volume);
  bool get isInitialized;
  WebViewController? get controller;
  Stream<bool> get healthStatus;
  void dispose();
}

class WebViewServiceImpl implements WebViewService {
  WebViewServiceImpl({
    required AppLogger logger,
  }) : _logger = logger {
    _startActivityMonitoring();
  }

  final AppLogger _logger;
  WebViewController? _controller;
  DateTime? _lastReload;
  DateTime? _lastActivity;
  final _healthController = StreamController<bool>.broadcast();
  Timer? _activityCheckTimer;

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
  WebViewController? get controller => _controller;

  @override
  bool get isInitialized => _controller != null;

  @override
  Future<void> initializeWebView(WebViewController controller) async {
    try {
      _controller = controller;

      // Configurações otimizadas para WebView
      await _controller?.runJavaScript('''
        // Impedir diálogos de confirmação de saída
        window.addEventListener('beforeunload', function(e) {
          e.preventDefault();
          e.returnValue = '';
        });
        
        // Script para manter a conexão ativa
        setInterval(function() {
          console.log('Heartbeat: ' + new Date().toISOString());
        }, 60000);
      ''');

      _lastActivity = DateTime.now();
      _healthController.add(true);
      _logger.info('WebView initialized successfully');
    } catch (e, s) {
      _logger.error('Error initializing WebView', e, s);
      _healthController.add(false);
      _controller = null;
      throw Failure(message: 'Erro ao inicializar WebView');
    }
  }

  @override
  Future<void> loadUrl(String url) async {
    try {
      if (!UrlValidator.isValidUrl(url)) {
        throw Failure(message: 'URL inválida: $url');
      }

      if (_controller == null) {
        throw Failure(message: 'WebView não inicializado');
      }

      await _controller!.loadRequest(Uri.parse(url));
      _lastActivity = DateTime.now();
      _logger.info('URL loaded successfully: $url');
    } catch (e, s) {
      _logger.error('Error loading URL: $url', e, s);
      throw Failure(message: 'Erro ao carregar URL: $url');
    }
  }

  @override
  Future<void> reload() async {
    try {
      final now = DateTime.now();
      if (_lastReload != null) {
        final timeSinceLastReload = now.difference(_lastReload!);
        if (timeSinceLastReload < _minReloadInterval) {
          _logger.info('Reload skipped - too soon since last reload');
          return;
        }
      }

      if (_controller == null) {
        throw Failure(message: 'WebView não inicializado');
      }

      await _controller!.reload();
      _lastReload = now;
      _lastActivity = now;
      _logger.info('WebView reloaded successfully');
    } catch (e, s) {
      _logger.error('Error reloading WebView', e, s);
      throw Failure(message: 'Erro ao recarregar WebView');
    }
  }

  @override
  Future<bool> isResponding() async {
    try {
      if (_controller == null) {
        return false;
      }

      // Verificar se o WebView está respondendo executando um script simples
      final result = await _controller!
          .runJavaScriptReturningResult('document.readyState');
      final isAlive = result.toString().contains('complete');

      if (isAlive) {
        _lastActivity = DateTime.now();
        _healthController.add(true);
      }

      return isAlive;
    } catch (e, s) {
      _logger.error('Error checking WebView health', e, s);
      _healthController.add(false);
      return false;
    }
  }

  @override
  Future<void> muteWebView() async {
    try {
      if (_controller == null) {
        _logger.warning('WebView not initialized for mute operation');
        return;
      }

      await _controller!.runJavaScript('''
        // Mute all audio elements
        const audioElements = document.querySelectorAll('audio, video');
        audioElements.forEach(audio => {
          audio.muted = true;
          audio.volume = 0;
        });
        
        // Mute any WebAudio contexts
        if (window.AudioContext || window.webkitAudioContext) {
          const AudioContext = window.AudioContext || window.webkitAudioContext;
          if (window.audioContext) {
            window.audioContext.suspend();
          }
        }
      ''');

      _logger.info('WebView muted successfully');
    } catch (e, s) {
      _logger.error('Error muting WebView', e, s);
    }
  }

  @override
  Future<void> unmuteWebView() async {
    try {
      if (_controller == null) {
        _logger.warning('WebView not initialized for unmute operation');
        return;
      }

      await _controller!.runJavaScript('''
        // Unmute all audio elements
        const audioElements = document.querySelectorAll('audio, video');
        audioElements.forEach(audio => {
          audio.muted = false;
          audio.volume = 1;
        });
        
        // Resume any WebAudio contexts
        if (window.AudioContext || window.webkitAudioContext) {
          const AudioContext = window.AudioContext || window.webkitAudioContext;
          if (window.audioContext) {
            window.audioContext.resume();
          }
        }
      ''');

      _logger.info('WebView unmuted successfully');
    } catch (e, s) {
      _logger.error('Error unmuting WebView', e, s);
    }
  }

  @override
  Future<void> setWebViewVolume(double volume) async {
    try {
      if (_controller == null) {
        _logger.warning('WebView not initialized for volume control');
        return;
      }

      // Clamp volume between 0 and 1
      final clampedVolume = volume.clamp(0.0, 1.0);

      await _controller!.runJavaScript('''
        // Set volume for all audio elements
        const audioElements = document.querySelectorAll('audio, video');
        audioElements.forEach(audio => {
          audio.volume = $clampedVolume;
          audio.muted = $clampedVolume === 0;
        });
      ''');

      _logger.info('WebView volume set to: $clampedVolume');
    } catch (e, s) {
      _logger.error('Error setting WebView volume', e, s);
    }
  }

  @override
  void dispose() {
    _activityCheckTimer?.cancel();
    _healthController.close();
    _controller = null;
    _logger.info('WebView service disposed');
  }
}
