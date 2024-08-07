import '../../core/exceptions/failure.dart';
import '../../core/logger/app_logger.dart';
import '../../core/rest_client/rest_client.dart';
import '../../core/rest_client/rest_client_exception.dart';
import './home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final RestClient _restClient;
  final AppLogger _logger;

  HomeRepositoryImpl({
    required RestClient restClient,
    required AppLogger logger,
  })  : _restClient = restClient,
        _logger = logger;

  @override
  Future<List<Map<String, dynamic>>> loadSchedules(DateTime date) async {
    try {
      final todayDate = DateTime.now();

      final response = await _restClient.auth().get(
            '/schedules/get?date=$todayDate',
          );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Failure(message: 'Erro ao carregar os agendamentos');
      }
    } on RestClientException catch (e, s) {
      _logger.error('Error on load schedules', e, s);
      throw Failure(message: 'Erro do RestClient ao carregar o agendamento');
    } catch (e, s) {
      _logger.error('Error on load schedules', e, s);
      throw Failure(message: 'Erro genérico ao carregar o agendamento');
    }
  }

  @override
  Future<void> forceUpdateLive() async {
    try {
      final response = await _restClient.auth().post('/schedules/update');

      if (response.statusCode == 200) {
        return;
      } else {
        throw Failure(message: 'Erro ao forçar a atualização da live');
      }
    } on RestClientException catch (e, s) {
      _logger.error('Error on force update live', e, s);
      throw Failure(
        message: 'Erro do RestClient ao forçar a atualização da live',
      );
    } catch (e, s) {
      _logger.error('Error forcing live update', e, s);
      throw Failure(message: 'Erro genérico ao forçar a atualização da live');
    }
  }
}
