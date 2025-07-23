import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_windows/webview_windows.dart';

class MyWebviewWidget extends StatefulWidget {
  const MyWebviewWidget({required this.initialUrl, super.key});
  final String initialUrl;

  @override
  State<MyWebviewWidget> createState() => _MyWebviewWidgetState();
}

class _MyWebviewWidgetState extends State<MyWebviewWidget> {
  InAppWebViewController? _controller;
  bool _isLoading = true;
  String? _errorMessage;
  bool _timeout = false;
  WebviewController? _winController;
  bool _winInitialized = false;

  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.windows) {
      _initWinWebView();
    } else {
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted && _isLoading) {
          setState(() {
            _timeout = true;
            _isLoading = false;
            _errorMessage =
                'A página não respondeu.\nPode ser uma limitação da Twitch ou do site. Deseja abrir no navegador externo?';
          });
        }
      });
    }
  }

  Future<void> _initWinWebView() async {
    _winController = WebviewController();
    await _winController!.initialize();
    await _winController!.loadUrl(widget.initialUrl);
    setState(() {
      _winInitialized = true;
      _isLoading = false;
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

    // WINDOWS: embutido
    if (defaultTargetPlatform == TargetPlatform.windows) {
      if (!_winInitialized) {
        return const Center(child: CircularProgressIndicator());
      }
      return SizedBox.expand(child: Webview(_winController!));
    }

    // MOBILE/WEB: usa inappwebview embutido
    if (_errorMessage != null) {
      return Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (_timeout) {
                      final url = Uri.parse(widget.initialUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url,
                            mode: LaunchMode.externalApplication);
                      }
                    } else {
                      setState(() {
                        _errorMessage = null;
                        _isLoading = true;
                        _timeout = false;
                      });
                      _controller?.loadUrl(
                          urlRequest:
                              URLRequest(url: WebUri(widget.initialUrl)));
                    }
                  },
                  icon: Icon(_timeout ? Icons.open_in_browser : Icons.refresh),
                  label: Text(
                      _timeout ? 'Abrir no navegador' : 'Tentar Novamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            useShouldOverrideUrlLoading: true,
            mediaPlaybackRequiresUserGesture: false,
            clearCache: false,
            cacheEnabled: true,
            supportZoom: true,
            transparentBackground: true,
            allowsInlineMediaPlayback: true,
          ),
          onWebViewCreated: (controller) {
            _controller = controller;
          },
          onLoadStart: (controller, url) {
            setState(() {
              _isLoading = true;
              _timeout = false;
            });
          },
          onLoadStop: (controller, url) async {
            setState(() {
              _isLoading = false;
              _timeout = false;
            });
          },
          onReceivedError: (controller, request, error) {
            setState(() {
              _isLoading = false;
              _timeout = false;
              _errorMessage = 'Erro ao carregar página: ${error.description}';
            });
          },
          onReceivedServerTrustAuthRequest: (controller, challenge) async {
            return ServerTrustAuthResponse(
                action: ServerTrustAuthResponseAction.PROCEED);
          },
        ),
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
