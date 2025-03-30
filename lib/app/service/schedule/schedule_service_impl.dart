import '../../core/exceptions/failure.dart';
import '../../core/logger/app_logger.dart';
import '../../repositories/schedule/schedule_repository.dart';
import 'schedule_service.dart';

class StreamerServiceImpl implements ScheduleService {
  StreamerServiceImpl({
    required AppLogger logger,
    required SchedulesRepository streamerRepository,
  })  : _logger = logger,
        _streamerRepository = streamerRepository;

  final SchedulesRepository _streamerRepository;
  final AppLogger _logger;

  @override
  Future<List> fetchSchedule() async {
    try {
      final schedules = await _streamerRepository.fetchSchedule();
      return schedules;
    } catch (e, s) {
      _logger.error('Error on fetch schedule', e, s);
      throw Failure(message: 'Erro ao buscar os agendamentos');
    }
  }
}
