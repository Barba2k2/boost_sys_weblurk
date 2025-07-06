import 'package:webview_windows/webview_windows.dart';

abstract interface class WindowsWebViewService {
  Future<void> initializeWebView(WebviewController controller);
  Future<void> loadUrl(String url);
  Future<void> reload();
  Future<bool> isResponding();
  bool get isInitialized;
  WebviewController? get controller;
  Stream<bool> get healthStatus;
  void notifyActivity();
  void dispose();
}
