import '../../models/confirm_login_model.dart';
import '../../models/user_model.dart';

abstract class UserRepository {
  Future<String> login(String nickname, String password);
  Future<ConfirmLoginModel> confirmLogin();
  Future<UserModel> getUserLogged();
  Future<void> updateLoginStatus(int userId, String status);
  // Future<void> saveLastSeen(int userId);
}
