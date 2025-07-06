import '../../../../core/logger/app_logger.dart';
import '../../../../utils/utils.dart';
import '../../domain/repositories/polling_repository.dart';
import '../datasources/polling_datasource.dart';

class PollingRepositoryImpl implements PollingRepository {
  final PollingDataSource _dataSource;
  final AppLogger _logger;

  PollingRepositoryImpl({
    required PollingDataSource dataSource,
    required AppLogger logger,
  })  : _dataSource = dataSource,
        _logger = logger;

  @override
  Future<Result<void>> startPolling(int streamerId) async {
    try {
      _logger.info('Iniciando polling via repository');
      return await _dataSource.startPolling(streamerId);
    } catch (e, s) {
      _logger.error('Erro inesperado ao iniciar polling', e, s);
      return Result.error(e as Exception);
    }
  }

  @override
  Future<Result<void>> stopPolling() async {
    try {
      _logger.info('Parando polling via repository');
      return await _dataSource.stopPolling();
    } catch (e, s) {
      _logger.error('Erro inesperado ao parar polling', e, s);
      return Result.error(e as Exception);
    }
  }

  @override
  Future<Result<void>> checkAndUpdateChannel() async {
    try {
      _logger.info('Verificando canal via repository');
      return await _dataSource.checkAndUpdateChannel();
    } catch (e, s) {
      _logger.error('Erro inesperado ao verificar canal', e, s);
      return Result.error(e as Exception);
    }
  }

  @override
  Future<Result<void>> checkAndUpdateScore(int streamerId) async {
    try {
      _logger.info('Verificando score via repository');
      return await _dataSource.checkAndUpdateScore(streamerId);
    } catch (e, s) {
      _logger.error('Erro inesperado ao verificar score', e, s);
      return Result.error(e as Exception);
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
