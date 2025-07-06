import '../../../../utils/utils.dart';

abstract class ScheduleRepository {
  Future<Result<List<dynamic>>> getSchedules();
  Future<Result<void>> updateSchedule(dynamic schedule);
  Future<Result<void>> deleteSchedule(int id);
}
