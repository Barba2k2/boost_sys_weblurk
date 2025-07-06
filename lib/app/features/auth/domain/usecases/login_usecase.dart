import '../../../../utils/utils.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Result<void>> execute(String nickname, String password) async {
    return await _repository.login(nickname, password);
  }
}
