import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../helpers/win32_helper.dart';
import 'controller/web_view_state_controller.dart';
import 'platform/webview_windows.dart';

class CustomWebView extends StatefulWidget {
  final String initialUrl;
  final Function(String)? onUrlChanged;
  final Function(String)? onTokenReceived;

  const CustomWebView({
    super.key,
    required this.initialUrl,
    this.onUrlChanged,
    this.onTokenReceived,
  });

  @override
  State<CustomWebView> createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  late final WebViewWindows _webView;
  late final WebViewStateController _stateController;
  int? _childHwnd;

  @override
  void initState() {
    super.initState();
    _stateController = WebViewStateController();
    _initializeWebView();
  }

  Future<int> _getHwnd() async {
    try {
      // Usa o Win32Helper existente para obter o HWND do widget
      final hwnd = await Win32Helper.getWidgetWindowHandle(context);
      _childHwnd = hwnd;
      return hwnd;
    } catch (e) {
      _stateController.setError(e.toString());
      rethrow;
    }
  }

  Future<void> _initializeWebView() async {
    try {
      // Obter HWND do widget Flutter
      final hwnd = await _getHwnd();

      _webView = WebViewWindows(
        hwnd: hwnd,
        stateController: _stateController,
      );

      await _webView.initialize();
      if (_stateController.isWebviewReady) {
        await _webView.navigate(widget.initialUrl);
      }
    } catch (e) {
      _stateController.setError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _stateController,
      child: Consumer<WebViewStateController>(
        builder: (context, state, child) {
          if (!state.isWebviewReady) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Erro: ${state.error}'),
                  ElevatedButton(
                    onPressed: _initializeWebView,
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              const SizedBox.expand(),
              if (state.isLoading)
                const Positioned.fill(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    if (_childHwnd != null) {
      Win32Helper.destroyWindow(_childHwnd!);
      _childHwnd = null;
    }
    Win32Helper.clearCache();
    _webView.dispose();
    _stateController.dispose();
    super.dispose();
  }
}
