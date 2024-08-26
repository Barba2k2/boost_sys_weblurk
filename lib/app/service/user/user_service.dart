abstract class UserService {
  Future<void> login(String nickname, String password);
  Future<void> logout();
}
