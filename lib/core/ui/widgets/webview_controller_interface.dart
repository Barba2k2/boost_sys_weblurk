import 'dart:async';

/// Abstract interface for webview controllers across different platforms
abstract class WebViewControllerInterface {
  /// Initialize the webview
  Future<void> initialize();

  /// Load a URL in the webview
  Future<void> loadUrl(String url);

  /// Execute JavaScript in the webview
  Future<void> executeScript(String script);

  /// Set background color
  Future<void> setBackgroundColor(dynamic color);

  /// Set popup window policy
  Future<void> setPopupWindowPolicy(dynamic policy);

  /// Set user agent for desktop mode
  Future<void> setUserAgent(String userAgent);

  /// Stream of loading state changes
  Stream<dynamic> get loadingState;

  /// Dispose the controller
  void dispose();

  /// Get the current URL
  String? get currentUrl;

  /// Set current URL
  set currentUrl(String? url);
}
