import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';

import '../../logger/app_logger.dart';

class WebviewWidget extends StatefulWidget {
  final String initialUrl;
  final Function(WebviewController)? onWebViewCreated;
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
  late final WebviewController _controller;
  late final Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _controller = WebviewController();
    _initializationFuture = _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    try {
      await _controller.initialize();
      await _controller.setBackgroundColor(Colors.transparent);
      await _controller.loadUrl(widget.initialUrl);

      if (widget.onWebViewCreated != null) {
        widget.onWebViewCreated!(_controller);
      }
    } catch (e) {
      widget.logger?.error('⚠️ Webview initialization error: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            widget.logger?.error('⚠️ Snapshot Error: ${snapshot.error}');
          }
          return Webview(
            _controller,
            permissionRequested: (url, permissionKind, isUserInitiated) {
              return Future.value(WebviewPermissionDecision.allow);
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator.adaptive(
              backgroundColor: Colors.purple,
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
