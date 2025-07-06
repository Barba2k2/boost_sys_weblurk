import '../../../../core/logger/app_logger.dart';
import '../../../../core/rest_client/rest_client.dart';
import '../../../../utils/utils.dart';

abstract class HomeDataSource {
  Future<Result<void>> initializeHome();
  Future<Result<void>> startPolling();
  Future<Result<void>> stopPolling();
}

class HomeDataSourceImpl implements HomeDataSource {
  final RestClient _restClient;
  final AppLogger _logger;

  HomeDataSourceImpl({
    required RestClient restClient,
    required AppLogger logger,
  })  : _restClient = restClient,
        _logger = logger;

  @override
  Future<Result<void>> initializeHome() async {
    try {
      _logger.info('Inicializando home via datasource');

      // Verificar se há dados necessários para inicializar
      final response = await _restClient.get('/home/status');

      if (response.statusCode == 200) {
        _logger.info('Home inicializada com sucesso');
        return Result.ok(null);
      } else {
        _logger.error('Falha ao inicializar home: ${response.statusCode}');
        return Result.error(Exception('Falha ao inicializar home'));
      }
    } catch (e, s) {
      _logger.error('Erro na inicialização da home', e, s);
      return Result.error(e as Exception);
    }
  }

  @override
  Future<Result<void>> startPolling() async {
    try {
      _logger.info('Iniciando polling via datasource');

      // TODO: Implementar polling real
      await Future.delayed(const Duration(milliseconds: 100));

      _logger.info('Polling iniciado com sucesso');
      return Result.ok(null);
    } catch (e, s) {
      _logger.error('Erro ao iniciar polling', e, s);
      return Result.error(e as Exception);
    }
  }

  @override
  Future<Result<void>> stopPolling() async {
    try {
      _logger.info('Parando polling via datasource');

      // TODO: Implementar parada do polling real
      await Future.delayed(const Duration(milliseconds: 100));

      _logger.info('Polling parado com sucesso');
      return Result.ok(null);
    } catch (e, s) {
      _logger.error('Erro ao parar polling', e, s);
      return Result.error(e as Exception);
    }
  }
}
