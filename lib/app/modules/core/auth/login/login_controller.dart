import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';

import '../../../../core/logger/app_logger.dart';
import '../../../../core/ui/widgets/loader.dart';
import '../../../../core/ui/widgets/messages.dart';
import '../../../../service/user/user_service.dart';
part 'login_controller.g.dart';

class LoginController = LoginControllerBase with _$LoginController;

abstract class LoginControllerBase with Store {
  final UserService _userService;
  final AppLogger _logger;

  LoginControllerBase({
    required UserService userService,
    required AppLogger logger,
  })  : _userService = userService,
        _logger = logger;

  @action
  Future<void> checkUserLogged() async {
    final String? token = await _userService.getToken();

    if (token != null && token.isNotEmpty) {
      Loader.show();
      Modular.to.navigate('/home/');
    } else {
      // Caso contrário, permanece na tela de login
    }
  }

  Future<void> login({
    required String nickname,
    required String password,
  }) async {
    try {
      Loader.show();
      await _userService.login(nickname, password);
      Loader.hide();
      Modular.to.navigate('/home/');
    } catch (e, s) {
      Loader.hide();
      Messages.alert('Usuario e/ou senha incorretos');
      _logger.error('Failed to login user', e, s);
      rethrow;
    }
  }
}
