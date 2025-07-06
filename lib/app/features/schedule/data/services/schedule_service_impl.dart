import '../../../../core/logger/app_logger.dart';
import '../../../../core/rest_client/rest_client.dart';
import '../../domain/services/schedule_service.dart';

class ScheduleServiceImpl implements ScheduleService {
  ScheduleServiceImpl({
    required RestClient restClient,
    required AppLogger logger,
  })  : _restClient = restClient,
        _logger = logger;

  final RestClient _restClient;
  final AppLogger _logger;

  @override
  Future<List<dynamic>> getSchedules() async {
    _logger.info('Buscando schedules');
    final response = await _restClient.get('/schedules');
    return response.data as List<dynamic>;
  }

  @override
  Future<void> updateSchedule(dynamic schedule) async {
    _logger.info('Atualizando schedule: ${schedule['id']}');
    await _restClient.put('/schedules/${schedule['id']}', data: schedule);
  }

  @override
  Future<void> deleteSchedule(int id) async {
    _logger.info('Deletando schedule: $id');
    await _restClient.delete('/schedules/$id');
  }
} 