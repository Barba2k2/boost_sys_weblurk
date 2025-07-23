import 'dart:convert';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';

import '../../../../core/helpers/constants.dart';
import '../../../../core/local_storage/local_storage.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../core/ui/widgets/loader.dart';
import '../../../../core/ui/widgets/messages.dart';
import '../../../../models/user_model.dart';
import '../../../../service/user/user_service.dart';
import '../auth_store.dart';
part 'login_controller.g.dart';

class LoginController = LoginControllerBase with _$LoginController;

abstract class LoginControllerBase with Store {
  LoginControllerBase({
    required UserService userService,
    required AppLogger logger,
    required LocalStorage localStorage,
  })  : _userService = userService,
        _localStorage = localStorage,
        _logger = logger;
  final LocalStorage _localStorage;
  final UserService _userService;
  final AppLogger _logger;

  @action
  Future<void> checkUserLogged() async {
    try {
      final String? token = await _userService.getToken();
      final userJson = await _localStorage.read<String>(
        Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY,
      );

      if (token != null && token.isNotEmpty && userJson != null) {
        try {
          final userData = UserModel.fromJson(json.decode(userJson));
          if (userData.id != 0) {
            Loader.show();
            await Future.delayed(const Duration(milliseconds: 200));
            Modular.to.navigate('/');
            Loader.hide();
            return;
          }
        } catch (e) {
          _logger.error('Erro ao decodificar dados do usuário', e);
        }
      }
    } catch (e, s) {
      _logger.error('Erro ao verificar login', e, s);
      await _userService.logout();
    }
  }

  Future<void> login({
    required String nickname,
    required String password,
  }) async {
    try {
      Loader.show();
      await _userService.login(nickname, password);

      final token = await _userService.getToken();
      final userJson = await _localStorage.read<String>(
        Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY,
      );

      if (token != null && userJson != null) {
        // Atualiza o AuthStore explicitamente após login
        final authStore = Modular.get<AuthStore>();
        await authStore.loadUserLogged();
        await Future.delayed(const Duration(milliseconds: 200));
        Modular.to.navigate('/');
      } else {
        Messages.alert('Erro ao realizar login');
        await _userService.logout();
      }

      Loader.hide();
    } catch (e, s) {
      Loader.hide();
      Messages.alert('Usuario e/ou senha incorretos');
      _logger.error('Erro ao realizar login', e, s);
      rethrow;
    }
  }
}
