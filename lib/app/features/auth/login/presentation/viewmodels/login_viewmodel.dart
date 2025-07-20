import 'package:flutter/foundation.dart';

import '../../../../../core/utils/command.dart';
import '../../../../../core/utils/result.dart';
import '../../../../../core/auth/auth_store.dart';
import '../../../../../models/user_model.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({
    required AuthStore authStore,
  }) : _authStore = authStore {
    // Escutar mudanças no AuthStore
    _authStore.addListener(() => notifyListeners());
  }

  final AuthStore _authStore;

  // Estado reativo do AuthStore
  UserModel? get userLogged => _authStore.userLogged;

  // Commands para operações
  late final loginCommand =
      Command1<UserModel, LoginParams>((params) => _login(params));
  late final logoutCommand = Command0<void>(() => _logout());

  // Método privado para login
  Future<Result<UserModel>> _login(LoginParams params) async {
    try {
      // Aqui você implementaria a lógica de login
      // Por enquanto, vamos simular um login bem-sucedido
      await Future.delayed(const Duration(seconds: 1));

      // Simular usuário logado
      final user = UserModel(
        id: 1,
        nickname: params.email,
        role: 'user',
        status: 'online',
      );

      return Result.ok(user);
    } catch (e) {
      return Result.error(Exception('Erro no login: $e'));
    }
  }

  // Método privado para logout
  Future<Result<void>> _logout() async {
    try {
      await _authStore.logout();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro no logout: $e'));
    }
  }
}

// Parâmetros para login
class LoginParams {
  final String email;
  final String password;

  LoginParams({
    required this.email,
    required this.password,
  });
}
