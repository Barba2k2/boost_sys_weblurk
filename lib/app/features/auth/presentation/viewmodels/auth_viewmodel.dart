import 'package:flutter/foundation.dart';
import '../../../../utils/command.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:result_dart/result_dart.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({required AuthRepository repository})
      : _repository = repository {
    login = Command1<void, Map<String, String>>(_login);
    logout = Command0<void>(_logout);
    checkLoginStatus = Command0<UserEntity?>(_checkLoginStatus);
  }

  final AuthRepository _repository;

  late Command1<void, Map<String, String>> login;
  late Command0<void> logout;
  late Command0<UserEntity?> checkLoginStatus;

  Future<Result<void, Exception>> _login(Map<String, String> credentials) async {
    final username = credentials['username'] ?? '';
    final password = credentials['password'] ?? '';
    final result = await _repository.login(username, password);
    return result;
  }

  Future<Result<void, Exception>> _logout() async {
    return await _repository.logout();
  }

  Future<Result<UserEntity?, Exception>> _checkLoginStatus() async {
    final result = await _repository.checkLoginStatus();
    return Success(UserEntity.empty());
  }
}
