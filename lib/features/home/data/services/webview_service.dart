import 'dart:async';

import 'package:webview_windows/webview_windows.dart';

import '../../../../core/exceptions/failure.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../core/utils/url_validator.dart';

abstract class WebViewService {
  Future<void> initializeWebView(WebviewController controller);
  Future<void> loadUrlForController(WebviewController controller, String url);
  Future<void> reloadController(WebviewController controller);
  Future<bool> isControllerResponding(WebviewController controller);
  Future<void> muteController(WebviewController controller);
  Future<void> unmuteController(WebviewController controller);
  Future<void> setVolumeForController(
    WebviewController controller,
    double volume,
  );
  Stream<bool> getHealthStatusForController(WebviewController controller);
  void dispose();

  // Métodos para compatibilidade com código existente (usando controller primário)
  Future<void> loadUrl(String url);
  Future<void> reload();
  Future<bool> isResponding();
  Future<void> muteWebView();
  Future<void> unmuteWebView();
  Future<void> setWebViewVolume(double volume);
  bool get isInitialized;
  WebviewController? get controller;
  Stream<bool> get healthStatus;
}

class WebViewServiceImpl implements WebViewService {
  WebViewServiceImpl({
    required AppLogger logger,
  }) : _logger = logger;

  final AppLogger _logger;

  // Mapa para gerenciar múltiplos controllers
  final Map<WebviewController, _ControllerData> _controllers = {};

  // Controller primário para compatibilidade
  WebviewController? _primaryController;

  @override
  Stream<bool> get healthStatus {
    if (_primaryController != null &&
        _controllers.containsKey(_primaryController)) {
      return _controllers[_primaryController]!.healthController.stream;
    }
    return Stream.value(false);
  }

  @override
  WebviewController? get controller => _primaryController;

  @override
  bool get isInitialized => _primaryController != null;

  @override
  Future<void> initializeWebView(WebviewController controller) async {
    try {
      if (_controllers.containsKey(controller)) {
        _logger.info('WebView controller já inicializado');
        return;
      }

      final controllerData = _ControllerData();
      _controllers[controller] = controllerData;

      // Se é o primeiro controller, torna-se o primário
      _primaryController ??= controller;

      // Configurar listeners
      controller.url.listen((url) {
        controllerData.isPageLoaded = true;
        controllerData.lastActivity = DateTime.now();
        controllerData.healthController.add(true);
        _logger.info('WebView navigation completed: $url');
      });

      controller.webMessage.listen((message) {
        controllerData.lastActivity = DateTime.now();
      });

      controllerData.lastActivity = DateTime.now();
      controllerData.healthController.add(true);

      // Iniciar monitoramento de atividade
      _startActivityMonitoring(controller);

      _logger.info('WebView controller initialized successfully');
    } catch (e, s) {
      _logger.error('Error initializing WebView controller', e, s);
      _controllers.remove(controller);
      throw Failure(message: 'Erro ao inicializar WebView');
    }
  }

  void _startActivityMonitoring(WebviewController controller) {
    final controllerData = _controllers[controller];
    if (controllerData == null) return;

    controllerData.activityCheckTimer?.cancel();
    controllerData.activityCheckTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkActivity(controller),
    );
  }

  void _checkActivity(WebviewController controller) {
    final controllerData = _controllers[controller];
    if (controllerData == null) return;

    final now = DateTime.now();
    if (controllerData.lastActivity != null) {
      final inactiveTime = now.difference(controllerData.lastActivity!);
      const inactivityThreshold = Duration(minutes: 10);

      if (inactiveTime > inactivityThreshold) {
        if (!controllerData.isPageLoaded) {
          controllerData.healthController.add(false);
        } else {
          controllerData.lastActivity = now;
          controllerData.healthController.add(true);
        }
      }
    } else {
      controllerData.lastActivity = now;
    }
  }

  @override
  Future<void> loadUrlForController(
      WebviewController controller, String url) async {
    try {
      if (!UrlValidator.isValidUrl(url)) {
        throw Failure(message: 'URL inválida: $url');
      }

      final controllerData = _controllers[controller];
      if (controllerData == null) {
        throw Failure(message: 'WebView controller não inicializado');
      }

      controllerData.isPageLoaded = false;
      await controller.loadUrl(url);
      controllerData.lastActivity = DateTime.now();
      _logger.info('URL loaded successfully: $url');
    } catch (e, s) {
      _logger.error('Error loading URL: $url', e, s);
      throw Failure(message: 'Erro ao carregar URL: $url');
    }
  }

  @override
  Future<void> reloadController(WebviewController controller) async {
    try {
      final controllerData = _controllers[controller];
      if (controllerData == null) {
        throw Failure(message: 'WebView controller não inicializado');
      }

      final now = DateTime.now();
      if (controllerData.lastReload != null) {
        final timeSinceLastReload = now.difference(controllerData.lastReload!);
        const minReloadInterval = Duration(seconds: 30);
        if (timeSinceLastReload < minReloadInterval) {
          _logger.info('Reload skipped - too soon since last reload');
          return;
        }
      }

      controllerData.isPageLoaded = false;
      await controller.reload();
      controllerData.lastReload = now;
      controllerData.lastActivity = now;
      _logger.info('WebView controller reloaded successfully');
    } catch (e, s) {
      _logger.error('Error reloading WebView controller', e, s);
      throw Failure(message: 'Erro ao recarregar WebView');
    }
  }

  @override
  Future<bool> isControllerResponding(WebviewController controller) async {
    final controllerData = _controllers[controller];
    return controllerData?.isPageLoaded ?? false;
  }

  @override
  Future<void> muteController(WebviewController controller) async {
    try {
      final controllerData = _controllers[controller];
      if (controllerData == null) {
        _logger
            .warning('WebView controller not initialized for mute operation');
        return;
      }

      await controller.executeScript('''
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

      _logger.info('WebView controller muted successfully');
    } catch (e, s) {
      _logger.error('Error muting WebView controller', e, s);
    }
  }

  @override
  Future<void> unmuteController(WebviewController controller) async {
    try {
      final controllerData = _controllers[controller];
      if (controllerData == null) {
        _logger
            .warning('WebView controller not initialized for unmute operation');
        return;
      }

      await controller.executeScript('''
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

      _logger.info('WebView controller unmuted successfully');
    } catch (e, s) {
      _logger.error('Error unmuting WebView controller', e, s);
    }
  }

  @override
  Future<void> setVolumeForController(
      WebviewController controller, double volume) async {
    try {
      final controllerData = _controllers[controller];
      if (controllerData == null) {
        _logger
            .warning('WebView controller not initialized for volume control');
        return;
      }

      final clampedVolume = volume.clamp(0.0, 1.0);

      await controller.executeScript('''
        // Set volume for all audio elements
        const audioElements = document.querySelectorAll('audio, video');
        audioElements.forEach(audio => {
          audio.volume = $clampedVolume;
          audio.muted = $clampedVolume === 0;
        });
      ''');

      _logger.info('WebView controller volume set to: $clampedVolume');
    } catch (e, s) {
      _logger.error('Error setting WebView controller volume', e, s);
    }
  }

  @override
  Stream<bool> getHealthStatusForController(WebviewController controller) {
    final controllerData = _controllers[controller];
    if (controllerData != null) {
      return controllerData.healthController.stream;
    }
    return Stream.value(false);
  }

  // Métodos de compatibilidade que usam o controller primário
  @override
  Future<void> loadUrl(String url) async {
    if (_primaryController != null) {
      await loadUrlForController(_primaryController!, url);
    }
  }

  @override
  Future<void> reload() async {
    if (_primaryController != null) {
      await reloadController(_primaryController!);
    }
  }

  @override
  Future<bool> isResponding() async {
    if (_primaryController != null) {
      return await isControllerResponding(_primaryController!);
    }
    return false;
  }

  @override
  Future<void> muteWebView() async {
    if (_primaryController != null) {
      await muteController(_primaryController!);
    }
  }

  @override
  Future<void> unmuteWebView() async {
    if (_primaryController != null) {
      await unmuteController(_primaryController!);
    }
  }

  @override
  Future<void> setWebViewVolume(double volume) async {
    if (_primaryController != null) {
      await setVolumeForController(_primaryController!, volume);
    }
  }

  @override
  void dispose() {
    for (final controllerData in _controllers.values) {
      controllerData.activityCheckTimer?.cancel();
      controllerData.healthController.close();
    }
    _controllers.clear();
    _primaryController = null;
    _logger.info('WebView service disposed');
  }
}

class _ControllerData {
  DateTime? lastReload;
  DateTime? lastActivity;
  final StreamController<bool> healthController =
      StreamController<bool>.broadcast();
  Timer? activityCheckTimer;
  bool isPageLoaded = false;
}
