import 'package:mobx/mobx.dart';
import '../../../../core/exceptions/failure.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../core/ui/widgets/messages.dart';
import '../../../../service/home/home_service.dart';

part 'home_controller.g.dart';

class HomeController = HomeControllerBase with _$HomeController;

abstract class HomeControllerBase with Store {
  final HomeService _homeService;
  final AppLogger _logger;

  HomeControllerBase({
    required HomeService homeService,
    required AppLogger logger,
  })  : _homeService = homeService,
        _logger = logger;

  @action
  Future<void> loadSchedules() async {
    try {
      await _homeService.fetchSchedules();
    } catch (e, s) {
      _logger.error('Error on load schedules', e, s);
      Messages.warning('Erro ao carregar os agendamentos');
      throw Failure(message: 'Erro ao carregar os agendamentos');
    }
  }

  @action
  Future<void> updateLists() async {
    try {
      await _homeService.forceUpdateLive();
    } catch (e, s) {
      _logger.error('Error on force update live', e, s);
      Messages.warning('Erro ao forçar a atualização da live');
      throw Failure(message: 'Erro ao forçar a atualização da live');
    }
  }
}
