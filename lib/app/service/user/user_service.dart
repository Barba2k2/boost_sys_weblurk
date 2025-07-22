abstract class UserService {
  Future<void> login(String nickname, String password);
  Future<void> logout();
  Future<String?> getToken();
  Future<void> updateLoginStatus(String status);
}
