import '../../../../core/exceptions/failure.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../utils/utils.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../../domain/services/schedule_service.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  ScheduleRepositoryImpl({
    required ScheduleService scheduleService,
    required AppLogger logger,
  })  : _scheduleService = scheduleService,
        _logger = logger;

  final ScheduleService _scheduleService;
  final AppLogger _logger;

  @override
  Future<Result<List<dynamic>>> getSchedules() async {
    try {
      _logger.info('Repository: Iniciando busca de schedules');
      
      final data = await _scheduleService.getSchedules();
      
      return Result.ok(data).when(
        success: (schedules) {
          _logger.info('Repository: Schedules buscados com sucesso: ${schedules.length}');
          return Result.ok(schedules);
        },
        error: (failure) {
          _logger.error('Repository: Erro ao buscar schedules', failure);
          return Result.error(failure);
        },
        loading: () {
          _logger.info('Repository: Buscando schedules...');
          return Result.loading();
        },
      );
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao buscar schedules', e, s);
      return Result.error(Failure('Erro ao buscar schedules: $e'));
    }
  }

  @override
  Future<Result<void>> updateSchedule(dynamic schedule) async {
    try {
      _logger.info('Repository: Iniciando atualização de schedule');
      
      await _scheduleService.updateSchedule(schedule);
      
      return Result.ok(null).when(
        success: (_) {
          _logger.info('Repository: Schedule atualizado com sucesso');
          return Result.ok(null);
        },
        error: (failure) {
          _logger.error('Repository: Erro ao atualizar schedule', failure);
          return Result.error(failure);
        },
        loading: () {
          _logger.info('Repository: Atualizando schedule...');
          return Result.loading();
        },
      );
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao atualizar schedule', e, s);
      return Result.error(Failure('Erro ao atualizar schedule: $e'));
    }
  }

  @override
  Future<Result<void>> deleteSchedule(int id) async {
    try {
      _logger.info('Repository: Iniciando exclusão de schedule: $id');
      
      await _scheduleService.deleteSchedule(id);
      
      return Result.ok(null).when(
        success: (_) {
          _logger.info('Repository: Schedule deletado com sucesso');
          return Result.ok(null);
        },
        error: (failure) {
          _logger.error('Repository: Erro ao deletar schedule', failure);
          return Result.error(failure);
        },
        loading: () {
          _logger.info('Repository: Deletando schedule...');
          return Result.loading();
        },
      );
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao deletar schedule', e, s);
      return Result.error(Failure('Erro ao deletar schedule: $e'));
    }
  }
} 