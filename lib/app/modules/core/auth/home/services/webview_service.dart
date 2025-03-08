import 'dart:async';

import 'package:desktop_webview_window/desktop_webview_window.dart';

import '../../../../../core/exceptions/failure.dart';
import '../../../../../core/logger/app_logger.dart';

abstract class WebViewService {
  Future<void> initializeWebView(Webview controller);
  Future<void> loadUrl(String url);
  Future<void> reload();
  Future<bool> isResponding();
  bool get isInitialized;
  Webview? get controller;
  void dispose();
}

class WebViewServiceImpl implements WebViewService {
  WebViewServiceImpl({
    required AppLogger logger,
  }) : _logger = logger;
  final AppLogger _logger;

  Webview? _controller;
  DateTime? _lastReload;
  static const _minReloadInterval = Duration(seconds: 30);
  static const _operationTimeout = Duration(seconds: 30);

  @override
  Webview? get controller => _controller;

  @override
  bool get isInitialized => _controller != null;

  @override
  Future<void> initializeWebView(Webview controller) async {
    try {
      _controller = controller;

      // Configurações otimizadas para Windows
      _controller?.addScriptToExecuteOnDocumentCreated('''
        window.addEventListener('beforeunload', function(e) {
          e.preventDefault();
          e.returnValue = '';
        });
      ''');

      _logger.info('WebView initialized successfully');
    } catch (e, s) {
      _logger.error('Error initializing WebView', e, s);
      _controller = null;
      throw Failure(message: 'Erro ao inicializar WebView');
    }
  }

  @override
  Future<void> loadUrl(String url) async {
    if (_controller == null) {
      throw Failure(message: 'WebView não inicializado');
    }

    try {
      // Usa um completer para controlar o timeout
      final completer = Completer<void>();

      // Timer para timeout
      final timer = Timer(_operationTimeout, () {
        if (!completer.isCompleted) {
          completer.completeError(Failure(message: 'Timeout ao carregar URL'));
        }
      });

      // Executa o launch
      _controller!.launch(url);

      // Cancela o timer e completa com sucesso
      timer.cancel();
      if (!completer.isCompleted) {
        completer.complete();
      }

      await completer.future;
      _logger.info('URL carregada com sucesso: $url');
    } catch (e, s) {
      _logger.error('Error loading URL: $url', e, s);
      if (e is Failure) rethrow;
      throw Failure(message: 'Erro ao carregar URL');
    }
  }

  @override
  Future<void> reload() async {
    if (_controller == null) {
      throw Failure(message: 'WebView não inicializado');
    }

    try {
      final now = DateTime.now();
      if (_lastReload != null && now.difference(_lastReload!) < _minReloadInterval) {
        _logger.warning('Recarregamento muito frequente, aguardando...');
        await Future.delayed(
          _minReloadInterval - now.difference(_lastReload!),
        );
      }

      final completer = Completer<void>();

      final timer = Timer(_operationTimeout, () {
        if (!completer.isCompleted) {
          completer.completeError(Failure(message: 'Timeout ao recarregar página'));
        }
      });

      await _controller!.reload();

      timer.cancel();
      if (!completer.isCompleted) {
        completer.complete();
      }

      await completer.future;
      _lastReload = DateTime.now();
      _logger.info('WebView recarregado com sucesso');
    } catch (e, s) {
      _logger.error('Error reloading WebView', e, s);
      if (e is Failure) rethrow;
      throw Failure(message: 'Erro ao recarregar página');
    }
  }

  @override
  Future<bool> isResponding() async {
    if (_controller == null) return false;

    try {
      final completer = Completer<bool>();

      final timer = Timer(_operationTimeout, () {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      });

      await _controller!.evaluateJavaScript('1 + 1');

      timer.cancel();
      if (!completer.isCompleted) {
        completer.complete(true);
      }

      return await completer.future;
    } catch (e) {
      _logger.warning('WebView não está respondendo: ${e.toString()}');
      return false;
    }
  }

  @override
  void dispose() {
    try {
      _controller?.close();
      _controller = null;
      _logger.info('WebView disposed');
    } catch (e, s) {
      _logger.error('Error disposing WebView', e, s);
      // Não relança o erro no dispose para evitar crashes
    } finally {
      _controller = null;
    }
  }
}
