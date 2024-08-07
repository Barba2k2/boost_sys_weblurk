import '../../core/exceptions/failure.dart';
import '../../core/logger/app_logger.dart';
import '../../models/user_model.dart';
import '../../repositories/schedule/schedule_repository.dart';
import 'schedule_service.dart';

class StreamerServiceImpl implements ScheduleService {
  final SchedulesRepository _streamerRepository;
  final AppLogger _logger;

  StreamerServiceImpl({
    required AppLogger logger,
    required SchedulesRepository streamerRepository,
  })  : _logger = logger,
        _streamerRepository = streamerRepository;

  @override
  Future<List> fetchSchedule(String token) {
    // TODO: implement fetchSchedule
    throw UnimplementedError();
  }
}
