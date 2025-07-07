import '../../../../core/result/result.dart';
import 'package:desktop_webview_window/desktop_webview_window.dart';

abstract class WebViewRepository {
  Future<AppResult<void>> initializeWebView(Webview controller);
  Future<AppResult<void>> loadUrl(String url);
  Future<AppResult<void>> reload();
  Future<AppResult<bool>> isResponding();
  bool get isInitialized;
  Webview? get controller;
  Stream<bool> get healthStatus;
  void notifyActivity();
  void dispose();
}
