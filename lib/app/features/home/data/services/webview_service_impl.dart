import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/logger/app_logger.dart';
import '../../domain/services/webview_service.dart';

class WebViewServiceImpl implements WebViewService {
  WebViewServiceImpl({
    required AppLogger logger,
  }) : _logger = logger;

  final AppLogger _logger;
  WebViewController? _controller;
  bool _isInitialized = false;

  @override
  Future<void> initializeWebView(WebViewController controller) async {
    _logger.info('Inicializando WebView');
    _controller = controller;
    _isInitialized = true;
    _logger.info('WebView inicializado com sucesso');
  }

  @override
  Future<void> loadUrl(String url) async {
    _logger.info('Carregando URL: $url');
    if (!_isInitialized || _controller == null) {
      throw Exception('WebView não inicializado');
    }
    await _controller!.loadRequest(Uri.parse(url));
    _logger.info('URL carregada com sucesso: $url');
  }

  @override
  Future<void> reloadWebView() async {
    _logger.info('Recarregando WebView');
    if (!_isInitialized || _controller == null) {
      throw Exception('WebView não inicializado');
    }
    await _controller!.reload();
    _logger.info('WebView recarregado com sucesso');
  }
} 