import '../../../../core/logger/app_logger.dart';
import '../../domain/repositories/polling_repository.dart';
import '../../domain/datasources/polling_datasource.dart';
import '../../../../core/result/result.dart';

class PollingRepositoryImpl implements PollingRepository {
  PollingRepositoryImpl({
    required PollingDataSource dataSource,
    required AppLogger logger,
  })  : _dataSource = dataSource,
        _logger = logger;
  final PollingDataSource _dataSource;
  final AppLogger _logger;

  @override
  Future<AppResult<AppUnit>> startPolling(int streamerId) async {
    try {
      _logger.info('Iniciando polling via repository');
      await _dataSource.startPolling(streamerId);
      return AppSuccess(appUnit);
    } catch (e, s) {
      _logger.error('Erro inesperado ao iniciar polling', e, s);
      return AppFailure(Exception('Erro ao iniciar polling: $e'));
    }
  }

  @override
  Future<AppResult<AppUnit>> stopPolling() async {
    try {
      _logger.info('Parando polling via repository');
      await _dataSource.stopPolling();
      return AppSuccess(appUnit);
    } catch (e, s) {
      _logger.error('Erro inesperado ao parar polling', e, s);
      return AppFailure(Exception('Erro ao parar polling: $e'));
    }
  }

  @override
  Future<AppResult<AppUnit>> checkAndUpdateChannel() async {
    try {
      _logger.info('Verificando canal via repository');
      await _dataSource.checkAndUpdateChannel();
      return AppSuccess(appUnit);
    } catch (e, s) {
      _logger.error('Erro inesperado ao verificar canal', e, s);
      return AppFailure(Exception('Erro ao verificar canal: $e'));
    }
  }

  @override
  Future<AppResult<AppUnit>> checkAndUpdateScore(int streamerId) async {
    try {
      _logger.info('Verificando score via repository');
      await _dataSource.checkAndUpdateScore(streamerId);
      return AppSuccess(appUnit);
    } catch (e, s) {
      _logger.error('Erro inesperado ao verificar score', e, s);
      return AppFailure(Exception('Erro ao verificar score: $e'));
    }
  }

  @override
  Stream<bool> get healthStatus => _dataSource.healthStatus;

  @override
  Stream<String> get channelUpdates => _dataSource.channelUpdates;

  @override
  bool isPollingActive() => _dataSource.isPollingActive();

  @override
  void dispose() => _dataSource.dispose();
}
