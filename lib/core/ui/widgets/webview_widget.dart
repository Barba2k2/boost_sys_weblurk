// lib/core/ui/widgets/webview_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import '../../logger/app_logger.dart';

// ✅ CORREÇÃO: Enum para gerenciar os estados do widget de forma clara.
enum _WebViewState { initializing, ready, error }

class MyWebviewWidget extends StatefulWidget {
  const MyWebviewWidget({
    required this.initialUrl,
    this.currentUrl,
    this.logger,
    super.key,
  });

  final String initialUrl;
  final String? currentUrl;
  final AppLogger? logger;

  @override
  State<MyWebviewWidget> createState() => _MyWebviewWidgetState();
}

// ✅ CORREÇÃO: Adicionado AutomaticKeepAliveClientMixin para manter o estado nas abas.
class _MyWebviewWidgetState extends State<MyWebviewWidget>
    with AutomaticKeepAliveClientMixin {
  final WebviewController _controller = WebviewController();

  // ✅ CORREÇÃO: Variáveis de estado para um controle mais robusto.
  _WebViewState _viewState = _WebViewState.initializing;
  bool _isNavigationLoading = false; // Controla apenas o loading de navegação
  String? _errorMessage;
  String _currentUrl = '';

  final _loadingProgress = ValueNotifier<double>(0);
  Timer? _progressTimer;
  StreamSubscription? _loadingStateSubscription;
  bool _isOperationInProgress = false;

  // ✅ CORREÇÃO: Garante que o estado da aba seja preservado.
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.currentUrl ?? widget.initialUrl;
    _initPlatformState();
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
      widget.logger?.warning(
        'Operação em andamento, aguardando para carregar nova URL: $url',
      );
      return;
    }

    try {
      widget.logger?.info('Carregando nova URL: $url');
      await _controller.loadUrl(url);
    } catch (e, s) {
      widget.logger?.error('Erro ao carregar nova URL: $url', e, s);
    }
  }

  Future<void> _initPlatformState() async {
    if (_isOperationInProgress) {
      widget.logger?.warning(
        'Operação já em andamento, ignorando inicialização',
      );
      return;
    }

    try {
      _isOperationInProgress = true;
      widget.logger?.info('Inicializando WebView Windows');

      // ✅ CORREÇÃO CRÍTICA: Removida verificação incorreta. A verificação de suporte
      // é feita no widget pai (schedule_tabs_widget.dart) antes de criar este.
      // if (!WebviewController.supported) {
      //   throw Exception('WebView não é suportado nesta plataforma');
      // }

      await _controller.initialize();
      await _controller.setBackgroundColor(Colors.transparent);
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      await _disableJavaScriptDialogs();
      _setupEventListeners();
      await _controller.loadUrl(_currentUrl);

      // ✅ CORREÇÃO: Removida chamada de callback não utilizada.
      // widget.onWebViewCreated?.call(_controller);

      if (mounted) {
        setState(() {
          _viewState = _WebViewState.ready;
        });
      }
    } catch (e, s) {
      widget.logger?.error('Erro na inicialização do WebView:', e, s);
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

  Future<void> _disableJavaScriptDialogs() async {
    try {
      await _controller.executeScript('''
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

      widget.logger?.info('Diálogos JavaScript desabilitados com sucesso');
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

      widget.logger?.info('Estado de carregamento: $state');

      if (state == LoadingState.navigationCompleted) {
        _captureCurrentUrl();
      }
    });

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
    try {
      await _controller.executeScript('''
        if (window.chrome && window.chrome.webview) {
          window.chrome.webview.postMessage('current_url:' + window.location.href);
        }
      ''');
    } catch (e) {
      widget.logger?.error('Erro ao capturar URL atual: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ CORREÇÃO: Necessário para AutomaticKeepAliveClientMixin
    super.build(context);

    // ✅ CORREÇÃO: Lógica de build baseada no estado para evitar recriar o WebView.
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
              child: Webview(_controller),
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
    _controller.dispose();
    super.dispose();
  }
}
