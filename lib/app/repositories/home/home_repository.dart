abstract class HomeRepository {
  Future<List<Map<String, dynamic>>> loadSchedules(DateTime date);
  Future<void> forceUpdateLive();
  Future<String?> getCurrentChannel();
}
