import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../logger/app_logger.dart';

class MyWebviewWidget extends StatefulWidget {
  const MyWebviewWidget({
    required this.initialUrl,
    this.onWebViewCreated,
    this.logger,
    super.key,
  });

  final String initialUrl;
  final void Function(WebViewController)? onWebViewCreated;
  final AppLogger? logger;

  @override
  State<MyWebviewWidget> createState() => _MyWebviewWidgetState();
}

class _MyWebviewWidgetState extends State<MyWebviewWidget> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    try {
      widget.logger?.info('Initializing WebView');

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              widget.logger?.info('WebView loading progress: $progress%');
            },
            onPageStarted: (String url) {
              widget.logger?.info('WebView page started: $url');
            },
            onPageFinished: (String url) {
              widget.logger?.info('WebView page finished: $url');
              setState(() {
                _isLoading = false;
              });
            },
            onWebResourceError: (WebResourceError error) {
              widget.logger
                  ?.error('WebView error: ${error.description}', error);
              setState(() {
                _errorMessage = 'Erro ao carregar página: ${error.description}';
                _isLoading = false;
              });
            },
          ),
        )
        ..addJavaScriptChannel(
          'Flutter',
          onMessageReceived: (JavaScriptMessage message) {
            widget.logger?.info('JavaScript message: ${message.message}');
          },
        )
        ..loadRequest(Uri.parse(widget.initialUrl));

      // Adicionar scripts para melhorar a experiência
      await _controller.runJavaScript('''
        // Impedir diálogos de confirmação de saída
        window.addEventListener('beforeunload', function(e) {
          e.preventDefault();
          e.returnValue = '';
        });
        
        // Script para manter a conexão ativa
        setInterval(function() {
          console.log('Heartbeat: ' + new Date().toISOString());
        }, 60000);
        
        // Notificar Flutter quando a página estiver pronta
        window.addEventListener('load', function() {
          Flutter.postMessage('Page loaded successfully');
        });
      ''');

      // Callback de criação
      if (widget.onWebViewCreated != null) {
        widget.onWebViewCreated!(_controller);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e, s) {
      widget.logger?.error('WebView initialization error:', e, s);
      setState(() {
        _errorMessage = '''
            Erro ao inicializar WebView:
            ${e.toString()}
            
            Stack Trace:
            $s
          ''';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Erro ao carregar WebView',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  _errorMessage!,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _errorMessage = null;
                      _isLoading = true;
                    });
                    _initializeWebView();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          Container(
            color: Colors.black87,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Carregando...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
