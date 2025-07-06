import '../../../../utils/utils.dart';
import '../repositories/home_repository.dart';

class StartPollingUseCase {
  final HomeRepository _repository;

  StartPollingUseCase(this._repository);

  Future<Result<void>> execute() async {
    return await _repository.startPolling();
  }
}
