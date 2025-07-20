import 'package:webview_flutter/webview_flutter.dart';
import '../../../../../core/logger/app_logger.dart';

class UniversalWebViewNavigation {
  static NavigationDelegate createNavigationDelegate({
    required Function(String) onPageStarted,
    required Function(int) onProgress,
    required Function(String) onPageFinished,
    required Function(NavigationRequest) onNavigationRequest,
    required Function(WebResourceError) onWebResourceError,
  }) {
    return NavigationDelegate(
      onPageStarted: onPageStarted,
      onProgress: onProgress,
      onPageFinished: onPageFinished,
      onNavigationRequest: (request) async => onNavigationRequest(request),
      onWebResourceError: onWebResourceError,
    );
  }

  static void handlePageStarted(String url, AppLogger? logger) {
    logger?.info('Página iniciando: $url');
  }

  static void handleProgress(int progress, AppLogger? logger) {
    logger?.info('Progresso: $progress%');
  }

  static void handlePageFinished(String url, AppLogger? logger) {
    logger?.info('Página carregada: $url');
  }

  static NavigationDecision handleNavigationRequest(
    NavigationRequest request,
    AppLogger? logger,
  ) {
    logger?.info('Navegação solicitada: ${request.url}');
    return NavigationDecision.navigate;
  }

  static void handleWebResourceError(
    WebResourceError error,
    AppLogger? logger,
  ) {
    logger?.error('Erro de recurso Web: ${error.description}');
  }
} 