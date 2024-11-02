import 'dart:io';

import 'package:flutter/material.dart';

import '../adapters/web_view_adapter.dart';
import '../exceptions/failure.dart';
import '../logger/app_logger.dart';
import '../ui/webview/controller/web_view_state_controller.dart';

class WebViewManager {
  final AppLogger _logger;
  final WebViewStateController stateController;
  WebViewAdapter? _webViewController;

  WebViewManager(this._logger) : stateController = WebViewStateController();

  WebViewAdapter get webViewController => _webViewController!;
  bool isWebViewInitialized = false;

  Future<void> initialize() async {
    try {
      if (!Platform.isWindows) {
        throw Failure(message: 'Esta aplicação só está disponível no Windows');
      }

      _logger.info('Criando WebView Controller...');
      _webViewController = WebViewAdapter(stateController: stateController);

      _logger.info('Inicializando WebView...');
      await _webViewController?.initialize();

      _logger.info('Configurando background...');
      await _webViewController?.setBackgroundColor(Colors.transparent);

      _logger.info('WebView inicializado com sucesso');
      isWebViewInitialized = true;
    } catch (e, s) {
      _logger.error('Erro ao inicializar WebView', e, s);
      isWebViewInitialized = false;
      _webViewController = null;
      rethrow;
    }
  }

  Future<void> loadUrl(String url) async {
    try {
      if (!isWebViewInitialized || _webViewController == null) {
        throw Failure(message: 'WebView não inicializado');
      }
      await _webViewController?.loadUrl(url);
    } catch (e) {
      _logger.error('Erro ao carregar URL: $url', e);
      rethrow;
    }
  }

  void dispose() {
    _webViewController?.dispose();
    _webViewController = null;
    isWebViewInitialized = false;
    stateController.dispose();
  }
}
