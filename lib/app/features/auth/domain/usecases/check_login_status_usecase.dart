import '../../../../utils/utils.dart';
import '../repositories/auth_repository.dart';

class CheckLoginStatusUseCase {
  final AuthRepository _repository;

  CheckLoginStatusUseCase(this._repository);

  Future<Result<bool>> execute() async {
    return await _repository.isLoggedIn();
  }
}
