import '../../../../utils/utils.dart';
import '../repositories/polling_repository.dart';

class CheckAndUpdateChannelUseCase {
  final PollingRepository _repository;

  CheckAndUpdateChannelUseCase(this._repository);

  Future<Result<void>> execute() async {
    return await _repository.checkAndUpdateChannel();
  }
}
