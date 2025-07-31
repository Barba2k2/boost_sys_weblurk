import 'package:flutter/foundation.dart';
import 'package:validatorless/validatorless.dart';

import '../../../../../core/helpers/sentry_mixin.dart';
import '../../../../../core/services/error_message_service.dart';
import '../../../../../core/utils/command.dart';
import '../../../../../core/utils/result.dart';
import '../../../../../models/user_model.dart';
import '../../../../../service/user/user_service.dart';
import 'auth_viewmodel.dart';

class LoginViewModel extends ChangeNotifier with SentryMixin {
  LoginViewModel({
    required AuthViewModel authStore,
    required UserService userService,
  })  : _authStore = authStore,
        _userService = userService {
    _authStore.addListener(() => notifyListeners());
  }

  final AuthViewModel _authStore;
  final UserService _userService;

  UserModel? get userLogged => _authStore.userLogged;

  late final loginCommand = Command1<UserModel, LoginParams>(
    (params) => _login(params),
  );
  late final logoutCommand = Command0<void>(() => _logout());

  Future<Result<UserModel>> _login(LoginParams params) async {
    try {
      await captureInfo(
        'Iniciando login',
        data: {'email': params.email},
      );

      await _userService.login(params.email, params.password);

      await _authStore.reloadUserData();

      final user = _authStore.userLogged;
      if (user != null) {
        await captureInfo(
          'Login realizado com sucesso',
          data: {'userId': user.id},
        );
        await setUserContext(
          id: user.id.toString(),
          username: user.nickname,
        );
        return Result.ok(user);
      } else {
        await captureWarning('Usuário não encontrado após login');
        return Result.error(
          Exception('Usuário não encontrado após login'),
        );
      }
    } catch (e) {
      await captureError(e, StackTrace.current, context: 'login_error');
      final errorMessage =
          ErrorMessageService.instance.extractUserFriendlyMessage(e);
      return Result.error(
        Exception(errorMessage),
      );
    }
  }

  Future<Result<void>> _logout() async {
    try {
      await captureInfo('Iniciando logout');
      await _userService.logout();
      await _authStore.logout();
      await captureInfo('Logout realizado com sucesso');
      return Result.ok(null);
    } catch (e) {
      await captureError(e, StackTrace.current, context: 'logout_error');
      return Result.error(
        Exception('Erro no logout: $e'),
      );
    }
  }

  String? validateUser(String? value) {
    return Validatorless.required('Login obrigatório')(value);
  }

  String? validatePassword(String? value) {
    return Validatorless.required('Senha obrigatória')(value);
  }
}

class LoginParams {
  LoginParams({
    required this.email,
    required this.password,
  });
  final String email;
  final String password;
}
