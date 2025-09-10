import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_windows/webview_windows.dart';

import '../../logger/app_logger.dart';
import '../app_colors.dart';
import '../config/webview_config.dart';
import 'webview_android_controller.dart';
import 'webview_controller_factory.dart';
import 'webview_controller_interface.dart';
import 'webview_windows_controller.dart';

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

  final Function(WebViewControllerInterface, String) onWebViewCreated;
  final String tabIdentifier;

  final String initialUrl;
  final String? currentUrl;
  final AppLogger? logger;

  @override
  State<MyWebviewWidget> createState() => _MyWebviewWidgetState();
}

class _MyWebviewWidgetState extends State<MyWebviewWidget>
    with AutomaticKeepAliveClientMixin {
  late final WebViewControllerInterface _controller;

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
    _controller = WebViewControllerFactory.createController();
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
            final platformName = WebViewControllerFactory.getPlatformName();
            throw Exception('''
WebView não suportado na plataforma $platformName.
            
Soluções:
1. Para Windows: Baixe e instale o Microsoft Edge WebView2 Runtime em:
   https://developer.microsoft.com/en-us/microsoft-edge/webview2/
   
2. Para Android: Verifique se o WebView está habilitado nas configurações
   
3. Execute o aplicativo como administrador (Windows)
   
4. Verifique se o antivírus não está bloqueando

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
      _currentUrl = url;
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

      // Set desktop user agent
      await _controller.setUserAgent(WebViewConfig.defaultDesktopUserAgent);

      // Set popup policy only for Windows
      if (Platform.isWindows) {
        await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      }

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
          final platformName = WebViewControllerFactory.getPlatformName();
          _errorMessage = '''
Erro ao inicializar WebView na plataforma $platformName:
${e.toString()}

Possíveis soluções:
• Para Windows: Instale o Microsoft Edge WebView2 Runtime
• Para Android: Verifique se o WebView está habilitado
• Execute como administrador (Windows)
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

      bool isLoading;
      if (Platform.isWindows) {
        isLoading = state != LoadingState.navigationCompleted;
      } else {
        // For Android/iOS, check if state indicates loading
        isLoading = state == 'loading';
      }

      if (_isNavigationLoading != isLoading) {
        setState(() {
          _isNavigationLoading = isLoading;
        });
      }

      if (Platform.isWindows && state == LoadingState.navigationCompleted) {
        _captureCurrentUrl();
      } else if (!Platform.isWindows && state == 'completed') {
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
      // Execute desktop mode script
      await _controller.executeScript(WebViewConfig.forceDesktopModeScript);

      // Execute post-load desktop script after a short delay
      Future.delayed(const Duration(milliseconds: 500), () async {
        try {
          await _controller.executeScript(WebViewConfig.postLoadDesktopScript);
        } catch (e) {
          widget.logger?.error('Erro ao executar script pós-carregamento: $e');
        }
      });

      // Execute autoplay script after page loads completely
      Future.delayed(const Duration(seconds: 2), () async {
        try {
          await _controller.executeScript('''
            try {
              // Força autoplay para todos os vídeos
              const videoElements = document.querySelectorAll('video');
              videoElements.forEach(video => {
                if (video.paused) {
                  video.autoplay = true;
                  video.muted = false;
                  
                  video.play().catch(e => {
                    console.log('[Page Load Autoplay] Erro ao dar play:', e);
                    video.muted = true;
                    video.play().catch(e2 => console.log('[Page Load Autoplay] Erro mesmo mutado:', e2));
                  });
                }
              });
              
              // Específico para Twitch player
              const twitchPlayer = document.querySelector('[data-a-target="twitch-player"]');
              if (twitchPlayer) {
                const video = twitchPlayer.querySelector('video');
                if (video && video.paused) {
                  console.log('[Page Load] Forçando autoplay Twitch...');
                  video.autoplay = true;
                  
                  video.play().then(() => {
                    console.log('[Page Load] Twitch autoplay iniciado');
                  }).catch(e => {
                    console.log('[Page Load] Erro Twitch autoplay:', e);
                    video.muted = true;
                    video.play().then(() => {
                      setTimeout(() => { video.muted = false; }, 2000);
                    }).catch(e2 => console.log('[Page Load] Erro Twitch mutado:', e2));
                  });
                }
              }
            } catch (e) {
              console.error('[Page Load Autoplay] Erro geral:', e);
            }
          ''');
        } catch (e) {
          widget.logger?.error('Erro ao executar script de autoplay: $e');
        }
      });

      if (Platform.isWindows) {
        await _controller.executeScript(
          '''
            if (window.chrome && window.chrome.webview) {
              window.chrome.webview.postMessage('current_url:' + window.location.href);
            }
          ''',
        );
      } else {
        // For Android/iOS, the URL is already captured in the navigation delegate
        _currentUrl = _controller.currentUrl ?? _currentUrl;
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
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
              child: _buildPlatformWebView(),
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

  Widget _buildPlatformWebView() {
    if (Platform.isWindows) {
      final windowsController = _controller as WebViewWindowsController;
      return Webview(windowsController.nativeController);
    } else {
      final androidController = _controller as WebViewAndroidController;
      return WebViewWidget(controller: androidController.nativeController);
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
