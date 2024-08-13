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
      await _homeRepository.loadSchedules(DateTime.now());
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
      Messages.success('Lista atualizada com sucesso');
    } catch (e, s) {
      _logger.error('Error on force update live', e, s);
      Messages.warning('Erro ao forçar a atualização da live');
      throw Failure(message: 'Erro ao forçar a atualização da live');
    }
  }

  @override
  Future<void> updateLists() async => await fetchSchedules();
  
  @override
  Future<String?> fetchCurrentChannel() async {
    try {
    final response = await _homeRepository.getCurrentChannel();

    return response;
  } catch (e, s) {
    _logger.error('Error fetching current channel URL', e, s);
    throw Failure(message: 'Erro ao buscar a URL do canal atual');
  }
  }
}
