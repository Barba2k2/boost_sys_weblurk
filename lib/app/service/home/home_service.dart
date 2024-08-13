abstract class HomeService {
  Future<void> fetchSchedules();
  Future<void> forceUpdateLive();
  Future<void> updateLists();
  Future<String?> fetchCurrentChannel();
}
