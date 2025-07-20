import 'dart:async';
import 'package:desktop_webview_window/desktop_webview_window.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../core/result/result.dart';
import '../../domain/datasources/webview_data_source.dart';

class WebViewDataSourceImpl implements WebViewDataSource {
  WebViewDataSourceImpl({required AppLogger logger}) : _logger = logger;

  final AppLogger _logger;
  Webview? _controller;
  bool _isInitialized = false;
  final _healthController = StreamController<bool>.broadcast();

  @override
  bool get isInitialized => _isInitialized;

  @override
  Webview? get controller => _controller;

  @override
  Stream<bool> get healthStatus => _healthController.stream;

  @override
  Future<AppResult<AppUnit>> initializeWebView(Webview controller) async {
    try {
      _controller = controller;
      _isInitialized = true;
      _healthController.add(true);
      _logger.info('WebViewDataSource: WebView inicializado');
      return AppSuccess(appUnit);
    } catch (e, s) {
      _logger.error('WebViewDataSource: Erro ao inicializar WebView', e, s);
      _healthController.add(false);
      _controller = null;
      return AppFailure(Exception('Erro ao inicializar WebView'));
    }
  }

  @override
  Future<AppResult<AppUnit>> loadUrl(String url) async {
    if (_controller == null) {
      _healthController.add(false);
      return AppFailure(Exception('WebView não inicializado'));
    }
    try {
      _controller!.launch(url);
      _healthController.add(true);
      _logger.info('WebViewDataSource: URL carregada: $url');
      return AppSuccess(appUnit);
    } catch (e, s) {
      _logger.error('WebViewDataSource: Erro ao carregar URL', e, s);
      _healthController.add(false);
      return AppFailure(Exception('Erro ao carregar URL'));
    }
  }

  @override
  Future<AppResult<AppUnit>> reload() async {
    if (_controller == null) {
      _healthController.add(false);
      return AppFailure(Exception('WebView não inicializado'));
    }
    try {
      await _controller!.reload();
      _healthController.add(true);
      _logger.info('WebViewDataSource: WebView recarregado');
      return AppSuccess(appUnit);
    } catch (e, s) {
      _logger.error('WebViewDataSource: Erro ao recarregar WebView', e, s);
      _healthController.add(false);
      return AppFailure(Exception('Erro ao recarregar WebView'));
    }
  }

  @override
  Future<AppResult<bool>> isResponding() async {
    if (_controller == null) {
      _healthController.add(false);
      return AppSuccess(false);
    }
    try {
      // Aqui pode-se implementar um ping real, se possível
      _logger.info('WebViewDataSource: Verificando resposta do WebView');
      return AppSuccess(true);
    } catch (e, s) {
      _logger.error('WebViewDataSource: Erro ao verificar resposta', e, s);
      return AppFailure(Exception('Erro ao verificar resposta do WebView'));
    }
  }

  @override
  void notifyActivity() {
    _healthController.add(true);
    _logger.info('WebViewDataSource: Atividade notificada');
  }

  @override
  void dispose() {
    _healthController.close();
    _controller = null;
    _isInitialized = false;
    _logger.info('WebViewDataSource: Disposed');
  }
}
