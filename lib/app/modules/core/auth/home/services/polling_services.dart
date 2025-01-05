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

  static const _pollingInterval = Duration(minutes: 6);

  PollingServiceImpl({
    required HomeService homeService,
    required AppLogger logger,
  })  : _homeService = homeService,
        _logger = logger;

  @override
  Future<void> startPolling(int streamerId) async {
    _logger.info('Iniciando polling services...');

    try {
      await checkAndUpdateChannel();
      await checkAndUpdateScore(streamerId);

      _channelTimer?.cancel();
      _scoreTimer?.cancel();

      _channelTimer = Timer.periodic(
        _pollingInterval,
        (_) => checkAndUpdateChannel(),
      );
      _scoreTimer = Timer.periodic(
        _pollingInterval,
        (_) => checkAndUpdateScore(streamerId),
      );

      _logger.info('Polling services iniciados com sucesso');
    } catch (e, s) {
      _logger.error('Erro ao iniciar polling services', e, s);
      stopPolling();
      rethrow;
    }
  }

  @override
  Future<void> stopPolling() async {
    _channelTimer?.cancel();
    _scoreTimer?.cancel();
    _logger.info('Polling services parados');
  }

  @override
  Future<void> checkAndUpdateChannel() async {
    try {
      await _homeService.fetchCurrentChannel();
      _logger.info('Canal verificado e atualizado com sucesso');
    } catch (e, s) {
      _logger.error('Erro ao verificar e atualizar canal', e, s);
      rethrow;
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
      _logger.info('Score atualizado com sucesso');
    } catch (e, s) {
      _logger.error('Erro ao atualizar score', e, s);
      rethrow;
    }
  }
}
