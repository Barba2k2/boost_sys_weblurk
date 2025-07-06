import 'package:flutter/foundation.dart';
import '../../../../utils/command.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../utils/result.dart';

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

  Future<Result<void>> _login(Map<String, String> credentials) async {
    return await _repository.login(credentials);
  }

  Future<Result<void>> _logout() async {
    return await _repository.logout();
  }

  Future<Result<UserEntity?>> _checkLoginStatus() async {
    return await _repository.checkLoginStatus();
  }
}
