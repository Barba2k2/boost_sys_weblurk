import 'dart:async';

import '../../../../core/result/result.dart';

abstract class PollingDataSource {
  Future<AppResult<AppUnit>> startPolling(int streamerId);
  Future<AppResult<AppUnit>> stopPolling();
  Future<AppResult<AppUnit>> checkAndUpdateChannel();
  Future<AppResult<AppUnit>> checkAndUpdateScore(int streamerId);
  Stream<bool> get healthStatus;
  Stream<String> get channelUpdates;
  bool isPollingActive();
  void dispose();
}
