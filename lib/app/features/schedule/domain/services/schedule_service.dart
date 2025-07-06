abstract class ScheduleService {
  Future<List<dynamic>> getSchedules();
  Future<void> updateSchedule(dynamic schedule);
  Future<void> deleteSchedule(int id);
} 