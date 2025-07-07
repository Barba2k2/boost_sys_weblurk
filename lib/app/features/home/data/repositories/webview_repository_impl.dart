import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:result_dart/result_dart.dart';

import '../../../../core/logger/app_logger.dart';
import '../../../../utils/utils.dart';
import '../../domain/repositories/webview_repository.dart';
import '../datasources/webview_datasource.dart';
import '../../../../core/result/result.dart';

class WebViewRepositoryImpl implements WebViewRepository {
  final WebViewDataSource _dataSource;
  final AppLogger _logger;

  WebViewRepositoryImpl({
    required WebViewDataSource dataSource,
    required AppLogger logger,
  })  : _dataSource = dataSource,
        _logger = logger;

  @override
  Future<AppResult<void>> initializeWebView(Webview controller) async {
    try {
      _logger.info('Inicializando WebView via repository');
      await _dataSource.initializeWebView(controller);
      return AppSuccess(null);
    } catch (e, s) {
      _logger.error('Erro inesperado ao inicializar WebView', e, s);
      return AppFailure(Exception('Erro ao inicializar WebView: $e'));
    }
  }

  @override
  Future<AppResult<void>> loadUrl(String url) async {
    try {
      _logger.info('Carregando URL via repository: $url');
      await _dataSource.loadUrl(url);
      return AppSuccess(null);
    } catch (e, s) {
      _logger.error('Erro inesperado ao carregar URL', e, s);
      return AppFailure(Exception('Erro ao carregar URL: $e'));
    }
  }

  @override
  Future<AppResult<void>> reload() async {
    try {
      _logger.info('Recarregando WebView via repository');
      await _dataSource.reload();
      return AppSuccess(null);
    } catch (e, s) {
      _logger.error('Erro inesperado ao recarregar WebView', e, s);
      return AppFailure(Exception('Erro ao recarregar WebView: $e'));
    }
  }

  @override
  Future<AppResult<bool>> isResponding() async {
    try {
      _logger.info('Verificando resposta do WebView via repository');
      final result = await _dataSource.isResponding();
      return AppSuccess(result);
    } catch (e, s) {
      _logger.error('Erro inesperado ao verificar resposta do WebView', e, s);
      return AppFailure(Exception('Erro ao verificar resposta do WebView: $e'));
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