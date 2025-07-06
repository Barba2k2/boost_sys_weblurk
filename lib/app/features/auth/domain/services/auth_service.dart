import '../entities/user_entity.dart';

abstract class AuthService {
  Future<UserEntity> login(String username, String password);
  Future<void> logout();
  Future<bool> checkLoginStatus();
} 