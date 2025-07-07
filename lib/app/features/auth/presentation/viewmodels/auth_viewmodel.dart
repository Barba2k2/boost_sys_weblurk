import 'package:flutter/foundation.dart';
import '../../../../core/result/result.dart';
import '../../../../utils/command.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/auth_store.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({
    required AuthRepository repository,
    required AuthStore authStore,
  })  : _repository = repository,
        _authStore = authStore {
    login = Command1<void, Map<String, String>>(_login);
    logout = Command0<void>(_logout);
  }

  final AuthRepository _repository;
  final AuthStore _authStore;

  late Command1<void, Map<String, String>> login;
  late Command0<void> logout;

  Future<AppResult<void>> _login(Map<String, String> credentials) async {
    final nickname = credentials['nickname'] ?? '';
    final password = credentials['password'] ?? '';
    final result = await _repository.login(nickname, password);
    
    if (result.isSuccess) {
      final loginData = result.data!;
      final user = loginData['user'] as UserEntity;
      final accessToken = loginData['access_token'] as String;
      final refreshToken = loginData['refresh_token'] as String;
      
      // Salva o usuário no AuthStore
      await _authStore.setUserLogged(user);
      
      // TODO: Salvar tokens no storage seguro se necessário
      // await _secureStorage.write('access_token', accessToken);
      // await _secureStorage.write('refresh_token', refreshToken);
      
      return AppSuccess(null);
    } else {
      return AppFailure(result.error!);
    }
  }

  Future<AppResult<void>> _logout() async {
    final result = await _repository.logout();
    
    if (result.isSuccess) {
      // Limpa o usuário do AuthStore
      await _authStore.clearUserLogged();
      
      // TODO: Limpar tokens do storage seguro se necessário
      // await _secureStorage.remove('access_token');
      // await _secureStorage.remove('refresh_token');
    }
    
    return result;
  }
}
