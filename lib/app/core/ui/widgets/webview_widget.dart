import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../logger/app_logger.dart';

class WebviewWidget extends StatelessWidget {
  final String initialUrl;
  final Future<void> Function(WebViewController)? onWebViewCreated;
  final AppLogger? logger;

  const WebviewWidget({
    required this.initialUrl,
    this.onWebViewCreated,
    this.logger,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(initialUrl),
      );

    // Chama o callback assim que o WebViewController for configurado
    if (onWebViewCreated != null) {
      onWebViewCreated!(controller);
      logger?.info('WebviewWidget: onWebViewCreated callback called');
    }

    return WebViewWidget(controller: controller);
  }
}
