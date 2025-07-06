import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:result_dart/result_dart.dart';

import '../../../../utils/utils.dart';

abstract class WebViewRepository {
  Future<Result<void, Exception>> initializeWebView(Webview controller);
  Future<Result<void, Exception>> loadUrl(String url);
  Future<Result<void, Exception>> reload();
  Future<Result<bool, Exception>> isResponding();
  bool get isInitialized;
  Webview? get controller;
  Stream<bool> get healthStatus;
  void notifyActivity();
  void dispose();
}
