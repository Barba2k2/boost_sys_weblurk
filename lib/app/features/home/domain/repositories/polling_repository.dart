import '../../../../core/result/result.dart';

abstract class PollingRepository {
  Future<AppResult<void>> startPolling(int streamerId);
  Future<AppResult<void>> stopPolling();
  Future<AppResult<void>> checkAndUpdateChannel();
  Future<AppResult<void>> checkAndUpdateScore(int streamerId);
  Stream<bool> get healthStatus;
  Stream<String> get channelUpdates;
  bool isPollingActive();
  void dispose();
}
