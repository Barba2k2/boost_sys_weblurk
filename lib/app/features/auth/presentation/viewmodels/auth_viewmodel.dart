import 'package:flutter/foundation.dart';
import '../../../../core/result/result.dart';
import '../../../../utils/command.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/local_storage/local_storage.dart';
import '../../../../core/helpers/constants.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({
    required AuthRepository repository,
    required AuthState authState,
    LocalStorage? secureStorage,
  })  : _repository = repository,
        _authState = authState,
        _secureStorage = secureStorage {
    login = Command1<AppUnit, Map<String, String>>(_login);
    logout = Command0<AppUnit>(_logout);
  }

  final AuthRepository _repository;
  final AuthState _authState;
  final LocalStorage? _secureStorage;

  late Command1<AppUnit, Map<String, String>> login;
  late Command0<AppUnit> logout;

  Future<AppResult<AppUnit>> _login(Map<String, String> credentials) async {
    final nickname = credentials['nickname'] ?? '';
    final password = credentials['password'] ?? '';
    final result = await _repository.login(nickname, password);

    if (result.isSuccess) {
      final loginData = result.data!;
      final user = loginData['user'] as UserEntity;
      final accessToken = loginData['access_token'] as String;
      final refreshToken = loginData['refresh_token'] as String;

      // Salva o usuário no AuthState
      await _authState.setUserLogged(user);

      // Salva tokens no storage seguro se disponível
      if (_secureStorage != null) {
        await _secureStorage.write(
          Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY,
          accessToken,
        );
        await _secureStorage.write(
          Constants.LOCAL_SOTRAGE_REFRESH_TOKEN_KEY,
          refreshToken,
        );
      }

      return AppSuccess(appUnit);
    } else {
      return AppFailure(result.error!);
    }
  }

  Future<AppResult<AppUnit>> _logout() async {
    final result = await _repository.logout();

    if (result.isSuccess) {
      // Limpa o usuário do AuthState
      await _authState.clearUserLogged();

      // Limpa tokens do storage seguro se disponível
      if (_secureStorage != null) {
        await _secureStorage.remove(Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY);
        await _secureStorage.remove(Constants.LOCAL_SOTRAGE_REFRESH_TOKEN_KEY);
      }
      return AppSuccess(appUnit);
    } else {
      return AppFailure(result.error!);
    }
  }
}
