import '../../core/exceptions/failure.dart';
import '../../core/logger/app_logger.dart';
import '../../core/ui/widgets/messages.dart';
import '../../repositories/home/home_repository.dart';
import 'home_service.dart';

class HomeServiceImpl implements HomeService {
  final HomeRepository _homeRepository;
  final AppLogger _logger;

  HomeServiceImpl({
    required HomeRepository homeRepository,
    required AppLogger logger,
  })  : _homeRepository = homeRepository,
        _logger = logger;

  @override
  Future<void> fetchSchedules() async {
    try {
      // final schedules = await _homeRepository.loadSchedules(selectedDate);

      // for (var schedule in schedules) {
      //   final index = int.parse(schedule['id'].toString()) - 1;
      //   controllers[index].text = schedule['streamerUrl'];
      // }
    } catch (e, s) {
      _logger.error('Error on load schedules', e, s);
      Messages.warning('Erro ao carregar os agendamentos');
      throw Failure(message: 'Erro ao carregar os agendamentos');
    }
  }

  @override
  Future<void> forceUpdateLive() async {
    try {
      await _homeRepository.forceUpdateLive();
      Messages.success('Live atualizada com sucesso');
    } catch (e, s) {
      _logger.error('Error on force update live', e, s);
      Messages.warning('Erro ao forçar a atualização da live');
      throw Failure(message: 'Erro ao forçar a atualização da live');
    }
  }
}
