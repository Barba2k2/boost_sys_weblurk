import 'package:desktop_webview_window/desktop_webview_window.dart';

import '../../../../utils/utils.dart';

abstract class WebViewRepository {
  Future<Result<void>> initializeWebView(Webview controller);
  Future<Result<void>> loadUrl(String url);
  Future<Result<void>> reload();
  Future<Result<bool>> isResponding();
  bool get isInitialized;
  Webview? get controller;
  Stream<bool> get healthStatus;
  void notifyActivity();
  void dispose();
}
