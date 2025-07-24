import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import '../../../features/home/data/services/webview_service.dart';
import '../app_colors.dart';

class MyWebviewWidget extends StatefulWidget {
  const MyWebviewWidget({
    required this.initialUrl,
    required this.webviewController,
    required this.webviewService,
    super.key,
  });

  final String initialUrl;
  final WebviewController webviewController;
  final WebViewService webviewService;

  @override
  State<MyWebviewWidget> createState() => _MyWebviewWidgetState();
}

class _MyWebviewWidgetState extends State<MyWebviewWidget> {
  bool _isLoading = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    try {
      // ✅ CORREÇÃO: Primeiro inicializar o service com o controller
      await widget.webviewService.initializeWebView(widget.webviewController);

      // ✅ Depois carregar a URL
      await widget.webviewService.loadUrl(widget.initialUrl);

      // Script para manter a conexão ativa e impedir diálogos
      await widget.webviewController.executeScript('''
        // Impedir diálogos de confirmação de saída
        window.addEventListener('beforeunload', function(e) {
          e.preventDefault();
          e.returnValue = '';
        });
        
        // Script para manter a conexão ativa
        setInterval(function() {
          console.log('Heartbeat: ' + new Date().toISOString());
        }, 60000);
      ''');

      // ✅ Escutar o health status do service
      widget.webviewService.healthStatus.listen((isResponding) {
        if (mounted) {
          setState(() {
            _isLoading = !isResponding;
            _isInitialized = isResponding;
          });
        }
      });

      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao inicializar WebView: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isInitialized = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.initialUrl.isEmpty || widget.initialUrl.trim() == '') {
      return const Center(
        child: Text(
          'URL inválida ou não informada',
          style: TextStyle(
            color: AppColors.error,
            fontSize: 16,
          ),
        ),
      );
    }

    return Stack(
      children: [
        if (_isInitialized)
          SizedBox.expand(child: Webview(widget.webviewController))
        else
          Container(
            color: AppColors.webviewBackground,
            child: const Center(
              child: Text(
                'Inicializando WebView...',
                style: TextStyle(
                  color: AppColors.webviewText,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        if (_isLoading)
          Container(
            color: AppColors.webviewBackground,
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
}
