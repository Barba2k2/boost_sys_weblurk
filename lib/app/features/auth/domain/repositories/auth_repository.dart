import '../../../../utils/utils.dart';

abstract class AuthRepository {
  Future<Result<void>> login(String nickname, String password);
  Future<Result<void>> logout();
  Future<Result<bool>> isLoggedIn();
}
