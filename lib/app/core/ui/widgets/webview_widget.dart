import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../logger/app_logger.dart';

class WebviewWidget extends StatefulWidget {
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
  State<WebviewWidget> createState() => _WebviewWidgetState();
}

class _WebviewWidgetState extends State<WebviewWidget> {
  late final WebViewController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent);

    // Atrasa a inicialização do WebView
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    try {
      await _controller.loadRequest(Uri.parse(widget.initialUrl));

      if (!mounted) return;

      setState(() {
        _isInitialized = true;
      });

      // Notifica apenas após a inicialização completa
      if (widget.onWebViewCreated != null) {
        await widget.onWebViewCreated!(_controller);
      }
    } catch (e) {
      widget.logger?.error('Erro ao inicializar WebView', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return WebViewWidget(controller: _controller);
  }
}
