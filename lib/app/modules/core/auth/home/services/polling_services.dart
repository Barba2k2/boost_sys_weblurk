import 'dart:async';

import '../../../../../core/logger/app_logger.dart';
import '../../../../../service/home/home_service.dart';

abstract class PollingService {
  Future<void> startPolling(int streamerId);
  Future<void> stopPolling();
  Future<void> checkAndUpdateChannel();
  Future<void> checkAndUpdateScore(int streamerId);
}

class PollingServiceImpl implements PollingService {
  final HomeService _homeService;
  final AppLogger _logger;
  Timer? _channelTimer;
  Timer? _scoreTimer;
  Timer? _watchdogTimer;
  DateTime? _lastChannelUpdate;
  DateTime? _lastScoreUpdate;

  static const _pollingInterval = Duration(minutes: 80);
  static const _channelCheckInterval = Duration(minutes: 6);
  static const _watchdogInterval = Duration(minutes: 5);
  static const _maxTimeSinceLastUpdate = Duration(minutes: 10);

  PollingServiceImpl({
    required HomeService homeService,
    required AppLogger logger,
  })  : _homeService = homeService,
        _logger = logger;

  @override
  Future<void> startPolling(int streamerId) async {
    _logger.info('Iniciando polling services... ${DateTime.now()}');

    try {
      _startTimers(streamerId);

      _startWatchdog(streamerId);

      _logger.info('Polling services iniciados com sucesso ${DateTime.now()}');
    } catch (e, s) {
      _logger.error('Erro ao iniciar polling services ${DateTime.now()}', e, s);
      stopPolling();
      rethrow;
    }
  }

  void _startTimers(int streamerId) {
    _channelTimer?.cancel();
    _scoreTimer?.cancel();

    checkAndUpdateChannel();
    checkAndUpdateScore(streamerId);

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
      _logger.info('Watchdog: Verificando se o polling deve ser reiniciado... ${DateTime.now()}');
      _checkAndRestartIfNeeded(streamerId);
    });
  }

  void _checkAndRestartIfNeeded(int streamerId) {
    final now = DateTime.now();

    if (_lastChannelUpdate != null &&
        now.difference(_lastChannelUpdate!) > _maxTimeSinceLastUpdate) {
      _logger.warning('Watchdog: Channel updates stopped, restarting polling... ${DateTime.now()}');
      _startTimers(streamerId);
    }

    if (_lastScoreUpdate != null && now.difference(_lastScoreUpdate!) > _maxTimeSinceLastUpdate) {
      _logger.warning('Watchdog: Score updates stopped, restarting polling... ${DateTime.now()}');
      _startTimers(streamerId);
    }
  }

  @override
  Future<void> checkAndUpdateChannel() async {
    try {
      await _homeService.fetchCurrentChannel();
      _lastChannelUpdate = DateTime.now();
      _logger.info('Canal verificado e atualizado com sucesso ${DateTime.now()}');
    } catch (e, s) {
      _logger.error('Erro ao verificar e atualizar canal ${DateTime.now()}', e, s);

      _lastChannelUpdate = DateTime.now();
    }
  }

  @override
  Future<void> checkAndUpdateScore(int streamerId) async {
    try {
      final now = DateTime.now();
      await _homeService.saveScore(
        streamerId,
        DateTime(now.year, now.month, now.day),
        now.hour,
        now.minute,
        1,
      );
      _lastScoreUpdate = now;
      _logger.info('Score atualizado com sucesso $now');
    } catch (e, s) {
      _logger.error('Erro ao atualizar score ${DateTime.now()}', e, s);

      _lastScoreUpdate = DateTime.now();
    }
  }

  @override
  Future<void> stopPolling() async {
    _channelTimer?.cancel();
    _scoreTimer?.cancel();
    _watchdogTimer?.cancel();
    _logger.info('Polling services parados ${DateTime.now()}');
  }

  bool isPollingActive() {
    return _channelTimer?.isActive == true &&
        _scoreTimer?.isActive == true &&
        _watchdogTimer?.isActive == true;
  }
}
