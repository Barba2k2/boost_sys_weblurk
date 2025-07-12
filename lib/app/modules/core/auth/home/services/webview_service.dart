import 'dart:async';

import 'package:desktop_webview_window/desktop_webview_window.dart';

import '../../../../../core/exceptions/failure.dart';
import '../../../../../core/logger/app_logger.dart';
import '../../../../../core/utils/url_validator.dart';

abstract class WebViewService {
  Future<void> initializeWebView(Webview controller);
  Future<void> loadUrl(String url);
  Future<void> reload();
  Future<bool> isResponding();
  bool get isInitialized;
  Webview? get controller;
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
  Webview? _controller;
  DateTime? _lastReload;
  DateTime? _lastActivity;
  final _healthController = StreamController<bool>.broadcast();
  Timer? _activityCheckTimer;

  static const _minReloadInterval = Duration(seconds: 30);
  static const _operationTimeout = Duration(seconds: 15);
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
  Webview? get controller => _controller;

  @override
  bool get isInitialized => _controller != null;

  @override
  Future<void> initializeWebView(Webview controller) async {
    try {
      _controller = controller;

      // Configurações otimizadas para WebView
      _controller?.addScriptToExecuteOnDocumentCreated('''
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
      // Usa um completer para controlar o timeout
      final completer = Completer<void>();

      // Timer para timeout
      final timer = Timer(_operationTimeout, () {
        if (!completer.isCompleted) {
          _logger.warning('Timeout ao carregar URL: $validatedUrl');
          completer.completeError(Failure(message: 'Timeout ao carregar URL'));
        }
      });

      // Executa o launch com a URL validada
      _controller!.launch(validatedUrl);

      // Cancela o timer e completa com sucesso
      timer.cancel();
      if (!completer.isCompleted) {
        completer.complete();
      }

      await completer.future;
      _lastActivity = DateTime.now();
      _healthController.add(true);
      _logger.info('URL carregada com sucesso: $validatedUrl');
    } catch (e, s) {
      _logger.error('Error loading URL: $validatedUrl', e, s);
      _healthController.add(false);
      if (e is Failure) rethrow;
      throw Failure(message: 'Erro ao carregar URL');
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

      final completer = Completer<void>();

      final timer = Timer(_operationTimeout, () {
        if (!completer.isCompleted) {
          _logger.warning('Timeout ao recarregar página');
          completer
              .completeError(Failure(message: 'Timeout ao recarregar página'));
        }
      });

      await _controller!.reload();

      timer.cancel();
      if (!completer.isCompleted) {
        completer.complete();
      }

      await completer.future;
      _lastReload = DateTime.now();
      _lastActivity = DateTime.now();
      _healthController.add(true);
      _logger.info('WebView recarregado com sucesso');
    } catch (e, s) {
      _logger.error('Error reloading WebView', e, s);
      _healthController.add(false);
      if (e is Failure) rethrow;
      throw Failure(message: 'Erro ao recarregar página');
    }
  }

  @override
  Future<bool> isResponding() async {
    if (_controller == null) {
      _healthController.add(false);
      return false;
    }

    try {
      final completer = Completer<bool>();

      final timer = Timer(_operationTimeout, () {
        if (!completer.isCompleted) {
          _logger.warning('Timeout na verificação de resposta do WebView');
          completer.complete(false);
        }
      });

      // Tentativa de executar JavaScript simples para verificar se o webview responde
      try {
        await _controller!.evaluateJavaScript('1 + 1');
        timer.cancel();
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      } catch (e) {
        _logger.warning('Erro ao executar JavaScript no WebView: $e');
        timer.cancel();
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      }

      final result = await completer.future;
      _healthController.add(result);

      if (result) {
        _lastActivity = DateTime.now();
      }

      return result;
    } catch (e) {
      _logger.warning('WebView não está respondendo: $e');
      _healthController.add(false);
      return false;
    }
  }

  @override
  void dispose() {
    _activityCheckTimer?.cancel();

    try {
      _controller?.close();
      _controller = null;
      _logger.info('WebView disposed');
    } catch (e, s) {
      _logger.error('Error disposing WebView', e, s);
      // Não relança o erro no dispose para evitar crashes
    } finally {
      _controller = null;
      _healthController.close();
    }
  }
}
