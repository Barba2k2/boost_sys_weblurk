import '../../../../utils/utils.dart';
import '../repositories/home_repository.dart';

class StopPollingUseCase {
  final HomeRepository _repository;

  StopPollingUseCase(this._repository);

  Future<Result<void>> execute() async {
    return await _repository.stopPolling();
  }
}
