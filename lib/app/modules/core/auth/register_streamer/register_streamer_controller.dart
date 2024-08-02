import 'package:mobx/mobx.dart';

import '../../../../core/exceptions/failure.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../core/ui/widgets/messages.dart';
import '../../../../models/user_model.dart';
import '../../../../service/streamer/streamer_service.dart';

part 'register_streamer_controller.g.dart';

class RegisterStreamerController = RegisterStreamerControllerBase
    with _$RegisterStreamerController;

abstract class RegisterStreamerControllerBase with Store {
  final StreamerService _streamerService;
  final AppLogger _logger;

  RegisterStreamerControllerBase({
    required StreamerService streamerService,
    required AppLogger logger,
  })  : _streamerService = streamerService,
        _logger = logger;

  @observable
  List<UserModel>? users = [];

  @observable
  String? errorMessage;

  @observable
  bool isLoading = false;

  @action
  Future<void> fetchUsers() async {
    try {
      isLoading = true;

      errorMessage = null;

      users = await _streamerService.fetchUsers();
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

  @action
  Future<void> registerUser(
    String nickname,
    String password,
    String role,
  ) async {
    try {
      isLoading = true;

      errorMessage = null;

      await _streamerService.registerUser(nickname, password, role);

      Messages.success('Streamer registrado com sucesso!');

      await fetchUsers();
    } catch (e) {
      _logger.error('Controller - Error registering user', e);
      if (e is Failure) {
        errorMessage = e.message;
      } else {
        errorMessage = 'Erro ao registrar o usuário';
      }
      Messages.warning(errorMessage!);
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> deleteUser(int id) async {
    try {
      isLoading = true;

      errorMessage = null;

      await _streamerService.deleteUser(id);

      Messages.success('Streamer deletado com sucesso!');

      await fetchUsers();
    } catch (e, s) {
      _logger.error('Controller - Error deleting user', e, s);
      if (e is Failure) {
        errorMessage = e.message;
      } else {
        errorMessage = 'Erro ao deletar o usuário';
      }
      Messages.warning(errorMessage!);
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> editUser(
    int id,
    String nickname,
    String password,
    String role,
  ) async {
    try {
      isLoading = true;

      errorMessage = null;

      await _streamerService.editUser(
        id,
        nickname,
        password,
        role,
      );

      Messages.success('Streamer atualizado com sucesso!');

      await fetchUsers();
    } catch (e, s) {
      _logger.error('Controller - Error updating user', e, s);
      if (e is Failure) {
        errorMessage = e.message;
      } else {
        errorMessage = 'Erro ao atualizar o usuário';
      }
      Messages.warning(errorMessage!);
    } finally {
      isLoading = false;
    }
  }
}
