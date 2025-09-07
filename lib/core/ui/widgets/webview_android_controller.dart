import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';

import 'webview_controller_interface.dart';

/// Android implementation of WebViewControllerInterface using webview_flutter
class WebViewAndroidController implements WebViewControllerInterface {
  late final WebViewController _controller;
  String? _currentUrl;
  final StreamController<dynamic> _loadingStateController =
      StreamController<dynamic>.broadcast();

  @override
  Future<void> initialize() async {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            _currentUrl = url;
            _loadingStateController.add('loading');
          },
          onPageFinished: (String url) {
            _currentUrl = url;
            _loadingStateController.add('completed');
          },
          onWebResourceError: (WebResourceError error) {
            _loadingStateController.add('error');
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      );
  }

  @override
  Future<void> loadUrl(String url) async {
    await _controller.loadRequest(Uri.parse(url));
    _currentUrl = url;
  }

  @override
  Future<void> executeScript(String script) async {
    await _controller.runJavaScript(script);
  }

  @override
  Future<void> setBackgroundColor(dynamic color) async {
    // Android webview background color is handled by the widget
    // This is a no-op for Android implementation
  }

  @override
  Future<void> setPopupWindowPolicy(dynamic policy) async {
    // Android webview popup policy is handled by the widget
    // This is a no-op for Android implementation
  }

  @override
  Future<void> setUserAgent(String userAgent) async {
    await _controller.setUserAgent(userAgent);
  }

  @override
  Stream<dynamic> get loadingState => _loadingStateController.stream;

  @override
  void dispose() {
    _loadingStateController.close();
  }

  @override
  String? get currentUrl => _currentUrl;

  @override
  set currentUrl(String? url) {
    _currentUrl = url;
  }

  /// Get the underlying WebViewController for platform-specific operations
  WebViewController get nativeController => _controller;
}
