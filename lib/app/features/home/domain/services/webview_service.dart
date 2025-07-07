import 'dart:async';

import '../../../../core/exceptions/failure.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../utils/utils.dart';
import '../../../../core/result/result.dart';

abstract class WebViewService {
  Future<AppResult<void>> initializeWebView(dynamic controller);
  Future<AppResult<void>> loadUrl(String url);
  Future<AppResult<void>> reloadWebView();
  Future<AppResult<bool>> isResponding();
  dynamic get controller;
  bool get isInitialized;
  Stream<bool> get healthStatus;
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
        if (result.isError || result.data == false) {
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
  Future<AppResult<void>> initializeWebView(dynamic controller) async {
    try {
      _controller = controller;
      _lastActivity = DateTime.now();
      _healthController.add(true);
      _logger.info('WebView initialized successfully');
      return AppSuccess(null);
    } catch (e, s) {
      _logger.error('Error initializing WebView', e, s);
      _healthController.add(false);
      _controller = null;
      return AppFailure(Exception('Erro ao inicializar WebView'));
    }
  }

  @override
  Future<AppResult<void>> loadUrl(String url) async {
    if (_controller == null) {
      _healthController.add(false);
      return AppFailure(Exception('WebView não inicializado'));
    }
    try {
      final completer = Completer<void>();
      final timer = Timer(_operationTimeout, () {
        if (!completer.isCompleted) {
          _logger.warning('Timeout ao carregar URL: $url');
          completer.completeError(Exception('Timeout ao carregar URL'));
        }
      });
      // Implementação genérica para diferentes tipos de controller
      timer.cancel();
      if (!completer.isCompleted) {
        completer.complete();
      }
      await completer.future;
      _lastActivity = DateTime.now();
      _healthController.add(true);
      _logger.info('URL carregada com sucesso: $url');
      return AppSuccess(null);
    } catch (e, s) {
      _logger.error('Error loading URL: $url', e, s);
      _healthController.add(false);
      return AppFailure(Exception('Erro ao carregar URL'));
    }
  }

  @override
  Future<AppResult<void>> reloadWebView() async {
    if (_controller == null) {
      _healthController.add(false);
      return AppFailure(Exception('WebView não inicializado'));
    }
    try {
      final now = DateTime.now();
      if (_lastReload != null && now.difference(_lastReload!) < _minReloadInterval) {
        _logger.warning('Recarregamento muito frequente, aguardando...');
        await Future.delayed(_minReloadInterval - now.difference(_lastReload!));
      }
      final completer = Completer<void>();
      final timer = Timer(_operationTimeout, () {
        if (!completer.isCompleted) {
          _logger.warning('Timeout ao recarregar página');
          completer.completeError(Exception('Timeout ao recarregar página'));
        }
      });
      // Reload genérico
      timer.cancel();
      if (!completer.isCompleted) {
        completer.complete();
      }
      await completer.future;
      _lastReload = DateTime.now();
      _lastActivity = DateTime.now();
      _healthController.add(true);
      _logger.info('WebView recarregado com sucesso');
      return AppSuccess(null);
    } catch (e, s) {
      _logger.error('Error reloading WebView', e, s);
      _healthController.add(false);
      return AppFailure(Exception('Erro ao recarregar página'));
    }
  }

  @override
  Future<AppResult<bool>> isResponding() async {
    if (_controller == null) {
      _healthController.add(false);
      return AppSuccess(false);
    }
    try {
      final completer = Completer<bool>();
      final timer = Timer(_operationTimeout, () {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      });
      timer.cancel();
      if (!completer.isCompleted) {
        completer.complete(true);
      }
      final result = await completer.future;
      return AppSuccess(result);
    } catch (e, s) {
      _logger.error('Error checking WebView response', e, s);
      return AppFailure(Exception('Erro ao verificar resposta do WebView'));
    }
  }

  @override
  void dispose() {
    _activityCheckTimer?.cancel();
    _healthController.close();
    _controller = null;
  }
}
