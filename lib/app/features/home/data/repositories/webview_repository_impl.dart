import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:result_dart/result_dart.dart';

import '../../../../core/logger/app_logger.dart';
import '../../../../utils/utils.dart';
import '../../domain/repositories/webview_repository.dart';
import '../datasources/webview_datasource.dart';

class WebViewRepositoryImpl implements WebViewRepository {
  final WebViewDataSource _dataSource;
  final AppLogger _logger;

  WebViewRepositoryImpl({
    required WebViewDataSource dataSource,
    required AppLogger logger,
  })  : _dataSource = dataSource,
        _logger = logger;

  @override
  Future<Result<void, Exception>> initializeWebView(Webview controller) async {
    try {
      _logger.info('Inicializando WebView via repository');
      return await _dataSource.initializeWebView(controller);
    } catch (e, s) {
      _logger.error('Erro inesperado ao inicializar WebView', e, s);
      return Failure(Exception('Erro ao inicializar WebView: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> loadUrl(String url) async {
    try {
      _logger.info('Carregando URL via repository: $url');
      return await _dataSource.loadUrl(url);
    } catch (e, s) {
      _logger.error('Erro inesperado ao carregar URL', e, s);
      return Failure(Exception('Erro ao carregar URL: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> reload() async {
    try {
      _logger.info('Recarregando WebView via repository');
      return await _dataSource.reload();
    } catch (e, s) {
      _logger.error('Erro inesperado ao recarregar WebView', e, s);
      return Failure(Exception('Erro ao recarregar WebView: $e'));
    }
  }

  @override
  Future<Result<bool, Exception>> isResponding() async {
    try {
      _logger.info('Verificando resposta do WebView via repository');
      return await _dataSource.isResponding();
    } catch (e, s) {
      _logger.error('Erro inesperado ao verificar resposta do WebView', e, s);
      return Failure(Exception('Erro ao verificar resposta do WebView: $e'));
    }
  }

  @override
  bool get isInitialized => _dataSource.isInitialized;

  @override
  Webview? get controller => _dataSource.controller;

  @override
  Stream<bool> get healthStatus => _dataSource.healthStatus;

  @override
  void notifyActivity() => _dataSource.notifyActivity();

  @override
  void dispose() => _dataSource.dispose();
} 