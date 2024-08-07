import '../../core/exceptions/failure.dart';
import '../../core/logger/app_logger.dart';
import '../../core/rest_client/rest_client.dart';
import 'schedule_repository.dart';

class ScheduleRepositoryImpl implements SchedulesRepository {
  final RestClient _restClient;
  final AppLogger _logger;

  ScheduleRepositoryImpl({
    required RestClient restClient,
    required AppLogger logger,
  })  : _restClient = restClient,
        _logger = logger;

  @override
  Future<void> fetchSchedule() async {
    try {
      final response = await _restClient.auth().get('/schedule/');

      _logger.info('Response data ${response.data}');

      if (response.statusCode == 200) {
        throw Failure(message: 'Erro ao buscar os agendamentos');
      }
    } catch (e, s) {
      _logger.error('Error on fetch schedule', e, s);
      throw Failure(message: 'Erro ao buscar os agendamentos');
    }
  }
}
