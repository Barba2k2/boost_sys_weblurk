import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../logger/app_logger.dart';

class WebviewWidget extends StatelessWidget {
  final String initialUrl;
  final void Function(InAppWebViewController) onWebViewCreated;
  final AppLogger? logger;

  const WebviewWidget({
    required this.initialUrl,
    required this.onWebViewCreated,
    this.logger,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri(initialUrl),
      ),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
      ),
      onWebViewCreated: (controller) {
        onWebViewCreated(controller);
      },
      onLoadStart: (controller, url) {
        logger?.info('Carregando: $url');
      },
      onLoadStop: (controller, url) {
        logger?.info('Navegação completada: $url');
      },
      onLoadError: (controller, url, code, message) {
        logger?.error('Erro ao carregar $url: $message');
        logger?.error('Código do erro: $code');
      },
      onPermissionRequest: (controller, request) async {
        logger?.info('Solicitação de permissão de: ${request.origin}');
        return PermissionResponse(
          resources: request.resources,
          action: PermissionResponseAction.GRANT,
        );
      },
      onConsoleMessage: (controller, consoleMessage) {
        logger?.info('Console message: ${consoleMessage.message}');
        if (consoleMessage.messageLevel == ConsoleMessageLevel.ERROR) {
          logger?.error('Erro do console detectado: ${consoleMessage.message}');
        }
      },
    );
  }
}
