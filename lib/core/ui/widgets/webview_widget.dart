import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import '../../../features/home/data/services/webview_service.dart';

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

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    await widget.webviewService.loadUrl(widget.initialUrl);
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
    widget.webviewService.healthStatus.listen((isResponding) {
      if (mounted) {
        setState(() {
          _isLoading = !isResponding;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.initialUrl.isEmpty || widget.initialUrl.trim() == '') {
      return const Center(
        child: Text(
          'URL inválida ou não informada',
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    return Stack(
      children: [
        SizedBox.expand(child: Webview(widget.webviewController)),
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
}
