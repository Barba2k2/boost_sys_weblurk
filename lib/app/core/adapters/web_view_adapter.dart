import 'package:webview_windows/webview_windows.dart';
import 'package:flutter/material.dart';
import '../helpers/win32_helper.dart';
import '../ui/webview/controller/web_view_state_controller.dart';
import '../ui/webview/platform/webview_windows.dart';

class WebViewAdapter extends WebviewController {
  final WebViewStateController stateController;
  WebViewWindows? _webViewWindows;

  WebViewAdapter({required this.stateController});

  @override
  Future<void> initialize() async {
    try {
      stateController.setLoading(true);

      // Obtém o HWND
      final hwnd = await Win32Helper.getFlutterWindowHandle();

      _webViewWindows = WebViewWindows(
        hwnd: hwnd,
        stateController: stateController,
      );

      await _webViewWindows?.initialize();
    } catch (e) {
      stateController.setError(e.toString());
      rethrow;
    } finally {
      stateController.setLoading(false);
    }
  }

  @override
  Future<void> loadUrl(String url) async {
    try {
      await _webViewWindows?.navigate(url);
    } catch (e) {
      stateController.setError(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> setBackgroundColor(Color color) async {
    // Implementar se necessário
  }

  @override
  Future<void> dispose() async {
    _webViewWindows?.dispose();
    _webViewWindows = null;
    await super.dispose();
  }

  WebViewWindows? get webViewImplementation => _webViewWindows;
}

