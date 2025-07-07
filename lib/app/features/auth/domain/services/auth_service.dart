import '../entities/user_entity.dart';

abstract class AuthService {
  Future<Map<String, dynamic>> login(String nickname, String password);
  Future<Map<String, String>> confirmLogin(String accessToken, String windowsToken);
  Future<void> logout();
  Future<bool> checkLoginStatus();
} 