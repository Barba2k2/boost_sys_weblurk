import '../../models/score_model.dart';

abstract class HomeRepository {
  Future<List<Map<String, dynamic>>> loadSchedules(DateTime date);
  Future<void> forceUpdateLive();
  Future<String?> getCurrentChannel();
  Future<void> saveScore(ScoreModel score);
  // Future<void> updateStreamerStatus(int streamerId, String status);
}
