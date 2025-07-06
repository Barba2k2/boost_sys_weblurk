import '../../../../utils/utils.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<Result<void>> execute() async {
    return await _repository.logout();
  }
}
