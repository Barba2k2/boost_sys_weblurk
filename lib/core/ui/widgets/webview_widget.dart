import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../app_colors.dart';

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
  String? _message;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    if (widget.initialUrl.isEmpty || widget.initialUrl.trim() == '') {
      return const Center(
        child: Text(
          'URL inválida ou não informada',
          style: TextStyle(color: AppColors.error, fontSize: 16),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Erro ao carregar WebView',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  _errorMessage!,
                  style: TextStyle(fontSize: 12, color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    setState(() {
                      _errorMessage = null;
                      _isLoading = true;
                      _timeout = false;
                    });
                    _controller?.loadUrl(
                      urlRequest: URLRequest(
                        url: WebUri(widget.initialUrl),
                      ),
                    );
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
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
          initialSettings: InAppWebViewSettings(
            userAgent:
                'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.1 Safari/605.1.15',
            useShouldOverrideUrlLoading: true,
            mediaPlaybackRequiresUserGesture: false,
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
              _message = 'Carregando $url';
            });
          },
          onLoadStop: (controller, url) async {
            setState(() {
              _isLoading = false;
              _timeout = false;
              _message = 'Carregado $url';
            });
          },
          onReceivedError: (controller, request, error) {
            setState(() {
              _isLoading = false;
              _timeout = false;
              _errorMessage =
                  'Erro ao carregar página: ${error.description.toString()}';
              _message = 'Erro ao carregar página: ${error.type.toString()}';
            });
          },
          onReceivedServerTrustAuthRequest: (controller, challenge) async {
            return ServerTrustAuthResponse(
              action: ServerTrustAuthResponseAction.PROCEED,
            );
          },
        ),
        if (_isLoading)
          Container(
            color: AppColors.loaderBackground,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator.adaptive(
                    backgroundColor: AppColors.cardHeaderText,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Carregando...',
                    style: TextStyle(
                      color: AppColors.cardHeaderText,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
