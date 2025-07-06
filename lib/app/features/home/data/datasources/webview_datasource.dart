import 'package:webview_windows/webview_windows.dart';

import '../../../../core/logger/app_logger.dart';
import '../../../../service/webview/windows_web_view_service.dart';
import '../../../../utils/utils.dart';

abstract class WebViewDataSource {
  Future<Result<void>> initializeWebView(WebviewController controller);
  Future<Result<void>> loadUrl(String url);
  Future<Result<void>> reload();
  Future<Result<bool>> isResponding();
  bool get isInitialized;
  WebviewController? get controller;
  Stream<bool> get healthStatus;
  void notifyActivity();
  void dispose();
}

class WebViewDataSourceImpl implements WebViewDataSource {
  final AppLogger _logger;
  final WindowsWebViewService _webViewService;

  WebViewDataSourceImpl({
    required AppLogger logger,
    required WindowsWebViewService webViewService,
  })  : _logger = logger,
        _webViewService = webViewService;

  @override
  Future<Result<void>> initializeWebView(WebviewController controller) async {
    try {
      _logger.info('Inicializando WebView');
      await _webViewService.initializeWebView(controller);
      _logger.info('WebView inicializado com sucesso');
      return Result.ok(null);
    } catch (e, s) {
      _logger.error('Erro ao inicializar WebView', e, s);
      return Result.error(e as Exception);
    }
  }

  @override
  Future<Result<void>> loadUrl(String url) async {
    try {
      _logger.info('Carregando URL: $url');
      await _webViewService.loadUrl(url);
      _logger.info('URL carregada com sucesso');
      return Result.ok(null);
    } catch (e, s) {
      _logger.error('Erro ao carregar URL', e, s);
      return Result.error(e as Exception);
    }
  }

  @override
  Future<Result<void>> reload() async {
    try {
      _logger.info('Recarregando WebView');
      await _webViewService.reload();
      _logger.info('WebView recarregado com sucesso');
      return Result.ok(null);
    } catch (e, s) {
      _logger.error('Erro ao recarregar WebView', e, s);
      return Result.error(e as Exception);
    }
  }

  @override
  Future<Result<bool>> isResponding() async {
    try {
      final isResponding = await _webViewService.isResponding();
      return Result.ok(isResponding);
    } catch (e, s) {
      _logger.error('Erro ao verificar resposta do WebView', e, s);
      return Result.error(e as Exception);
    }
  }

  @override
  bool get isInitialized => _webViewService.isInitialized;

  @override
  WebviewController? get controller => _webViewService.controller;

  @override
  Stream<bool> get healthStatus => _webViewService.healthStatus;

  @override
  void notifyActivity() => _webViewService.notifyActivity();

  @override
  void dispose() => _webViewService.dispose();
}
