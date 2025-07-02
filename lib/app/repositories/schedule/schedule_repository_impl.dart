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
      // Busca ambas as listas A e B
      final responseListA = await _restClient.auth().get('/list-a/');
      final responseListB = await _restClient.auth().get('/list-b/');

      final List<dynamic> allSchedules = [];

      if (responseListA.statusCode == 200) {
        final dataA = responseListA.data;
        if (dataA is Map<String, dynamic> && dataA['schedules'] != null) {
          allSchedules.addAll(dataA['schedules'] as List);
        }
      }

      if (responseListB.statusCode == 200) {
        final dataB = responseListB.data;
        if (dataB is Map<String, dynamic> && dataB['schedules'] != null) {
          allSchedules.addAll(dataB['schedules'] as List);
        }
      }

      return allSchedules;
    } catch (e, s) {
      _logger.error('Error on fetch schedule', e, s);
      throw Failure(message: 'Erro ao buscar os agendamentos');
    }
  }
}
