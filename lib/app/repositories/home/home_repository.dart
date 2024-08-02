abstract interface class HomeRepository {
  Future<void> saveSchedules(DateTime selectedDate, List<String> streamerUrl);
  Future<List<Map<String, dynamic>>> loadSchedules(DateTime selectedDate);
  Future<void> forceUpdateLive();
}
