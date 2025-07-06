import '../entities/schedule_list_entity.dart';

abstract class HomeService {
  Future<void> fetchSchedules();
  Future<List<ScheduleListEntity>> fetchScheduleLists();
  Future<List<String>> getAvailableListNames();
  Future<ScheduleListEntity?> fetchScheduleListByName(String listName);
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
