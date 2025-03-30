import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import '../../../../../core/logger/app_logger.dart';
import '../../../../../service/home/home_service.dart';

abstract class PollingService {
  Future<void> startPolling(int streamerId);
  Future<void> stopPolling();
  Future<void> checkAndUpdateChannel();
  Future<void> checkAndUpdateScore(int streamerId);
  Stream<bool> get healthStatus;
}

class PollingServiceImpl implements PollingService {
  PollingServiceImpl({
    required HomeService homeService,
    required AppLogger logger,
  })  : _homeService = homeService,
        _logger = logger {
    // Adicionar detecção de suspensão/retomada do sistema
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

  final _healthController = StreamController<bool>.broadcast();

  // Ajuste os intervalos conforme necessário
  static const _pollingInterval = Duration(minutes: 80);
  static const _channelCheckInterval = Duration(minutes: 6);
  static const _watchdogInterval = Duration(minutes: 2); // Reduzido para 2 minutos
  static const _maxTimeSinceLastUpdate = Duration(minutes: 15); // Aumentado para 15 minutos

  // Parâmetros de backoff para erros do servidor
  int _scoreErrorCount = 0;
  static const _maxBackoffMinutes = 30; // Tempo máximo de backoff em minutos
  static const _initialBackoffSeconds = 30;

  @override
  Stream<bool> get healthStatus => _healthController.stream;

  void _setupSystemLifecycleDetection() {
    // Uma abordagem simplificada com verificações periódicas de tempo
    Timer.periodic(const Duration(seconds: 30), (timer) {
      final now = DateTime.now();
      if (_lastSuspensionResume != null) {
        final diff = now.difference(_lastSuspensionResume!);
        // Se a última verificação foi há mais de 2 minutos, provavelmente o sistema estava suspenso
        if (diff.inMinutes > 2) {
          _logger.info('Possível retorno de suspensão do sistema detectado');
          _onSystemResume();
        }
      }
      _lastSuspensionResume = now;
    });
  }

  void _onSystemResume() {
    _logger.info('Sistema retomado de suspensão ${DateTime.now()}');
    // Forçar uma verificação imediata do canal atual
    _forceChannelCheck();
  }

  Future<void> _forceChannelCheck() async {
    try {
      await checkAndUpdateChannel();
      _logger.info('Verificação forçada de canal após retomada do sistema');
    } catch (e, s) {
      _logger.error('Erro na verificação forçada de canal', e, s);
    }
  }

  @override
  Future<void> startPolling(int streamerId) async {
    _logger.info('Iniciando polling services... ${DateTime.now()}');

    try {
      _startTimers(streamerId);
      _startWatchdog(streamerId);
      _healthController.add(true);

      // Iniciar verificador de background adicional
      _startBackgroundWatcher(streamerId);

      _logger.info('Polling services iniciados com sucesso ${DateTime.now()}');
    } catch (e, s) {
      _logger.error('Erro ao iniciar polling services ${DateTime.now()}', e, s);
      _healthController.add(false);
      stopPolling();
      rethrow;
    }
  }

  void _startBackgroundWatcher(int streamerId) {
    // Cancelar timer existente se houver
    _backgroundWatcherTimer?.cancel();

    // Criar novo timer para verificação periódica em background
    _backgroundWatcherTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      developer.log('Background watcher verificando saúde do polling');
      if (!isPollingActive()) {
        developer.log('Polling inativo detectado pelo background watcher, reiniciando...');
        _startTimers(streamerId);
      }
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

    _logger.info('Timers reiniciados: ${DateTime.now()}');
  }

  void _startWatchdog(int streamerId) {
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer.periodic(_watchdogInterval, (_) {
      _logger.info('Watchdog: Verificando polling... ${DateTime.now()}');
      _checkAndRestartIfNeeded(streamerId);
    });
  }

  void _checkAndRestartIfNeeded(int streamerId) {
    final now = DateTime.now();
    bool needsRestart = false;

    if (_lastChannelUpdate != null) {
      final channelUpdateDiff = now.difference(_lastChannelUpdate!);
      _logger.info('Última atualização de canal: ${channelUpdateDiff.inMinutes} minutos atrás');

      if (channelUpdateDiff > _maxTimeSinceLastUpdate) {
        _logger.warning('Watchdog: Atualizações de canal paradas, reiniciando polling... $now');
        needsRestart = true;
      }
    } else {
      _logger.warning('Watchdog: Nenhuma atualização de canal registrada, reiniciando...');
      needsRestart = true;
    }

    if (_lastScoreUpdate != null) {
      final scoreUpdateDiff = now.difference(_lastScoreUpdate!);
      _logger.info('Última atualização de score: ${scoreUpdateDiff.inMinutes} minutos atrás');

      if (scoreUpdateDiff > _maxTimeSinceLastUpdate) {
        _logger.warning('Watchdog: Atualizações de score paradas, reiniciando polling... $now');
        needsRestart = true;
      }
    } else {
      _logger.warning('Watchdog: Nenhuma atualização de score registrada, reiniciando...');
      needsRestart = true;
    }

    // Verificar se os timers ainda estão ativos
    if (_channelTimer == null ||
        !_channelTimer!.isActive ||
        _scoreTimer == null ||
        !_scoreTimer!.isActive) {
      _logger.warning('Watchdog: Timers inativos detectados, reiniciando... $now');
      needsRestart = true;
    }

    if (needsRestart) {
      _startTimers(streamerId);
      _healthController.add(false); // Notificar problema

      // Após reiniciar, notificar recuperação
      Timer(const Duration(seconds: 5), () {
        _healthController.add(true);
      });
    } else {
      _healthController.add(true);
    }
  }

  @override
  Future<void> checkAndUpdateChannel() async {
    try {
      final currentChannel = await _homeService.fetchCurrentChannel();
      _lastChannelUpdate = DateTime.now();
      _logger.info('Canal verificado: $currentChannel em $_lastChannelUpdate');
    } catch (e, s) {
      _logger.error('Erro ao verificar canal ${DateTime.now()}', e, s);
      // Ainda atualizamos o timestamp para evitar tentativas excessivas
      _lastChannelUpdate = DateTime.now();
    }
  }

  @override
  Future<void> checkAndUpdateScore(int streamerId) async {
    try {
      // Se tivermos muitos erros recentes, aplicamos backoff exponencial
      if (_scoreErrorCount > 0) {
        final backoffTime = _calculateBackoffTime(_scoreErrorCount);
        _logger.warning(
          'Backoff aplicado após erros: esperando ${backoffTime.inSeconds} segundos antes de tentar novamente',
        );
        await Future.delayed(backoffTime);
      }

      final now = DateTime.now();
      await _homeService.saveScore(
        streamerId,
        DateTime(now.year, now.month, now.day),
        now.hour,
        now.minute,
        1,
      );

      // Sucesso - resetamos o contador de erros
      _scoreErrorCount = 0;
      _lastScoreUpdate = now;
      _logger.info('Score atualizado com sucesso $now');
    } catch (e, s) {
      // Incrementa o contador de erros para backoff exponencial
      _scoreErrorCount++;

      if (e.toString().contains('500') || e.toString().contains('Internal Server Error')) {
        _logger.warning(
          'Erro 500 do servidor ao atualizar score. Erro #$_scoreErrorCount. ${DateTime.now()}',
        );
      } else {
        _logger.error('Erro ao atualizar score ${DateTime.now()}', e, s);
      }

      // Ainda atualizamos o timestamp para evitar tentativas excessivas do watchdog
      _lastScoreUpdate = DateTime.now();
    }
  }

  Duration _calculateBackoffTime(int errorCount) {
    // Backoff exponencial com jitter
    // Formula: min(maxBackoff, initialBackoff * 2^(errorCount-1)) + random jitter
    final maxBackoffSeconds = _maxBackoffMinutes * 60;
    final baseSeconds =
        min(maxBackoffSeconds, _initialBackoffSeconds * pow(2, errorCount - 1).toInt());

    // Adiciona até 25% de jitter para evitar "tempestade de reconexão"
    final jitterSeconds = (baseSeconds * 0.25 * Random().nextDouble()).toInt();

    return Duration(seconds: baseSeconds + jitterSeconds);
  }

  @override
  Future<void> stopPolling() async {
    _channelTimer?.cancel();
    _scoreTimer?.cancel();
    _watchdogTimer?.cancel();
    _backgroundWatcherTimer?.cancel();
    _logger.info('Polling services parados ${DateTime.now()}');
  }

  bool isPollingActive() {
    return _channelTimer?.isActive == true &&
        _scoreTimer?.isActive == true &&
        _watchdogTimer?.isActive == true;
  }

  void dispose() {
    stopPolling();
    _healthController.close();
  }
}
