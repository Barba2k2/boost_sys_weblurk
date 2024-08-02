abstract class UserService {
  Future<void> register(String nickname, String password, String role);
  Future<void> login(String nickname, String password);
}