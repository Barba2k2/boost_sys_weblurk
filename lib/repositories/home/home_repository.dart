import '../../models/score_model.dart';
import '../../models/schedule_list_model.dart';
import '../../models/schedule_model.dart';

abstract class HomeRepository {
  Future<List<ScheduleModel>> loadSchedules(DateTime date);
  Future<List<ScheduleListModel>> loadScheduleLists(DateTime date);
  Future<List<String>> getAvailableListNames();
  Future<ScheduleListModel?> loadScheduleListByName(
    String listName,
    DateTime date,
  );
  // Future<void> forceUpdateLive();
  Future<String?> getCurrentChannel();
  Future<void> saveScore(ScoreModel score);
  // Future<void> updateStreamerStatus(int streamerId, String status);
}
