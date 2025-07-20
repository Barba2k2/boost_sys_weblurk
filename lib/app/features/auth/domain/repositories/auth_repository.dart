import '../../../../core/result/result.dart';

abstract class AuthRepository {
  Future<AppResult<Map<String, dynamic>>> login(
    String nickname,
    String password,
  );
  Future<AppResult<AppUnit>> logout();
  Future<AppResult<bool>> checkLoginStatus();
}
