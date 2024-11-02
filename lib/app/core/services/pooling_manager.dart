// ignore_for_file: unused_field

import 'dart:async';

import '../exceptions/failure.dart';
import 'webview_manager.dart';

import '../../service/home/home_service.dart';
import '../logger/app_logger.dart';

class PollingManager {
  final AppLogger _logger;
  final HomeService _homeService;
  final WebViewManager _webViewManager;

  static const Duration pollingInterval = Duration(minutes: 6);
  static const Duration healthCheckInterval = Duration(minutes: 2);
  static const int maxConsecutiveErrors = 3;

  Timer? _pollingTimer;
  Timer? _healthCheckTimer;
  bool _isPollingActive = false;
  int _consecutivePollingErrors = 0;
  DateTime? _lastSuccessfulPoll;
  String? currentChannel;

  PollingManager(
    this._logger,
    this._homeService,
    this._webViewManager,
  );

  Future<void> start() async {
    _logger.info('Iniciando polling para atualizações...');
    _stopPolling();

    try {
      await _executePolling();
      _startPeriodicPolling();
      _startHealthCheck();
      _isPollingActive = true;
      _logger.info(
        'Polling iniciado com sucesso - Intervalo: ${pollingInterval.inSeconds}s',
      );
    } catch (e, s) {
      _logger.error('Erro ao iniciar polling', e, s);
      _handlePollingError(e);
    }
  }

  void _startPeriodicPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(pollingInterval, (timer) async {
      try {
        await _executePolling();
      } catch (e, s) {
        _logger.error('Erro durante polling periódico', e, s);
        _handlePollingError(e);
      }
    });
  }

  void _startHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(healthCheckInterval, (timer) async {
      await _checkPollingHealth();
    });
  }

  Future<void> _executePolling() async {
    try {
      if (!_webViewManager.isWebViewInitialized) {
        throw Failure(message: 'WebView não inicializado');
      }

      await _loadCurrentChannel();

      _consecutivePollingErrors = 0;
      _lastSuccessfulPoll = DateTime.now();

      _logger.info('Polling executado com sucesso: ${DateTime.now()}');
    } catch (e, s) {
      _consecutivePollingErrors++;
      _logger.error(
        'Erro no polling (tentativa $_consecutivePollingErrors)',
        e,
        s,
      );
      rethrow;
    }
  }

  Future<void> _loadCurrentChannel() async {
    try {
      final newChannel = await _homeService.fetchCurrentChannel();
      currentChannel = newChannel ?? 'https://twitch.tv/BoostTeam_';

      if (_webViewManager.isWebViewInitialized && currentChannel != null) {
        await _webViewManager.loadUrl(currentChannel!);
        _logger.info('Current Channel: $currentChannel');
      }
    } catch (e, s) {
      _logger.error('Error loading current channel URL', e, s);
      throw Failure(message: 'Erro ao carregar o canal atual');
    }
  }

  Future<void> _checkPollingHealth() async {
    _logger.info('Verificando saúde do polling...');

    final now = DateTime.now();
    final lastPoll = _lastSuccessfulPoll;

    if (lastPoll != null) {
      final timeSinceLastPoll = now.difference(lastPoll);
      if (timeSinceLastPoll > pollingInterval * 2) {
        _logger.warning(
          'Polling pode estar travado. Última atualização: $lastPoll',
        );
        await _recoverPolling();
        return;
      }
    }

    try {
      final expectedChannel = await _homeService.fetchCurrentChannel();
      if (expectedChannel != null && expectedChannel != currentChannel) {
        _logger.warning(
          'Canal atual diferente do esperado. Atual: $currentChannel, Esperado: $expectedChannel',
        );
        await _recoverPolling();
        return;
      }
    } catch (e, s) {
      _logger.error('Erro ao verificar canal atual', e, s);
    }

    if (_consecutivePollingErrors >= maxConsecutiveErrors) {
      _logger.warning(
        'Muitos erros consecutivos: $_consecutivePollingErrors',
      );
      await _recoverPolling();
    }
  }

  Future<void> _recoverPolling() async {
    _logger.info('Tentando recuperar polling...');

    try {
      _stopPolling();

      await _loadCurrentChannel();
      _startPeriodicPolling();
      _startHealthCheck();

      _consecutivePollingErrors = 0;
      _lastSuccessfulPoll = DateTime.now();
      _isPollingActive = true;

      _logger.info('Polling recuperado com sucesso');
    } catch (e, s) {
      _logger.error('Falha ao recuperar polling', e, s);
      Future.delayed(const Duration(minutes: 1), _recoverPolling);
    }
  }

  void _handlePollingError(dynamic error) {
    if (_consecutivePollingErrors >= maxConsecutiveErrors) {
      _logger.error(
        'Muitos erros consecutivos, tentando recuperar polling',
      );
      _recoverPolling();
    }
  }

  Future<void> forceUpdate() async {
    _logger.info('Forçando atualização do polling...');
    try {
      await _executePolling();
      _logger.info('Atualização forçada concluída com sucesso');
    } catch (e, s) {
      _logger.error('Erro na atualização forçada', e, s);
      rethrow;
    }
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
    _isPollingActive = false;
  }

  void dispose() {
    try {
      _stopPolling();
    } catch (e, s) {
      _logger.error('Erro ao fazer dispose do PollingManager', e, s);
    }
  }
}
