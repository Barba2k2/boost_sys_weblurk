import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';

import '../../logger/app_logger.dart';
import '../app_colors.dart';

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

  final Function(WebviewController, String) onWebViewCreated;
  final String tabIdentifier;

  final String initialUrl;
  final String? currentUrl;
  final AppLogger? logger;

  @override
  State<MyWebviewWidget> createState() => _MyWebviewWidgetState();
}

class _MyWebviewWidgetState extends State<MyWebviewWidget>
    with AutomaticKeepAliveClientMixin {
  final WebviewController _controller = WebviewController();

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
    _currentUrl = (widget.currentUrl?.isNotEmpty ?? false)
        ? widget.currentUrl!
        : widget.initialUrl;
    _initPlatformState();
  }

  Future<void> _initializeWebViewWithRetry() async {
    final int maxRetries = 3;
    for (int i = 0; i < maxRetries; i++) {
      try {
        await _controller.initialize();
        return;
      } catch (e) {
        if (i == maxRetries - 1) {
          // Última tentativa - melhorar mensagem de erro
          if (e.toString().contains('unsupported_platform')) {
            throw Exception('''
WebView2 Runtime não encontrado ou não suportado.
            
Soluções:
1. Baixe e instale o Microsoft Edge WebView2 Runtime em:
   https://developer.microsoft.com/en-us/microsoft-edge/webview2/
   
2. Execute o aplicativo como administrador
   
3. Verifique se o antivírus não está bloqueando

Erro original: $e
            ''');
          }
          rethrow;
        }

        // Aguardar antes da próxima tentativa
        await Future.delayed(Duration(milliseconds: 500 * (i + 1)));
      }
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
    if (_isOperationInProgress) {
      return;
    }

    try {
      await _controller.loadUrl(url);
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

      // Tentar inicializar com retry
      await _initializeWebViewWithRetry();
      await _controller.setBackgroundColor(Colors.transparent);
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      await _disableJavaScriptDialogs();
      _setupEventListeners();
      await _controller.loadUrl(_currentUrl);

      widget.onWebViewCreated(_controller, widget.tabIdentifier);

      if (mounted) {
        setState(() {
          _viewState = _WebViewState.ready;
        });
      }
    } catch (e, s) {
      widget.logger?.error('Erro na inicialização do WebView: $e', e, s);

      if (mounted) {
        setState(() {
          _viewState = _WebViewState.error;
          _errorMessage = '''
Erro ao inicializar WebView:
${e.toString()}

Possíveis soluções:
• Instale o Microsoft Edge WebView2 Runtime
• Execute como administrador  
• Verifique antivírus/firewall

StackTrace:
$s
            ''';
        });
      }
    } finally {
      _isOperationInProgress = false;
    }
  }

  Future<void> _disableJavaScriptDialogs() async {
    try {
      widget.logger?.debug('Desabilitando diálogos JavaScript');
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
      widget.logger?.debug('Diálogos JavaScript desabilitados com sucesso');
    } catch (e) {
      widget.logger?.error('Erro ao desabilitar diálogos JavaScript: $e');
    }
  }

  void _setupEventListeners() {
    _loadingStateSubscription?.cancel();
    _progressTimer?.cancel();

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

    _progressTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        if (_isNavigationLoading) {
          _loadingProgress.value =
              (_loadingProgress.value + 0.02).clamp(0.0, 0.95);
        } else {
          _loadingProgress.value = 1.0;
          timer.cancel();
        }
      },
    );
  }

  Future<void> _captureCurrentUrl() async {
    try {
      await _controller.executeScript(
        '''
          if (window.chrome && window.chrome.webview) {
            window.chrome.webview.postMessage('current_url:' + window.location.href);
          }
        ''',
      );
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
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.cosmicNavy,
                AppColors.cosmicBlue,
                AppColors.cosmicDarkPurple,
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator.adaptive(
                  backgroundColor: Colors.white,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.cosmicAccent),
                ),
                SizedBox(height: 16),
                Text(
                  'Inicializando WebView...',
                  style: TextStyle(
                    color: AppColors.cosmicAccent,
                    fontSize: 16,
                    fontFamily: 'Ibrand',
                    fontWeight: FontWeight.w600,
                  ),
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
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
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
              child: Webview(_controller),
            ),
            if (_isNavigationLoading)
              ValueListenableBuilder<double>(
                valueListenable: _loadingProgress,
                builder: (context, progress, _) {
                  return LinearProgressIndicator(
                    value: progress,
                    backgroundColor:
                        AppColors.cosmicNavy.withValues(alpha: 0.3),
                    color: AppColors.cosmicAccent,
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
    _controller.dispose();
    super.dispose();
  }
}
