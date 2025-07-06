import '../../../../core/logger/app_logger.dart';
import '../../../../utils/utils.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeDataSource _dataSource;
  final AppLogger _logger;

  HomeRepositoryImpl({
    required HomeDataSource dataSource,
    required AppLogger logger,
  })  : _dataSource = dataSource,
        _logger = logger;

  @override
  Future<Result<void>> initializeHome() async {
    try {
      _logger.info('Inicializando home');

      final result = await _dataSource.initializeHome();

      if (result.isSuccess) {
        _logger.info('Home inicializada com sucesso');
        return Result.ok(null);
      } else {
        _logger.error('Falha ao inicializar home: ${result.asErrorValue}');
        return Result.error(result.asErrorValue);
      }
    } catch (e, s) {
      _logger.error('Erro inesperado ao inicializar home', e, s);
      return Result.error(e as Exception);
    }
  }

  @override
  Future<Result<void>> startPolling() async {
    try {
      _logger.info('Iniciando polling');

      final result = await _dataSource.startPolling();

      if (result.isSuccess) {
        _logger.info('Polling iniciado com sucesso');
        return Result.ok(null);
      } else {
        _logger.error('Falha ao iniciar polling: ${result.asErrorValue}');
        return Result.error(result.asErrorValue);
      }
    } catch (e, s) {
      _logger.error('Erro inesperado ao iniciar polling', e, s);
      return Result.error(e as Exception);
    }
  }

  @override
  Future<Result<void>> stopPolling() async {
    try {
      _logger.info('Parando polling');

      final result = await _dataSource.stopPolling();

      if (result.isSuccess) {
        _logger.info('Polling parado com sucesso');
        return Result.ok(null);
      } else {
        _logger.error('Falha ao parar polling: ${result.asErrorValue}');
        return Result.error(result.asErrorValue);
      }
    } catch (e, s) {
      _logger.error('Erro inesperado ao parar polling', e, s);
      return Result.error(e as Exception);
    }
  }
}
