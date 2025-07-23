import '../../models/schedule_list_model.dart';

abstract class HomeService {
  Future<void> fetchSchedules();
  Future<List<ScheduleListModel>> fetchScheduleLists();
  Future<List<String>> getAvailableListNames();
  Future<ScheduleListModel?> fetchScheduleListByName(String listName);
  // Future<void> forceUpdateLive();
  Future<void> updateLists();
  Future<String?> fetchCurrentChannel();
  Future<String?> fetchCurrentChannelForList(String listName);
  Future<void> saveScore(
    int streamerId,
    DateTime date,
    int hour,
    int minute,
    int points,
  );
}
