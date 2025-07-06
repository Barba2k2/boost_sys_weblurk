import '../../../../utils/utils.dart';
import '../repositories/polling_repository.dart';

class StartPollingWithIdUseCase {
  final PollingRepository _repository;

  StartPollingWithIdUseCase(this._repository);

  Future<Result<void>> execute(int streamerId) async {
    return await _repository.startPolling(streamerId);
  }
}
