import 'package:webview_windows/webview_windows.dart';

import '../../../../utils/utils.dart';

abstract class WebViewRepository {
  Future<Result<void>> initializeWebView(WebviewController controller);
  Future<Result<void>> loadUrl(String url);
  Future<Result<void>> reload();
  Future<Result<bool>> isResponding();
  bool get isInitialized;
  WebviewController? get controller;
  Stream<bool> get healthStatus;
  void notifyActivity();
  void dispose();
}
