import 'package:desktop_webview_window/desktop_webview_window.dart';
import '../../../../core/result/result.dart';

abstract class WebViewDataSource {
  Future<AppResult<AppUnit>> initializeWebView(Webview controller);
  Future<AppResult<AppUnit>> loadUrl(String url);
  Future<AppResult<AppUnit>> reload();
  Future<AppResult<bool>> isResponding();
  bool get isInitialized;
  Webview? get controller;
  Stream<bool> get healthStatus;
  void notifyActivity();
  void dispose();
}
