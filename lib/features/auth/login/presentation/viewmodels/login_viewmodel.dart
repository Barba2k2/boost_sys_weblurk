import 'package:flutter/foundation.dart';
import 'package:validatorless/validatorless.dart';

import '../../../../../core/services/error_message_service.dart';
import '../../../../../core/utils/command.dart';
import '../../../../../core/utils/result.dart';
import '../../../../../models/user_model.dart';
import '../../../../../service/user/user_service.dart';
import 'auth_viewmodel.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({
    required AuthViewModel authStore,
    required UserService userService,
  })  : _authStore = authStore,
        _userService = userService {
    // Escutar mudanças no AuthStore
    _authStore.addListener(() => notifyListeners());
  }

  final AuthViewModel _authStore;
  final UserService _userService;

  // Estado reativo do AuthStore
  UserModel? get userLogged => _authStore.userLogged;

  // Commands para operações
  late final loginCommand =
      Command1<UserModel, LoginParams>((params) => _login(params));
  late final logoutCommand = Command0<void>(() => _logout());

  // Método privado para login
  Future<Result<UserModel>> _login(LoginParams params) async {
    try {
      // Usar o UserService real para fazer login
      await _userService.login(params.email, params.password);

      // Recarregar os dados do usuário do AuthStore
      await _authStore.reloadUserData();

      // Retornar o usuário logado
      final user = _authStore.userLogged;
      if (user != null) {
        return Result.ok(user);
      } else {
        return Result.error(
          Exception('Usuário não encontrado após login'),
        );
      }
    } catch (e) {
      // Usar o ErrorMessageService para extrair mensagem amigável
      final errorMessage =
          ErrorMessageService.instance.extractUserFriendlyMessage(e);
      return Result.error(Exception(errorMessage));
    }
  }

  // Método privado para logout
  Future<Result<void>> _logout() async {
    try {
      await _userService.logout();
      await _authStore.logout();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro no logout: $e'));
    }
  }

  String? validateUser(String? value) {
    return Validatorless.required('Login obrigatório')(value);
  }

  String? validatePassword(String? value) {
    return Validatorless.required('Senha obrigatória')(value);
  }
}

// Parâmetros para login
class LoginParams {
  LoginParams({
    required this.email,
    required this.password,
  });
  final String email;
  final String password;
}
