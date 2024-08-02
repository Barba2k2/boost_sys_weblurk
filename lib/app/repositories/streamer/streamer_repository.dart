import '../../models/user_model.dart';

abstract interface class StreamerRepository {
  Future<List<UserModel>> fetchUsers();
  Future<void> registerUser(String nickname, String password, String role);
  Future<void> deleteUser(int id);
  Future<void> editUser(int id, String nickname, String password, String role);
}
