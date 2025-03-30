import '../../core/exceptions/failure.dart';
import '../../core/logger/app_logger.dart';
import '../../core/rest_client/rest_client.dart';
import 'schedule_repository.dart';

class ScheduleRepositoryImpl implements SchedulesRepository {
  ScheduleRepositoryImpl({
    required RestClient restClient,
    required AppLogger logger,
  })  : _restClient = restClient,
        _logger = logger;

  final RestClient _restClient;
  final AppLogger _logger;

  @override
  Future<List> fetchSchedule() async {
    try {
      final response = await _restClient.auth().get('/schedule/');

      if (response.statusCode == 200) {
        return response.data as List;
      } else {
        throw Failure(message: 'Erro ao buscar os agendamentos');
      }
    } catch (e, s) {
      _logger.error('Error on fetch schedule', e, s);
      throw Failure(message: 'Erro ao buscar os agendamentos');
    }
  }
}
