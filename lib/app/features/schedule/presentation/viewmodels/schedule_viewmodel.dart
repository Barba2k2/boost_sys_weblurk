import 'package:flutter/foundation.dart';
import '../../../../utils/command.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../../../../utils/result.dart';

class ScheduleViewModel extends ChangeNotifier {
  ScheduleViewModel({required ScheduleRepository repository})
      : _repository = repository {
    loadSchedules = Command0<List<ScheduleEntity>>(_loadSchedules);
    loadScheduleByName = Command1<List<ScheduleEntity>, String>(_loadScheduleByName);
    saveSchedule = Command1<void, ScheduleEntity>(_saveSchedule);
    deleteSchedule = Command1<void, int>(_deleteSchedule);
  }

  final ScheduleRepository _repository;

  late Command0<List<ScheduleEntity>> loadSchedules;
  late Command1<List<ScheduleEntity>, String> loadScheduleByName;
  late Command1<void, ScheduleEntity> saveSchedule;
  late Command1<void, int> deleteSchedule;

  Future<Result<List<ScheduleEntity>>> _loadSchedules() async {
    return await _repository.fetchSchedules();
  }

  Future<Result<List<ScheduleEntity>>> _loadScheduleByName(String name) async {
    return await _repository.fetchScheduleByName(name);
  }

  Future<Result<void>> _saveSchedule(ScheduleEntity schedule) async {
    return await _repository.saveSchedule(schedule);
  }

  Future<Result<void>> _deleteSchedule(int id) async {
    return await _repository.deleteSchedule(id);
  }
} 