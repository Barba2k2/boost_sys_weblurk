import '../../../../utils/utils.dart';

abstract class HomeRepository {
  Future<Result<void>> initializeHome();
  Future<Result<void>> startPolling();
  Future<Result<void>> stopPolling();
}
