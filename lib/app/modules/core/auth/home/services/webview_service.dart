import 'package:desktop_webview_window/desktop_webview_window.dart';

import '../../../../../core/exceptions/failure.dart';
import '../../../../../core/logger/app_logger.dart';

abstract class WebViewService {
  Future<void> initializeWebView(Webview controller);
  Future<void> loadUrl(String url);
  Future<void> reload();
  bool get isInitialized;
  void dispose();
}

class WebViewServiceImpl implements WebViewService {
  final AppLogger _logger;
  Webview? _controller;

  WebViewServiceImpl({required AppLogger logger}) : _logger = logger;

  @override
  bool get isInitialized => _controller != null;

  @override
  Future<void> initializeWebView(Webview controller) async {
    try {
      _controller = controller;
      _logger.info('WebView initialized successfully');
    } catch (e, s) {
      _logger.error('Error initializing WebView', e, s);
      throw Failure(message: 'Erro ao inicializar WebView');
    }
  }

  @override
  Future<void> loadUrl(String url) async {
    if (_controller == null) {
      throw Failure(message: 'WebView não inicializado');
    }

    try {
      _controller?.launch(url);
      _logger.info('URL carregada com sucesso: $url');
    } catch (e, s) {
      _logger.error('Error loading URL: $url', e, s);
      throw Failure(message: 'Erro ao carregar URL');
    }
  }

  @override
  Future<void> reload() async {
    if (_controller == null) {
      throw Failure(message: 'WebView não inicializado');
    }

    try {
      await _controller?.reload();
      _logger.info('WebView recarregado com sucesso');
    } catch (e, s) {
      _logger.error('Error reloading WebView', e, s);
      throw Failure(message: 'Erro ao recarregar página');
    }
  }

  @override
  void dispose() {
    _controller?.close();
    _controller = null;
    _logger.info('WebView disposed');
  }
}
