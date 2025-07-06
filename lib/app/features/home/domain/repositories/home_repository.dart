import '../../../../utils/utils.dart';
import '../entities/schedule_list_entity.dart';
import 'package:result_dart/result_dart.dart';

abstract class HomeRepository {
  Future<Result<List<dynamic>, Exception>> fetchSchedules();
  Future<Result<List<ScheduleListEntity>, Exception>> fetchScheduleLists();
  Future<Result<List<String>, Exception>> getAvailableListNames();
  Future<Result<ScheduleListEntity?, Exception>> fetchScheduleListByName(String listName);
  Future<Result<void, Exception>> updateLists();
  Future<Result<String?, Exception>> fetchCurrentChannel();
  Future<Result<String?, Exception>> fetchCurrentChannelForList(String listName);
  Future<Result<void, Exception>> saveScore(
    int streamerId,
    DateTime date,
    int hour,
    int minute,
    int points,
  );
  Future<Result<void, Exception>> startPolling(int streamerId);
  Future<Result<void, Exception>> stopPolling();
  Future<Result<void, Exception>> loadUrl(String url);
  Future<Result<void, Exception>> reloadWebView();
}
