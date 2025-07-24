import 'dart:async';

import 'package:webview_windows/webview_windows.dart';

import '../../../../core/exceptions/failure.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../core/utils/url_validator.dart';

abstract class WebViewService {
  Future<void> initializeWebView(WebviewController controller);
  Future<void> loadUrl(String url);
  Future<void> reload();
  Future<bool> isResponding();
  Future<void> muteWebView();
  Future<void> unmuteWebView();
  Future<void> setWebViewVolume(double volume);
  bool get isInitialized;
  WebviewController? get controller;
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
  WebviewController? _controller;
  DateTime? _lastReload;
  DateTime? _lastActivity;
  final _healthController = StreamController<bool>.broadcast();
  Timer? _activityCheckTimer;
  bool _isPageLoaded = false;

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
        if (!_isPageLoaded) {
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
      _controller = controller;
      _controller!.url.listen(
        (url) {
          {
            _isPageLoaded = true;
            _lastActivity = DateTime.now();
            _healthController.add(true);
            _logger.info('WebView navigation completed: $url');
          }
        },
      );
      _controller!.webMessage.listen(
        (message) {
          _lastActivity = DateTime.now();
        },
      );

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
      _isPageLoaded = false;
      await _controller!.loadUrl(url);
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
      _isPageLoaded = false;
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
    return _isPageLoaded;
  }

  @override
  Future<void> muteWebView() async {
    try {
      if (_controller == null) {
        _logger.warning('WebView not initialized for mute operation');
        return;
      }

      await _controller!.executeScript('''
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

      await _controller!.executeScript('''
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

      await _controller!.executeScript('''
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
