import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../service/webview/windows_web_view_service.dart';
import '../../logger/app_logger.dart';
import '../../../service/webview/windows_web_view_service_impl.dart';
import '../../controllers/volume_controller.dart';

class WindowsWebViewWidget extends StatefulWidget {
  const WindowsWebViewWidget({
    required this.initialUrl,
    this.currentUrl,
    this.onWebViewCreated,
    this.logger,
    super.key,
  });

  final String initialUrl;
  final String? currentUrl;
  final void Function(WebviewController)? onWebViewCreated;
  final AppLogger? logger;

  @override
  State<WindowsWebViewWidget> createState() => _WindowsWebViewWidgetState();
}

class _WindowsWebViewWidgetState extends State<WindowsWebViewWidget> {
  WebviewController _controller = WebviewController();
  bool _isLoading = true;
  String? _errorMessage;
  String _currentUrl = '';
  final _loadingProgress = ValueNotifier<double>(0);
  Timer? _progressTimer;
  StreamSubscription? _loadingStateSubscription;
  StreamSubscription? _webMessageSubscription;

  // Flag para evitar múltiplas operações simultâneas
  bool _isOperationInProgress = false;

  // Obter serviço através do Modular para comunicar atividade
  WindowsWebViewService get _webViewService =>
      Modular.get<WindowsWebViewService>();

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.currentUrl ?? widget.initialUrl;
    _initPlatformState();
  }

  @override
  void didUpdateWidget(WindowsWebViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newUrl = widget.currentUrl ?? widget.initialUrl;
    if (newUrl != _currentUrl && newUrl.isNotEmpty) {
      _currentUrl = newUrl;
      _loadNewUrl(newUrl);
    }
  }

  /// Carrega uma nova URL no WebView
  Future<void> _loadNewUrl(String url) async {
    if (_isOperationInProgress) {
      widget.logger?.warning(
          'Operação em andamento, aguardando para carregar nova URL: $url');
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
      widget.logger
          ?.warning('Operação já em andamento, ignorando inicialização');
      return;
    }

    try {
      _isOperationInProgress = true;
      //

      await _controller.initialize();

      // Inicializa o controller no serviço
      await _webViewService.initializeWebView(_controller);

      // Configurações do WebView - CRÍTICO PARA PREVENIR DIÁLOGOS EXTERNOS
      await _controller.setBackgroundColor(Colors.transparent);

      // Impede que o WebView abra janelas popup (importante para evitar diálogos fora da tela)
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);

      // Desabilita diálogos JavaScript como alert, confirm e prompt - MUITO IMPORTANTE
      await _disableJavaScriptDialogs();

      // Configurando os listeners de eventos apenas no widget
      _setupEventListeners();

      // Carrega a URL inicial
      await _controller.loadUrl(_currentUrl);

      // Notifica o callback de criação
      if (widget.onWebViewCreated != null) {
        widget.onWebViewCreated!(_controller);
      }
    } catch (e, s) {
      widget.logger?.error('Erro na inicialização do WebView:', e, s);
      if (mounted) {
        setState(() {
          _errorMessage = '''
              Erro ao inicializar WebView:
              ${e.toString()}
              
              StackTrace:
              $s
          ''';
        });
      }
    } finally {
      _isOperationInProgress = false;
    }
  }

  // Método específico para desabilitar diálogos JavaScript
  Future<void> _disableJavaScriptDialogs() async {
    try {
      // Nota: O WebView2 do Windows usa diferentes métodos para configurar isto
      // Este é um script que vai substituir as funções de diálogo padrão com versões seguras
      await _controller.executeScript('''
        // Substituir diálogos JavaScript por versões que nunca bloqueiam o navegador
        window.alert = function(message) { 
          console.log("[Alert interceptado]: " + message);
          return true;
        };
        
        window.confirm = function(message) {
          console.log("[Confirm interceptado]: " + message);
          // Sempre retornamos true para que a operação continue
          return true;
        };
        
        window.prompt = function(message, defaultValue) {
          console.log("[Prompt interceptado]: " + message);
          // Retorna o valor padrão ou uma string vazia
          return defaultValue || "";
        };
        
        // Sobrescrever função de diálogo de saída de página
        window.onbeforeunload = null;
        
        // Força todos os diálogos a aparecerem embebidos e não como janelas separadas
        try {
          const originalOpen = window.open;
          window.open = function() {
            console.log("[window.open interceptado]");
            return null; // Não permite abrir novas janelas
          };
        } catch(e) {
          console.error("Erro ao substituir window.open:", e);
        }
      ''');
    } catch (e) {
      widget.logger?.error('Erro ao desabilitar diálogos JavaScript: $e');
    }
  }

  void _setupEventListeners() {
    // Cancelar assinaturas anteriores se houver
    _loadingStateSubscription?.cancel();
    _webMessageSubscription?.cancel();
    _progressTimer?.cancel();

    // Monitorar estados de carregamento
    _loadingStateSubscription = _controller.loadingState.listen((state) {
      if (!mounted) return;

      setState(() {
        // A API correta usa enum para estado de carregamento em vez de isLoading
        _isLoading = state != LoadingState.navigationCompleted;
      });

      if (state == LoadingState.navigationCompleted) {
        _notifyServiceOfActivity();
        _captureCurrentUrl();
        _reapplyVolumeState();
      }
    });

    // Monitorar mensagens da webview
    _webMessageSubscription = _controller.webMessage.listen((message) {
      _notifyServiceOfActivity();

      if (message.startsWith('current_url:')) {
        try {
          final url = message.split('current_url:')[1].trim();
          _currentUrl = url;
        } catch (e) {
          widget.logger?.error('Erro ao extrair URL atual: $e');
        }
      } else if (message.contains('dialog_detected')) {
        // Se detectarmos um diálogo, tentamos lidar com ele
        _handleDetectedDialog();
      }
    });

    // O webview_windows não possui um stream de progresso percentual,
    // então vamos simular isso com alguns valores para a UI
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isLoading) {
        _loadingProgress.value =
            (_loadingProgress.value + 0.02).clamp(0.0, 0.95);
      } else {
        _loadingProgress.value = 1.0;
        timer.cancel();
      }
    });
  }

  // Método para lidar com diálogos detectados
  Future<void> _handleDetectedDialog() async {
    try {
      // Executamos um script que tenta fechar diálogos ou confirmar ações
      await _controller.executeScript('''
        try {
          // Tentar encontrar e clicar em botões de "Sim", "OK", etc.
          var buttons = document.querySelectorAll('button, input[type="button"], input[type="submit"]');
          for (var i = 0; i < buttons.length; i++) {
            var button = buttons[i];
            var text = button.textContent || button.value || '';
            text = text.toLowerCase();
            
            // Procura por botões de confirmação comuns
            if (text.includes('ok') || text.includes('yes') || 
                text.includes('sim') || text.includes('confirm') || 
                text.includes('aceitar') || text.includes('allow')) {
              console.log('Clicando automaticamente no botão: ' + text);
              button.click();
              return;
            }
          }
          
          // Se não encontrar botões específicos, procura por diálogos modais
          var dialogs = document.querySelectorAll('[role="dialog"], .modal, .dialog, .popup');
          for (var i = 0; i < dialogs.length; i++) {
            var closeButton = dialogs[i].querySelector('[aria-label="Close"], .close, .dismiss');
            if (closeButton) {
              console.log('Fechando diálogo automaticamente');
              closeButton.click();
              return;
            }
          }
        } catch(e) {
          console.error('Erro ao tentar lidar com diálogo:', e);
        }
      ''');
    } catch (e) {
      widget.logger?.error('Erro ao tentar lidar com diálogo: $e');
    }
  }

  Future<void> _captureCurrentUrl() async {
    try {
      // Executar um script para obter a URL atual
      await _controller.executeScript('''
        window.chrome.webview.postMessage('current_url:' + window.location.href);
      ''');
    } catch (e) {
      widget.logger?.error('Erro ao capturar URL atual: $e');
    }
  }

  void _notifyServiceOfActivity() {
    try {
      // Informamos ao serviço que o WebView está ativo
      if (_webViewService is WindowsWebViewServiceImpl) {
        (_webViewService as WindowsWebViewServiceImpl).notifyActivity();
      }
    } catch (e) {
      widget.logger?.error('Erro ao notificar serviço de atividade: $e');
    }
  }

  Future<void> _reapplyVolumeState() async {
    try {
      final volumeController = Modular.get<VolumeController>();
      final webViewService = Modular.get<WindowsWebViewService>();
      if (volumeController.isMuted) {
        await webViewService.muteWebView();
      } else {
        await webViewService.unmuteWebView();
      }
    } catch (e) {
      widget.logger?.error('Erro ao reaplicar estado de volume: $e');
    }
  }

  Future<void> safeRefresh() async {
    if (_isOperationInProgress) {
      widget.logger?.warning('Operação já em andamento, ignorando refresh');
      return;
    }

    try {
      _isOperationInProgress = true;

      // Desabilitar diálogos JavaScript novamente antes de recarregar
      await _disableJavaScriptDialogs();

      if (_currentUrl.isEmpty) {
        await _captureCurrentUrl();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (_currentUrl.isNotEmpty) {
        // Mostramos o indicador de carregamento
        setState(() {
          _isLoading = true;
          _loadingProgress.value = 0.0;
        });

        // Recomeçamos o timer de progresso
        _progressTimer?.cancel();
        _progressTimer =
            Timer.periodic(const Duration(milliseconds: 100), (timer) {
          if (_isLoading) {
            _loadingProgress.value =
                (_loadingProgress.value + 0.02).clamp(0.0, 0.95);
          } else {
            _loadingProgress.value = 1.0;
            timer.cancel();
          }
        });

        // Em vez de reload(), que pode travar, carregamos a URL atual novamente
        await _controller.loadUrl(_currentUrl);
      } else {
        widget.logger
            ?.warning('URL atual não disponível, tentando reload padrão');
        try {
          // Pré-configuramos para evitar diálogos
          await _disableJavaScriptDialogs();

          // Fallback para reload padrão com timeout
          final completer = Completer<void>();
          Timer(const Duration(seconds: 5), () {
            if (!completer.isCompleted) {
              completer.completeError('Timeout no reload');
            }
          });

          // Tentativa de reload padrão
          await _controller.reload();
          if (!completer.isCompleted) completer.complete();

          await completer.future;
        } catch (e) {
          widget.logger?.error('Erro no reload padrão: $e');
          // Se falhar, tentamos reinicializar o WebView completamente
          await _resetWebView();
        }
      }
    } catch (e, s) {
      widget.logger?.error('Erro no refresh seguro: $e', s);

      // Em caso de erro, tentamos reinicializar o WebView
      await _resetWebView();
    } finally {
      _isOperationInProgress = false;
    }
  }

  // Método para reinicializar o WebView completamente em caso de problemas graves
  Future<void> _resetWebView() async {
    try {
      widget.logger?.warning('Reinicializando WebView completamente...');

      // Limpamos todas as subscriptions e timers
      _loadingStateSubscription?.cancel();
      _webMessageSubscription?.cancel();
      _progressTimer?.cancel();

      // Destruímos o controlador atual
      await _controller.dispose();

      // Indicamos para o usuário que estamos recarregando
      setState(() {
        _isLoading = true;
        _loadingProgress.value = 0.1;
      });

      // Criamos um novo controlador
      final newController = WebviewController();

      // Inicializamos e configuramos o novo controlador
      await newController.initialize();
      await newController.setBackgroundColor(Colors.transparent);
      await newController.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);

      // Inicializa o novo controller no serviço
      await _webViewService.initializeWebView(newController);

      // Substituímos o controlador
      _controller = newController;

      // Desabilitamos diálogos JavaScript
      await _disableJavaScriptDialogs();

      // Reconfiguramos os listeners
      _setupEventListeners();

      // Carregamos a URL
      if (_currentUrl.isNotEmpty) {
        await _controller.loadUrl(_currentUrl);
      } else {
        await _controller.loadUrl(widget.initialUrl);
      }

      // Notificamos o callback
      if (widget.onWebViewCreated != null) {
        widget.onWebViewCreated!(_controller);
      }
    } catch (e, s) {
      widget.logger?.error('Erro fatal ao reinicializar WebView: $e', s);

      // Se até a reinicialização falhar, mostramos um erro para o usuário
      setState(() {
        _errorMessage = '''
            Erro crítico no WebView:
            ${e.toString()}
            
            Por favor, reinicie o aplicativo.
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
    }

    return Stack(
      children: [
        Webview(_controller),
        if (_isLoading)
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
        Positioned(
          top: 10,
          right: 10,
          child: _isOperationInProgress
              ? const CircularProgressIndicator.adaptive(strokeWidth: 2)
              : Container(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _loadingStateSubscription?.cancel();
    _webMessageSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }
}
