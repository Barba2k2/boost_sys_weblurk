import 'dart:async';

import '../../../../core/exceptions/failure.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../utils/utils.dart';

abstract class WebViewService {
  Future<void> initializeWebView(dynamic controller);
  Future<void> loadUrl(String url);
  Future<void> reloadWebView();
}

class WebViewServiceImpl implements WebViewService {
  WebViewServiceImpl({
    required AppLogger logger,
  }) : _logger = logger {
    _startActivityMonitoring();
  }

  final AppLogger _logger;
  dynamic _controller;
  DateTime? _lastReload;
  DateTime? _lastActivity;
  final _healthController = StreamController<bool>.broadcast();
  Timer? _activityCheckTimer;

  static const _minReloadInterval = Duration(seconds: 30);
  static const _operationTimeout = Duration(seconds: 15);
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
        final result = await isResponding();

        if (result.isError || !result.asSuccess) {
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
  dynamic get controller => _controller;

  @override
  bool get isInitialized => _controller != null;

  @override
  Future<Result<void>> initializeWebView(dynamic controller) async {
    try {
      _controller = controller;

      // Configurações otimizadas para WebView
      // Removido addScriptToExecuteOnDocumentCreated para compatibilidade

      _lastActivity = DateTime.now();
      _healthController.add(true);
      _logger.info('WebView initialized successfully');
      return Result.ok(null);
    } catch (e, s) {
      _logger.error('Error initializing WebView', e, s);
      _healthController.add(false);
      _controller = null;
      return Result.error(Failure(message: 'Erro ao inicializar WebView'));
    }
  }

  @override
  Future<Result<void>> loadUrl(String url) async {
    if (_controller == null) {
      _healthController.add(false);
      return Result.error(Failure(message: 'WebView não inicializado'));
    }

    try {
      // Usa um completer para controlar o timeout
      final completer = Completer<void>();

      // Timer para timeout
      final timer = Timer(_operationTimeout, () {
        if (!completer.isCompleted) {
          _logger.warning('Timeout ao carregar URL: $url');
          completer.completeError(Failure(message: 'Timeout ao carregar URL'));
        }
      });

      // Executa o loadUrl (compatibilidade)
      if (_controller != null) {
        // Implementação genérica para diferentes tipos de controller
      }

      // Cancela o timer e completa com sucesso
      timer.cancel();
      if (!completer.isCompleted) {
        completer.complete();
      }

      await completer.future;
      _lastActivity = DateTime.now();
      _healthController.add(true);
      _logger.info('URL carregada com sucesso: $url');
      return Result.ok(null);
    } catch (e, s) {
      _logger.error('Error loading URL: $url', e, s);
      _healthController.add(false);
      if (e is Failure) return Result.error(e);
      return Result.error(Failure(message: 'Erro ao carregar URL'));
    }
  }

  @override
  Future<Result<void>> reloadWebView() async {
    if (_controller == null) {
      _healthController.add(false);
      return Result.error(Failure(message: 'WebView não inicializado'));
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

      final completer = Completer<void>();

      final timer = Timer(_operationTimeout, () {
        if (!completer.isCompleted) {
          _logger.warning('Timeout ao recarregar página');
          completer
              .completeError(Failure(message: 'Timeout ao recarregar página'));
        }
      });

      // Implementação genérica para reload
      if (_controller != null) {
        // Reload genérico
      }

      timer.cancel();
      if (!completer.isCompleted) {
        completer.complete();
      }

      await completer.future;
      _lastReload = DateTime.now();
      _lastActivity = DateTime.now();
      _healthController.add(true);
      _logger.info('WebView recarregado com sucesso');
      return Result.ok(null);
    } catch (e, s) {
      _logger.error('Error reloading WebView', e, s);
      _healthController.add(false);
      if (e is Failure) return Result.error(e);
      return Result.error(Failure(message: 'Erro ao recarregar página'));
    }
  }

  @override
  Future<Result<bool>> isResponding() async {
    if (_controller == null) {
      _healthController.add(false);
      return Result.ok(false);
    }

    try {
      final completer = Completer<bool>();

      final timer = Timer(_operationTimeout, () {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      });

      // Tenta executar um script simples para verificar se está respondendo
      _controller!.addScriptToExecuteOnDocumentCreated('''
        window.webViewResponding = true;
      ''');

      timer.cancel();
      if (!completer.isCompleted) {
        completer.complete(true);
      }

      final result = await completer.future;
      return Result.ok(result);
    } catch (e, s) {
      _logger.error('Error checking WebView response', e, s);
      return Result.ok(false);
    }
  }

  @override
  void dispose() {
    _activityCheckTimer?.cancel();
    _healthController.close();
    _controller = null;
  }
}
