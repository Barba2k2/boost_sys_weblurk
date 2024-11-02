import '../controller/web_view_state_controller.dart';
import '../web_view_2.dart';

class WebViewWindows {
  final int hwnd;
  WebView2? _webView;
  final WebViewStateController stateController;

  WebViewWindows({required this.hwnd, required this.stateController});

  Future<void> initialize() async {
    try {
      stateController.setLoading(true);

      // Inicializar o WebView2
      _webView = WebView2(hwnd);
      await _webView?.initialize();

      // Configura handlers de eventos
      _setupEventHandlers();

      stateController.setWebviewReady(true);
    } catch (e) {
      stateController.setError(e.toString());
    } finally {
      stateController.setLoading(false);
    }
  }

  void _setupEventHandlers() {
    _webView?.webMessageReceived.listen((message) {
      _handleWebMessage(message);
    });

    _webView?.navigationCompleted.listen((success) {
      if (success) {
        stateController.setLoading(false);
      }
    });

    _webView?.navigationStarting.listen((_) {
      stateController.setLoading(true);
    });

    _webView?.sourceChanged.listen((source) {
      stateController.setCurrentUrl(source);
    });
  }

  void _handleWebMessage(String message) {
    if (message.contains('twitch_token:')) {
      final token = message.split('twitch_token:')[1];
      stateController.setAuthToken(token);
    }
  }

  Future<void> navigate(String url) async {
    try {
      stateController.setLoading(true);
      await _webView?.navigate(url);
      stateController.setCurrentUrl(url);
    } catch (e) {
      stateController.setError(e.toString());
    }
  }

  Future<void> injectJavaScript(String script) async {
    try {
      await _webView?.executeScript(script);
    } catch (e) {
      stateController.setError(e.toString());
    }
  }

  Future<void> addScriptToExecuteOnDocumentCreated(String script) async {
    try {
      await _webView?.addScriptToExecuteOnDocumentCreated(script);
    } catch (e) {
      stateController.setError(e.toString());
    }
  }

  Future<void> setupTwitchTokenCapture() async {
    const script = '''
      new MutationObserver(function(mutations) {
        if (window.location.hash) {
          const params = new URLSearchParams(window.location.hash.substr(1));
          const token = params.get('access_token');
          if (token) {
            window.chrome.webview.postMessage('twitch_token:' + token);
          }
        }
      }).observe(document, {subtree: true, childList: true});
    ''';

    await addScriptToExecuteOnDocumentCreated(script);
  }

  void dispose() {
    _webView?.dispose();
    _webView = null;
  }
}
