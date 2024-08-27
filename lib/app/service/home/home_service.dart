abstract class HomeService {
  Future<void> fetchSchedules();
  // Future<void> forceUpdateLive();
  Future<void> updateLists();
  Future<String?> fetchCurrentChannel();
  Future<void> saveScore(
    int streamerId,
    DateTime date,
    int hour,
    int points,
  );
}
