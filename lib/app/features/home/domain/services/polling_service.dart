import 'dart:async';
import 'dart:math';

import '../../../../core/exceptions/failure.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../utils/utils.dart';
import 'home_service.dart';

abstract class PollingService {
  Future<void> startPolling(int streamerId);
  Future<void> stopPolling();
  Future<void> checkAndUpdateChannel();
  Future<void> checkAndUpdateScore(int streamerId);
  Stream<bool> get healthStatus;
  Stream<String> get channelUpdates;
  bool isPollingActive();
  void dispose();
}

class PollingServiceImpl implements PollingService {
  PollingServiceImpl({
    required HomeService homeService,
    required AppLogger logger,
  })  : _homeService = homeService,
        _logger = logger {
    _setupSystemLifecycleDetection();
  }

  final HomeService _homeService;
  final AppLogger _logger;
  Timer? _channelTimer;
  Timer? _scoreTimer;
  Timer? _watchdogTimer;
  Timer? _backgroundWatcherTimer;
  DateTime? _lastChannelUpdate;
  DateTime? _lastScoreUpdate;
  DateTime? _lastSuspensionResume;

  // Canal atual e canal base
  String? _currentChannel;
  final String _baseChannel = 'https://twitch.tv/BoostTeam_';

  // Controllers para notificações
  final _healthController = StreamController<bool>.broadcast();
  final _channelController = StreamController<String>.broadcast();

  // Ajuste os intervalos conforme necessário
  static const _pollingInterval = Duration(minutes: 6);
  static const _channelCheckInterval = Duration(minutes: 6);
  static const _watchdogInterval = Duration(minutes: 2);
  static const _maxTimeSinceLastUpdate = Duration(minutes: 15);

  // Parâmetros de backoff para erros do servidor
  int _scoreErrorCount = 0;
  static const _maxBackoffMinutes = 30;
  static const _initialBackoffSeconds = 30;

  @override
  Stream<bool> get healthStatus => _healthController.stream;

  @override
  Stream<String> get channelUpdates => _channelController.stream;

  void _setupSystemLifecycleDetection() {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      final now = DateTime.now();
      if (_lastSuspensionResume != null) {
        final diff = now.difference(_lastSuspensionResume!);
        if (diff.inMinutes > 2) {
          _onSystemResume();
        }
      }
      _lastSuspensionResume = now;
    });
  }

  void _onSystemResume() {
    _forceChannelCheck();
  }

  Future<void> _forceChannelCheck() async {
    try {
      await checkAndUpdateChannel();
    } catch (e, s) {
      _logger.error('Erro na verificação forçada de canal', e, s);
    }
  }

  @override
  Future<void> startPolling(int streamerId) async {
    try {
      // Verificação imediata do canal correto
      await checkAndUpdateChannel();

      _startTimers(streamerId);
      _startWatchdog(streamerId);
      _healthController.add(true);

      _startBackgroundWatcher(streamerId);
    } catch (e, s) {
      _logger.error('Erro ao iniciar polling services ${DateTime.now()}', e, s);
      _healthController.add(false);
      stopPolling();
    }
  }

  void _startBackgroundWatcher(int streamerId) {
    _backgroundWatcherTimer?.cancel();

    _backgroundWatcherTimer =
        Timer.periodic(const Duration(minutes: 10), (timer) {
      if (!isPollingActive()) {
        _logger.info(
          'Polling inativo detectado pelo background watcher, reiniciando...',
        );
        _startTimers(streamerId);
      }

      // Verificar também se estamos no canal correto
      _verifyCorrectChannel();
    });
  }

  void _startTimers(int streamerId) {
    _channelTimer?.cancel();
    _scoreTimer?.cancel();

    // Executa imediatamente
    checkAndUpdateChannel();
    checkAndUpdateScore(streamerId);

    // Configura os timers periódicos
    _channelTimer = Timer.periodic(
      _channelCheckInterval,
      (_) => checkAndUpdateChannel(),
    );

    _scoreTimer = Timer.periodic(
      _pollingInterval,
      (_) => checkAndUpdateScore(streamerId),
    );
  }

  void _startWatchdog(int streamerId) {
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer.periodic(_watchdogInterval, (_) {
      _checkAndRestartIfNeeded(streamerId);
    });
  }

  void _checkAndRestartIfNeeded(int streamerId) {
    final now = DateTime.now();
    bool needsRestart = false;

    if (_lastChannelUpdate != null) {
      final channelUpdateDiff = now.difference(_lastChannelUpdate!);
      _logger.info(
          'Última atualização de canal: ${channelUpdateDiff.inMinutes} minutos atrás');

      if (channelUpdateDiff > _maxTimeSinceLastUpdate) {
        _logger.warning(
            'Watchdog: Atualizações de canal paradas, reiniciando polling... $now');
        needsRestart = true;
      }
    } else {
      _logger.warning(
          'Watchdog: Nenhuma atualização de canal registrada, reiniciando...');
      needsRestart = true;
    }

    if (_lastScoreUpdate != null) {
      final scoreUpdateDiff = now.difference(_lastScoreUpdate!);
      _logger.info(
          'Última atualização de score: ${scoreUpdateDiff.inMinutes} minutos atrás');

      if (scoreUpdateDiff > _maxTimeSinceLastUpdate) {
        _logger.warning(
            'Watchdog: Atualizações de score paradas, reiniciando polling... $now');
        needsRestart = true;
      }
    } else {
      _logger.warning(
          'Watchdog: Nenhuma atualização de score registrada, reiniciando...');
      needsRestart = true;
    }

    // Verificar se os timers ainda estão ativos
    if (_channelTimer == null ||
        !_channelTimer!.isActive ||
        _scoreTimer == null ||
        !_scoreTimer!.isActive) {
      _logger.warning('Watchdog: Timers inativos, reiniciando polling...');
      needsRestart = true;
    }

    if (needsRestart) {
      _logger.info('Watchdog: Reiniciando polling...');
      _startTimers(streamerId);
    }
  }

  @override
  Future<void> stopPolling() async {
    try {
      _logger.info('Parando polling services...');

      _channelTimer?.cancel();
      _scoreTimer?.cancel();
      _watchdogTimer?.cancel();
      _backgroundWatcherTimer?.cancel();

      _channelTimer = null;
      _scoreTimer = null;
      _watchdogTimer = null;
      _backgroundWatcherTimer = null;

      _healthController.add(false);
      _logger.info('Polling services parados');
    } catch (e, s) {
      _logger.error('Erro ao parar polling services', e, s);
    }
  }

  @override
  Future<void> checkAndUpdateChannel() async {
    try {
      final result = await _homeService.fetchCurrentChannel();
      if (result != null) {
        if (result != _currentChannel) {
          _currentChannel = result;
          _channelController.add(result ?? '');
          _logger.info('Canal atualizado: $result');
        }
        _lastChannelUpdate = DateTime.now();
      }
    } catch (e, s) {
      _logger.error('Erro ao verificar canal', e, s);
    }
  }

  @override
  Future<void> checkAndUpdateScore(int streamerId) async {
    try {
      final result = await _homeService.saveScore(
        streamerId,
        DateTime.now(),
        DateTime.now().hour,
        DateTime.now().minute,
        100,
      );
      
      // Score atualizado com sucesso
      _lastScoreUpdate = DateTime.now();
      _scoreErrorCount = 0; // Reset error count on success
    } catch (e, s) {
      _scoreErrorCount++;
      _logger.error(
          'Erro ao atualizar score (tentativa $_scoreErrorCount)', e, s);
    }
  }

  void _verifyCorrectChannel() {
    if (_currentChannel != null && !_currentChannel!.startsWith(_baseChannel)) {
      _logger.warning('Canal incorreto detectado: $_currentChannel');
      checkAndUpdateChannel();
    }
  }

  @override
  bool isPollingActive() {
    return _channelTimer?.isActive == true && _scoreTimer?.isActive == true;
  }

  @override
  void dispose() {
    stopPolling();
    _healthController.close();
    _channelController.close();
  }
}
