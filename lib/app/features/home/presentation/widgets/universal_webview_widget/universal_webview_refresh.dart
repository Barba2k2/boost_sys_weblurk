import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../../core/logger/app_logger.dart';
import 'universal_webview_javascript.dart';

class UniversalWebViewRefresh {
  static Future<void> safeRefresh({
    required WebViewController controller,
    required String currentUrl,
    required AppLogger? logger,
    required bool isOperationInProgress,
    required Function(bool) setLoadingState,
    required Function() startProgressTimer,
    required Function() resetWebView,
  }) async {
    if (isOperationInProgress) return;
    
    try {
      logger?.info('Iniciando refresh seguro...');
      await UniversalWebViewJavaScript.injectJavaScriptDialogs(
        controller: controller,
        logger: logger,
      );
      
      String urlToRefresh = currentUrl;
      if (urlToRefresh.isEmpty) {
        await UniversalWebViewJavaScript.captureCurrentUrl(
          controller: controller,
          logger: logger,
        );
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      if (urlToRefresh.isNotEmpty) {
        await _refreshWithCurrentUrl(
          controller: controller,
          url: urlToRefresh,
          logger: logger,
          setLoadingState: setLoadingState,
          startProgressTimer: startProgressTimer,
        );
      } else {
        await _refreshWithFallback(
          controller: controller,
          logger: logger,
          resetWebView: resetWebView,
        );
      }
    } catch (e, s) {
      logger?.error('Erro no refresh seguro: $e', s);
      await resetWebView();
    }
  }

  static Future<void> _refreshWithCurrentUrl({
    required WebViewController controller,
    required String url,
    required AppLogger? logger,
    required Function(bool) setLoadingState,
    required Function() startProgressTimer,
  }) async {
    logger?.info('Recarregando pela URL atual: $url');
    setLoadingState(true);
    startProgressTimer();
    await controller.loadRequest(Uri.parse(url));
    logger?.info('URL recarregada com sucesso');
  }

  static Future<void> _refreshWithFallback({
    required WebViewController controller,
    required AppLogger? logger,
    required Function() resetWebView,
  }) async {
    logger?.warning('URL atual não disponível, tentando reload padrão');
    try {
      await UniversalWebViewJavaScript.injectJavaScriptDialogs(
        controller: controller,
        logger: logger,
      );
      await _reloadWithTimeout(controller: controller, logger: logger);
      logger?.info('Reload padrão concluído com sucesso');
    } catch (e) {
      logger?.error('Erro no reload padrão: $e');
      await resetWebView();
    }
  }

  static Future<void> _reloadWithTimeout({
    required WebViewController controller,
    required AppLogger? logger,
  }) async {
    final completer = Completer<void>();
    Timer(const Duration(seconds: 5), () {
      if (!completer.isCompleted) {
        completer.completeError('Timeout no reload');
      }
    });
    
    await controller.reload();
    if (!completer.isCompleted) completer.complete();
    await completer.future;
  }
} 