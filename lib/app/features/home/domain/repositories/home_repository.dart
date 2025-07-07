import '../../../../core/result/result.dart';
import '../entities/schedule_list_entity.dart';

abstract class HomeRepository {
  Future<AppResult<List<dynamic>>> fetchSchedules();
  Future<AppResult<List<ScheduleListEntity>>> fetchScheduleLists();
  Future<AppResult<List<String>>> getAvailableListNames();
  Future<AppResult<ScheduleListEntity?>> fetchScheduleListByName(String listName);
  Future<AppResult<void>> updateLists();
  Future<AppResult<String?>> fetchCurrentChannel();
  Future<AppResult<String?>> fetchCurrentChannelForList(String listName);
  Future<AppResult<void>> saveScore(
    int streamerId,
    DateTime date,
    int hour,
    int minute,
    int points,
  );
  Future<AppResult<void>> startPolling(int streamerId);
  Future<AppResult<void>> stopPolling();
  Future<AppResult<void>> loadUrl(String url);
  Future<AppResult<void>> reloadWebView();
}
