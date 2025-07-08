import 'dart:async';

abstract class PollingService {
  Future<void> startPolling(int streamerId);
  Future<void> stopPolling();
  Future<void> checkAndUpdateChannel();
  Future<void> checkAndUpdateScore(int streamerId);
  Stream<bool> get healthStatus;
  Stream<String> get channelUpdates;
  bool isPollingActive();
  void dispose();
}
