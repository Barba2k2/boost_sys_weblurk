import 'dart:async';
import 'package:webview_windows/webview_windows.dart';

import 'webview_controller_interface.dart';

/// Windows implementation of WebViewControllerInterface using webview_windows
class WebViewWindowsController implements WebViewControllerInterface {
  final WebviewController _controller = WebviewController();
  String? _currentUrl;

  @override
  Future<void> initialize() async {
    await _controller.initialize();
  }

  @override
  Future<void> loadUrl(String url) async {
    await _controller.loadUrl(url);
    _currentUrl = url;
  }

  @override
  Future<void> executeScript(String script) async {
    await _controller.executeScript(script);
  }

  @override
  Future<void> setBackgroundColor(dynamic color) async {
    await _controller.setBackgroundColor(color);
  }

  @override
  Future<void> setPopupWindowPolicy(dynamic policy) async {
    await _controller.setPopupWindowPolicy(policy);
  }

  @override
  Future<void> setUserAgent(String userAgent) async {
    await _controller.setUserAgent(userAgent);
  }

  @override
  Stream<dynamic> get loadingState => _controller.loadingState;

  @override
  void dispose() {
    _controller.dispose();
  }

  @override
  String? get currentUrl => _currentUrl;

  @override
  set currentUrl(String? url) {
    _currentUrl = url;
  }

  /// Get the underlying WebviewController for platform-specific operations
  WebviewController get nativeController => _controller;
}
