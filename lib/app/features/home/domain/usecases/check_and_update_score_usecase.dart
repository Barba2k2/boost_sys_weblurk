import '../../../../utils/utils.dart';
import '../repositories/polling_repository.dart';

class CheckAndUpdateScoreUseCase {
  final PollingRepository _repository;

  CheckAndUpdateScoreUseCase(this._repository);

  Future<Result<void>> execute(int streamerId) async {
    return await _repository.checkAndUpdateScore(streamerId);
  }
}
