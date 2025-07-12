import 'dart:async';

import 'package:webview_windows/webview_windows.dart';

import '../../core/exceptions/failure.dart';
import '../../core/logger/app_logger.dart';
import './windows_web_view_service.dart';
import '../../core/utils/url_validator.dart';

class WindowsWebViewServiceImpl implements WindowsWebViewService {
  WindowsWebViewServiceImpl({
    required AppLogger logger,
  }) : _logger = logger {
    _startActivityMonitoring();
  }

  final AppLogger _logger;
  WebviewController? _controller;
  DateTime? _lastReload;
  DateTime? _lastActivity;
  final _healthController = StreamController<bool>.broadcast();
  Timer? _activityCheckTimer;

  static const _minReloadInterval = Duration(seconds: 30);
  static const _inactivityThreshold = Duration(minutes: 10);

  @override
  Stream<bool> get healthStatus => _healthController.stream;

  void _startActivityMonitoring() {
    _activityCheckTimer?.cancel();
    _activityCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkActivity();
    });
  }

  void _checkActivity() async {
    final now = DateTime.now();
    if (_lastActivity != null) {
      final inactiveTime = now.difference(_lastActivity!);

      if (inactiveTime > _inactivityThreshold) {
        final isAlive = await isResponding();

        if (!isAlive) {
          _healthController.add(false);
        } else {
          _lastActivity = now;
          _healthController.add(true);
        }
      }
    } else {
      _lastActivity = now;
    }
  }

  @override
  WebviewController? get controller => _controller;

  @override
  bool get isInitialized => _controller != null;

  @override
  Future<void> initializeWebView(WebviewController controller) async {
    try {
      // Armazenamos o controller, mas NÃO registramos listeners aqui
      // porque o widget já está registrando seus próprios listeners
      _controller = controller;

      // Apenas usamos o controller para operações, não para eventos
      _lastActivity = DateTime.now();
      _healthController.add(true);
      _logger.info('WebView inicializado com sucesso');
    } catch (e, s) {
      _logger.error('Erro ao inicializar WebView', e, s);
      _healthController.add(false);
      _controller = null;
      throw Failure(message: 'Erro ao inicializar WebView');
    }
  }

  @override
  Future<void> loadUrl(String url) async {
    if (_controller == null) {
      _healthController.add(false);
      throw Failure(message: 'WebView não inicializado');
    }

    // Valida e sanitiza a URL antes de carregar
    final validatedUrl = UrlValidator.validateAndSanitizeUrl(url);
    if (validatedUrl == null) {
      _logger.error('URL inválida ou maliciosa detectada: $url');
      _healthController.add(false);
      throw Failure(message: 'URL inválida ou não permitida');
    }

    try {
      _logger.info('Carregando URL: $validatedUrl');

      // Operação simples, sem usar completer ou listeners adicionais
      await _controller!.loadUrl(validatedUrl);

      _lastActivity = DateTime.now();
      _healthController.add(true);
      _logger.info('URL carregada com sucesso: $validatedUrl');
    } catch (e, s) {
      _logger.error('Erro ao carregar URL: $validatedUrl', e, s);
      _healthController.add(false);
      throw Failure(message: 'Erro ao carregar URL: ${e.toString()}');
    }
  }

  @override
  Future<void> reload() async {
    if (_controller == null) {
      _healthController.add(false);
      throw Failure(message: 'WebView não inicializado');
    }

    try {
      final now = DateTime.now();
      if (_lastReload != null &&
          now.difference(_lastReload!) < _minReloadInterval) {
        _logger.warning('Recarregamento muito frequente, aguardando...');
        await Future.delayed(
          _minReloadInterval - now.difference(_lastReload!),
        );
      }

      _logger.info('Recarregando WebView...');

      // Operação simples de reload sem completer ou listeners adicionais
      await _controller!.reload();

      _lastReload = DateTime.now();
      _lastActivity = DateTime.now();
      _healthController.add(true);
      _logger.info('WebView recarregado com sucesso');
    } catch (e, s) {
      _logger.error('Erro ao recarregar WebView: ${e.toString()}', e, s);
      _healthController.add(false);
      throw Failure(message: 'Erro ao recarregar página: ${e.toString()}');
    }
  }

  @override
  Future<bool> isResponding() async {
    if (_controller == null) {
      _healthController.add(false);
      return false;
    }

    try {
      // Tentativa de executar JavaScript simples para verificar se o webview responde
      // _logger.info('Verificando se WebView está respondendo...');

      await _controller!.executeScript('1 + 1');

      _lastActivity = DateTime.now();
      _healthController.add(true);
      // _logger.info('WebView está respondendo');
      return true;
    } catch (e) {
      _logger.warning('WebView não está respondendo: ${e.toString()}');
      _healthController.add(false);
      return false;
    }
  }

  void notifyActivity() {
    _lastActivity = DateTime.now();
    _healthController.add(true);
  }

  @override
  void dispose() {
    _activityCheckTimer?.cancel();

    try {
      // Não fazemos dispose do controller aqui, deixamos o widget fazer isso
      _controller = null;
      _logger.info('WebView service disposed');
    } catch (e, s) {
      _logger.error('Erro ao fazer dispose do WebView service', e, s);
    } finally {
      _controller = null;
      _healthController.close();
    }
  }
}
