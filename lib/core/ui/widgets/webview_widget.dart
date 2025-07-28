import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../logger/app_logger.dart';

enum _WebViewState { initializing, ready, error }

class MyWebviewWidget extends StatefulWidget {
  const MyWebviewWidget({
    required this.initialUrl,
    this.currentUrl,
    this.logger,
    required this.onWebViewCreated,
    required this.tabIdentifier,
    super.key,
  });

  final Function(dynamic controller, String) onWebViewCreated;
  final String tabIdentifier;

  final String initialUrl;
  final String? currentUrl;
  final AppLogger? logger;

  @override
  State<MyWebviewWidget> createState() => _MyWebviewWidgetState();
}

class _MyWebviewWidgetState extends State<MyWebviewWidget>
    with AutomaticKeepAliveClientMixin {
  dynamic _controller;
  bool _isMacOS = false;

  _WebViewState _viewState = _WebViewState.initializing;
  bool _isNavigationLoading = false;
  String? _errorMessage;
  String _currentUrl = '';

  final _loadingProgress = ValueNotifier<double>(0);
  Timer? _progressTimer;
  StreamSubscription? _loadingStateSubscription;
  bool _isOperationInProgress = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.currentUrl ?? widget.initialUrl;
    _isMacOS = Platform.isMacOS;
    _initController();
    _initPlatformState();
  }

  void _initController() {
    if (!_isMacOS) {
      _controller = WebviewController();
    } else {
      // Para macOS, o controller será inicializado no InAppWebView
      _controller = null;
    }
  }

  @override
  void didUpdateWidget(MyWebviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newUrl = widget.currentUrl ?? widget.initialUrl;
    if (newUrl != _currentUrl && newUrl.isNotEmpty) {
      _currentUrl = newUrl;
      _loadNewUrl(newUrl);
    }
  }

  Future<void> _loadNewUrl(String url) async {
    if (_isOperationInProgress || _controller == null) {
      return;
    }

    try {
      if (_isMacOS) {
        await _controller.loadUrl(
          urlRequest: URLRequest(url: WebUri(url)),
        );
      } else {
        await _controller.loadUrl(url);
      }
    } catch (e, s) {
      widget.logger?.error('Erro ao carregar nova URL: $url', e, s);
    }
  }

  Future<void> _initPlatformState() async {
    if (_isOperationInProgress) {
      return;
    }

    try {
      _isOperationInProgress = true;

      if (_isMacOS) {
        await _initMacOSWebView();
      } else {
        if (_controller != null) {
          await _initWindowsWebView();
        } else {
          throw Exception('Controller não inicializado');
        }
      }

      if (_controller != null) {
        widget.onWebViewCreated(_controller, widget.tabIdentifier);
      }

      if (mounted) {
        setState(() {
          _viewState = _WebViewState.ready;
        });
      }
    } catch (e, s) {
      if (mounted) {
        setState(
          () {
            _viewState = _WebViewState.error;
            _errorMessage = '''
              Erro ao inicializar WebView:
              ${e.toString()}

              StackTrace:
              $s
            ''';
          },
        );
      }
    } finally {
      _isOperationInProgress = false;
    }
  }

  Future<void> _initMacOSWebView() async {
    // Para macOS, a inicialização é feita no InAppWebView widget
    // O controller é passado via onWebViewCreated
    setState(() {
      _viewState = _WebViewState.ready;
    });
  }

  Future<void> _initWindowsWebView() async {
    if (_controller == null) {
      throw Exception('Controller não inicializado');
    }

    await _controller.initialize();
    await _controller.setBackgroundColor(Colors.transparent);
    await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
    await _disableJavaScriptDialogs();
    _setupEventListeners();
    await _controller.loadUrl(_currentUrl);
  }

  Future<void> _disableJavaScriptDialogs() async {
    if (_controller == null) {
      return;
    }

    try {
      if (_isMacOS) {
        await _controller.evaluateJavascript(source: '''
          window.alert = function(message) { 
            console.log("[Alert interceptado]: " + message);
            return true;
          };
          
          window.confirm = function(message) {
            console.log("[Confirm interceptado]: " + message);
            return true;
          };
          
          window.prompt = function(message, defaultValue) {
            console.log("[Prompt interceptado]: " + message);
            return defaultValue || "";
          };
          
          window.onbeforeunload = null;
          
          try {
            const originalOpen = window.open;
            window.open = function() {
              console.log("[window.open interceptado]");
              return null;
            };
          } catch(e) {
            console.error("Erro ao substituir window.open:", e);
          }
        ''');
      } else {
        await _controller.executeScript(
          '''
            window.alert = function(message) { 
              console.log("[Alert interceptado]: " + message);
              return true;
            };
            
            window.confirm = function(message) {
              console.log("[Confirm interceptado]: " + message);
              return true;
            };
            
            window.prompt = function(message, defaultValue) {
              console.log("[Prompt interceptado]: " + message);
              return defaultValue || "";
            };
            
            window.onbeforeunload = null;
            
            try {
              const originalOpen = window.open;
              window.open = function() {
                console.log("[window.open interceptado]");
                return null;
              };
            } catch(e) {
              console.error("Erro ao substituir window.open:", e);
            }
          ''',
        );
      }
    } catch (e) {
      widget.logger?.error('Erro ao desabilitar diálogos JavaScript: $e');
    }
  }

  void _setupEventListeners() {
    _loadingStateSubscription?.cancel();
    _progressTimer?.cancel();

    if (!_isMacOS && _controller != null) {
      _loadingStateSubscription = _controller.loadingState.listen((state) {
        if (!mounted) return;

        final isLoading = state != LoadingState.navigationCompleted;
        if (_isNavigationLoading != isLoading) {
          setState(() {
            _isNavigationLoading = isLoading;
          });
        }

        if (state == LoadingState.navigationCompleted) {
          _captureCurrentUrl();
        }
      });
    }

    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isNavigationLoading) {
        _loadingProgress.value =
            (_loadingProgress.value + 0.02).clamp(0.0, 0.95);
      } else {
        _loadingProgress.value = 1.0;
        timer.cancel();
      }
    });
  }

  Future<void> _captureCurrentUrl() async {
    if (_controller == null) {
      return;
    }

    try {
      if (_isMacOS) {
        await _controller.evaluateJavascript(source: '''
          if (window.webkit && window.webkit.messageHandlers) {
            window.webkit.messageHandlers.urlHandler.postMessage(window.location.href);
          }
        ''');
      } else {
        await _controller.executeScript(
          '''
            if (window.chrome && window.chrome.webview) {
              window.chrome.webview.postMessage('current_url:' + window.location.href);
            }
          ''',
        );
      }
    } catch (e) {
      widget.logger?.error('Erro ao capturar URL atual: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    switch (_viewState) {
      case _WebViewState.initializing:
        return Container(
          color: Colors.black87,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator.adaptive(
                  backgroundColor: Colors.white,
                ),
                SizedBox(height: 16),
                Text(
                  'Inicializando WebView...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        );

      case _WebViewState.error:
        return Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  SelectableText(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _initPlatformState,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            ),
          ),
        );

      case _WebViewState.ready:
        return Stack(
          children: [
            SizedBox.expand(
              child: _isMacOS
                  ? InAppWebView(
                      initialUrlRequest: URLRequest(url: WebUri(_currentUrl)),
                      onWebViewCreated: (controller) {
                        widget.onWebViewCreated(
                            controller, widget.tabIdentifier);
                      },
                      onLoadStart: (controller, url) {
                        setState(() {
                          _isNavigationLoading = true;
                        });
                      },
                      onLoadStop: (controller, url) {
                        setState(() {
                          _isNavigationLoading = false;
                        });
                        _captureCurrentUrl();
                      },
                      onLoadError: (controller, url, code, message) {
                        widget.logger?.error(
                            'Erro ao carregar URL: $url, Código: $code, Mensagem: $message');
                      },
                      initialSettings: InAppWebViewSettings(
                        allowsInlineMediaPlayback: true,
                        mediaPlaybackRequiresUserGesture: false,
                        supportZoom: false,
                        useShouldOverrideUrlLoading: true,
                        useOnLoadResource: true,
                      ),
                    )
                  : Webview(_controller),
            ),
            if (_isNavigationLoading)
              ValueListenableBuilder<double>(
                valueListenable: _loadingProgress,
                builder: (context, progress, _) {
                  return LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.black12,
                    color: Colors.purple,
                  );
                },
              ),
          ],
        );
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _loadingStateSubscription?.cancel();
    if (!_isMacOS && _controller != null) {
      _controller.dispose();
    }
    super.dispose();
  }
}
