import 'package:flutter/material.dart';
import 'package:desktop_webview_window/desktop_webview_window.dart';
import '../../logger/app_logger.dart';

class MyWebviewWidget extends StatefulWidget {
  const MyWebviewWidget({
    required this.initialUrl,
    this.onWebViewCreated,
    this.logger,
    super.key,
  });
  
  final String initialUrl;
  final void Function(Webview)? onWebViewCreated;
  final AppLogger? logger;

  @override
  State<MyWebviewWidget> createState() => _MyWebviewWidgetState();
}

class _MyWebviewWidgetState extends State<MyWebviewWidget> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    try {
      widget.logger?.info('Initializing WebView Window');

      final webview = await WebviewWindow.create(
        configuration: const CreateConfiguration(
          title: 'Boost Team SysLurk',
          titleBarHeight: 0,
          windowWidth: 1100,
          windowHeight: 670,
        ),
      );

      // Carregar URL
      webview.launch(widget.initialUrl);

      // Callback de criação
      if (widget.onWebViewCreated != null) {
        widget.onWebViewCreated!(webview);
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
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(height: 8),
                SelectableText(_errorMessage!),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _initializeWebView,
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: Colors.black87,
      child: const Center(
        child: Text(
          'As Lives estão sendo exibidas em uma janela separada',
          style: TextStyle(
            fontSize: 28,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
