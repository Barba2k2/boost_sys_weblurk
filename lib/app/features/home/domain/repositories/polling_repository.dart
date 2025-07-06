import '../../../../utils/utils.dart';
import 'package:result_dart/result_dart.dart';

abstract class PollingRepository {
  Future<Result<void, Exception>> startPolling(int streamerId);
  Future<Result<void, Exception>> stopPolling();
  Future<Result<void, Exception>> checkAndUpdateChannel();
  Future<Result<void, Exception>> checkAndUpdateScore(int streamerId);
  Stream<bool> get healthStatus;
  Stream<String> get channelUpdates;
  bool isPollingActive();
  void dispose();
}
