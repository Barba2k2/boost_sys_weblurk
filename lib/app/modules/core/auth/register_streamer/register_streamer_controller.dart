import 'package:mobx/mobx.dart';

import '../../../../core/exceptions/failure.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../service/schedule/schedule_service.dart';

part 'register_streamer_controller.g.dart';

class RegisterStreamerController = RegisterStreamerControllerBase
    with _$RegisterStreamerController;

abstract class RegisterStreamerControllerBase with Store {
  final ScheduleService _scheduleService;
  final AppLogger _logger;

  RegisterStreamerControllerBase({
    required ScheduleService scheduleService,
    required AppLogger logger,
  })  : _scheduleService = scheduleService,
        _logger = logger;

  // @observable
  // List? users = [];

  @observable
  String? errorMessage;

  @observable
  bool isLoading = false;

  @action
  Future<void> fetchUsers() async {
    try {
      isLoading = true;

      errorMessage = null;

      await _scheduleService.fetchSchedule();
    } catch (e, s) {
      _logger.error('Controller - Error fetching users', e, s);

      if (e is Failure) {
        errorMessage = e.message;
      } else {
        errorMessage = 'Erro ao buscar os usuários';
      }
    } finally {
      isLoading = false;
    }
  }
}
