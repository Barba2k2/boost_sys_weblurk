import '../../../../utils/utils.dart';

abstract class PollingRepository {
  Future<Result<void>> startPolling(int streamerId);
  Future<Result<void>> stopPolling();
  Future<Result<void>> checkAndUpdateChannel();
  Future<Result<void>> checkAndUpdateScore(int streamerId);
  Stream<bool> get healthStatus;
  Stream<String> get channelUpdates;
  bool isPollingActive();
  void dispose();
}
