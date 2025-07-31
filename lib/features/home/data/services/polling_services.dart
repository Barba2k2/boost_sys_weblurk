import 'dart:async';
import 'dart:math';

import '../../../../core/logger/app_logger.dart';
import '../../../../core/utils/url_validator.dart';
import '../../../../service/home/home_service.dart';

abstract class PollingService {
  Future<void> startPolling(int streamerId);
  Future<void> stopPolling();
  Future<void> checkAndUpdateChannel();
  Future<void> checkAndUpdateScore(int streamerId);
  Stream<bool> get healthStatus;
  Stream<String> get channelUpdates;
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

  String? _currentChannel;
  final String _baseChannel = 'https://twitch.tv/BoostTeam_';

  final _healthController = StreamController<bool>.broadcast();
  final _channelController = StreamController<String>.broadcast();

  static const _pollingInterval = Duration(minutes: 6);
  static const _channelCheckInterval = Duration(minutes: 6);
  static const _watchdogInterval = Duration(minutes: 2);
  static const _maxTimeSinceLastUpdate = Duration(minutes: 15);

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
      // Forçar verificação imediata do canal correto
      await checkAndUpdateChannel();

      // Aguardar um pouco para garantir que o canal foi atualizado
      await Future.delayed(const Duration(milliseconds: 500));

      _startTimers(streamerId);
      _startWatchdog(streamerId);
      _healthController.add(true);

      _startBackgroundWatcher(streamerId);
    } catch (e, s) {
      _logger.error('Erro ao iniciar polling services ${DateTime.now()}', e, s);
      _healthController.add(false);
      stopPolling();
      rethrow;
    }
  }

  void _startBackgroundWatcher(int streamerId) {
    _backgroundWatcherTimer?.cancel();

    _backgroundWatcherTimer =
        Timer.periodic(const Duration(minutes: 10), (timer) {
      if (!isPollingActive()) {
        _logger.warning(
          'Background watcher detectou polling inativo, reiniciando timers',
        );
        _startTimers(streamerId);
      }

      _verifyCorrectChannel();
    });
  }

  void _startTimers(int streamerId) {
    _channelTimer?.cancel();
    _scoreTimer?.cancel();

    checkAndUpdateChannel();
    checkAndUpdateScore(streamerId);

    _channelTimer = Timer.periodic(
      _channelCheckInterval,
      (_) {
        checkAndUpdateChannel();
      },
    );

    _scoreTimer = Timer.periodic(
      _pollingInterval,
      (_) {
        checkAndUpdateScore(streamerId);
      },
    );
  }

  void _startWatchdog(int streamerId) {
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer.periodic(_watchdogInterval, (_) {
      _logger.debug('Executando verificação do watchdog');
      _checkAndRestartIfNeeded(streamerId);
    });
  }

  void _checkAndRestartIfNeeded(int streamerId) {
    final now = DateTime.now();
    bool needsRestart = false;

    if (_lastChannelUpdate != null) {
      final channelUpdateDiff = now.difference(_lastChannelUpdate!);

      if (channelUpdateDiff > _maxTimeSinceLastUpdate) {
        _logger.warning(
          'Watchdog: Atualizações de canal paradas há ${channelUpdateDiff.inMinutes} minutos, reiniciando polling... $now',
        );
        needsRestart = true;
      }
    } else {
      _logger.warning(
        'Watchdog: Nenhuma atualização de canal registrada, reiniciando...',
      );
      needsRestart = true;
    }

    if (_lastScoreUpdate != null) {
      final scoreUpdateDiff = now.difference(_lastScoreUpdate!);

      if (scoreUpdateDiff > _maxTimeSinceLastUpdate) {
        _logger.warning(
          'Watchdog: Atualizações de score paradas há ${scoreUpdateDiff.inMinutes} minutos, reiniciando polling... $now',
        );
        needsRestart = true;
      }
    } else {
      _logger.warning(
        'Watchdog: Nenhuma atualização de score registrada, reiniciando...',
      );
      needsRestart = true;
    }

    if (_channelTimer == null ||
        !_channelTimer!.isActive ||
        _scoreTimer == null ||
        !_scoreTimer!.isActive) {
      _logger.warning(
        'Watchdog: Timers inativos detectados, reiniciando... $now',
      );
      needsRestart = true;
    }

    if (needsRestart) {
      _startTimers(streamerId);
      _healthController.add(false);

      Timer(const Duration(seconds: 5), () {
        _healthController.add(true);
      });
    } else {
      _healthController.add(true);
    }

    _verifyCorrectChannel();
  }

  Future<void> _verifyCorrectChannel() async {
    try {
      final correctChannel = await _homeService.fetchCurrentChannel();
      final channelToShow = correctChannel ?? _baseChannel;

      if (_currentChannel != channelToShow) {
        _logger.warning(
          'Canal incorreto detectado! Atual: $_currentChannel, Correto: $channelToShow',
        );

        _channelController.add(channelToShow);
        _currentChannel = channelToShow;
      }
    } catch (e) {
      _logger.error('Erro ao verificar canal correto: $e');
    }
  }

  @override
  Future<void> checkAndUpdateChannel() async {
    try {
      final correctChannel = await _homeService.fetchCurrentChannel();

      final channelToShow = correctChannel ?? _baseChannel;

      final validatedUrl = UrlValidator.validateAndSanitizeUrl(channelToShow);
      if (validatedUrl == null) {
        _logger.error(
          'URL de canal inválida ou maliciosa detectada: $channelToShow',
        );
        return;
      }

      if (_currentChannel != validatedUrl) {
        _channelController.add(validatedUrl);
        _currentChannel = validatedUrl;
        _lastChannelUpdate = DateTime.now();
        _healthController.add(true);
      }
    } catch (e, s) {
      _logger.error('Erro ao verificar canal correto', e, s);
      _healthController.add(false);
    }
  }

  @override
  Future<void> checkAndUpdateScore(int streamerId) async {
    try {
      if (_scoreErrorCount > 0) {
        final backoffTime = _calculateBackoffTime(_scoreErrorCount);
        _logger.warning(
          'Backoff aplicado após $_scoreErrorCount erros: esperando ${backoffTime.inSeconds} segundos antes de tentar novamente',
        );
        await Future.delayed(backoffTime);
      }

      final now = DateTime.now();

      if (_lastScoreUpdate != null) {
        final timeDiff = now.difference(_lastScoreUpdate!);
        if (timeDiff.inMinutes < 5) {
          _logger.debug(
              'Score atualizado recentemente (${timeDiff.inMinutes} minutos atrás), pulando atualização');
          return;
        }
      }

      _logger.debug('Atualizando score para streamerId: $streamerId');
      await _homeService.saveScore(
        streamerId,
        DateTime(now.year, now.month, now.day),
        now.hour,
        now.minute,
        1,
      );

      _scoreErrorCount = 0;
      _lastScoreUpdate = now;
    } catch (e, s) {
      _scoreErrorCount++;

      if (e.toString().contains('500') ||
          e.toString().contains('Internal Server Error')) {
        _logger.warning(
          'Erro 500 do servidor ao atualizar score. Erro #$_scoreErrorCount. ${DateTime.now()}',
        );
      } else {
        _logger.error('Erro ao atualizar score ${DateTime.now()}', e, s);
      }

      _lastScoreUpdate = DateTime.now();
    }
  }

  Duration _calculateBackoffTime(int errorCount) {
    final maxBackoffSeconds = _maxBackoffMinutes * 60;
    final baseSeconds = min(
      maxBackoffSeconds,
      _initialBackoffSeconds * pow(2, errorCount - 1).toInt(),
    );

    final jitterSeconds = (baseSeconds * 0.25 * Random().nextDouble()).toInt();

    return Duration(seconds: baseSeconds + jitterSeconds);
  }

  @override
  Future<void> stopPolling() async {
    _channelTimer?.cancel();
    _scoreTimer?.cancel();
    _watchdogTimer?.cancel();
    _backgroundWatcherTimer?.cancel();
  }

  bool isPollingActive() {
    final isActive = _channelTimer?.isActive == true &&
        _scoreTimer?.isActive == true &&
        _watchdogTimer?.isActive == true;

    return isActive;
  }

  void dispose() {
    stopPolling();
    _healthController.close();
    _channelController.close();
  }
}
