import '../../../../utils/utils.dart';
import '../entities/schedule_list_entity.dart';

abstract class HomeRepository {
  Future<Result<List<dynamic>>> fetchSchedules();
  Future<Result<List<ScheduleListEntity>>> fetchScheduleLists();
  Future<Result<List<String>>> getAvailableListNames();
  Future<Result<ScheduleListEntity?>> fetchScheduleListByName(String listName);
  Future<Result<void>> updateLists();
  Future<Result<String?>> fetchCurrentChannel();
  Future<Result<String?>> fetchCurrentChannelForList(String listName);
  Future<Result<void>> saveScore(
    int streamerId,
    DateTime date,
    int hour,
    int minute,
    int points,
  );
  Future<Result<void>> startPolling(int streamerId);
  Future<Result<void>> stopPolling();
  Future<Result<void>> loadUrl(String url);
  Future<Result<void>> reloadWebView();
}
