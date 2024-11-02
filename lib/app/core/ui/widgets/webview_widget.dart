import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import '../../adapters/web_view_adapter.dart';

class WebviewWidget extends StatefulWidget {
  final WebViewAdapter webViewController;
  final Future<void> initializationFuture;

  const WebviewWidget({
    required this.webViewController,
    required this.initializationFuture,
    super.key,
  });

  @override
  State<WebviewWidget> createState() => _WebviewWidgetState();
}

class _WebviewWidgetState extends State<WebviewWidget> {
  @override
  Widget build(BuildContext context) {
    if (!Platform.isWindows) {
      return const Center(
        child: Text(
          'WebView só está disponível no Windows',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return FutureBuilder<void>(
      future: widget.initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar WebView: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return ListenableBuilder(
            listenable: widget.webViewController.stateController,
            builder: (context, _) {
              if (widget.webViewController.stateController.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Erro no WebView: ${widget.webViewController.stateController.error}',
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          widget.webViewController.initialize();
                        },
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                );
              }

              return Stack(
                children: [
                  const SizedBox.expand(),
                  if (widget.webViewController.stateController.isLoading)
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator.adaptive(
                            backgroundColor: Colors.purple,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Carregando...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          );
        }

        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator.adaptive(
                backgroundColor: Colors.purple,
              ),
              SizedBox(height: 16),
              Text(
                'Inicializando WebView...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }
}
