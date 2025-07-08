import '../entities/user_entity.dart';
import '../../../../core/result/result.dart';

abstract class AuthRepository {
  Future<AppResult<Map<String, dynamic>>> login(String nickname, String password);
  Future<AppResult<void>> logout();
  Future<AppResult<bool>> checkLoginStatus();
}
