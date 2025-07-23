import '../../core/exceptions/failure.dart';
import '../../core/logger/app_logger.dart';
import '../../core/ui/widgets/messages.dart';
import '../../models/score_model.dart';
import '../../models/schedule_list_model.dart';
import '../../models/schedule_model.dart';
import '../../repositories/home/home_repository.dart';
import 'home_service.dart';

class HomeServiceImpl implements HomeService {
  HomeServiceImpl({
    required HomeRepository homeRepository,
    required AppLogger logger,
  })  : _homeRepository = homeRepository,
        _logger = logger;

  final HomeRepository _homeRepository;
  final AppLogger _logger;

  @override
  Future<void> fetchSchedules() async {
    try {
      await _homeRepository.loadSchedules(DateTime.now());
    } catch (e, s) {
      _logger.error('Error on load schedules', e, s);
      Messages.warning('Erro ao carregar os agendamentos');
      throw Failure(message: 'Erro ao carregar os agendamentos');
    }
  }

  @override
  Future<List<ScheduleListModel>> fetchScheduleLists() async {
    try {
      return await _homeRepository.loadScheduleLists(DateTime.now());
    } catch (e, s) {
      _logger.error('Error on load schedule lists', e, s);
      Messages.warning('Erro ao carregar as listas de agendamentos');
      throw Failure(message: 'Erro ao carregar as listas de agendamentos');
    }
  }

  @override
  Future<List<String>> getAvailableListNames() async {
    try {
      return await _homeRepository.getAvailableListNames();
    } catch (e, s) {
      _logger.error('Error on get available list names', e, s);
      Messages.warning('Erro ao carregar nomes das listas');
      throw Failure(message: 'Erro ao carregar nomes das listas');
    }
  }

  @override
  Future<ScheduleListModel?> fetchScheduleListByName(String listName) async {
    try {
      final result = await _homeRepository.loadScheduleListByName(
        listName,
        DateTime.now(),
      );
      return result;
    } catch (e, s) {
      _logger.error('Erro no fetch da lista $listName', e, s);
      Messages.warning('Erro ao buscar lista $listName');
      throw Failure(message: 'Erro ao buscar lista $listName');
    }
  }

  // @override
  // Future<void> forceUpdateLive() async {
  //   try {
  //     await _homeRepository.forceUpdateLive();
  //   } catch (e, s) {
  //     _logger.error('Error forcing live update', e, s);
  //     throw Failure(message: 'Erro ao forçar a atualização da live');
  //   }
  // }

  @override
  Future<void> updateLists() async {
    return await fetchSchedules();
  }

  @override
  Future<String?> fetchCurrentChannel() async {
    try {
      final now = DateTime.now();
      final scheduleLists = await _homeRepository.loadScheduleLists(now);

      if (scheduleLists.isEmpty) {
        _logger.warning(
          'Nenhuma lista de agendamentos encontrada, carregando canal padrão',
        );
        return 'https://twitch.tv/BoostTeam_';
      }

      // Procura em todas as listas por um agendamento atual
      for (final scheduleList in scheduleLists) {
        if (scheduleList.schedules.isEmpty) continue;

        final currentSchedule = scheduleList.schedules.firstWhere(
          (schedule) {
            try {
              final startTimeStr = schedule.startTime;
              final endTimeStr = schedule.endTime;

              // Remove o formato Time() se presente
              final cleanStartTime =
                  startTimeStr.replaceAll('Time(', '').replaceAll(')', '');
              final cleanEndTime =
                  endTimeStr.replaceAll('Time(', '').replaceAll(')', '');

              if (cleanStartTime.isEmpty || cleanEndTime.isEmpty) return false;

              final startTimeParts = cleanStartTime.split(':');
              final endTimeParts = cleanEndTime.split(':');

              if (startTimeParts.length < 2 || endTimeParts.length < 2) {
                return false;
              }

              final startDateTime = DateTime(
                now.year,
                now.month,
                now.day,
                int.parse(startTimeParts[0]),
                int.parse(startTimeParts[1]),
                startTimeParts.length > 2 ? int.parse(startTimeParts[2]) : 0,
              );
              final endDateTime = DateTime(
                now.year,
                now.month,
                now.day,
                int.parse(endTimeParts[0]),
                int.parse(endTimeParts[1]),
                endTimeParts.length > 2 ? int.parse(endTimeParts[2]) : 0,
              );

              return now.isAfter(startDateTime) && now.isBefore(endDateTime);
            } catch (e) {
              _logger.warning('Erro ao processar horário do agendamento: $e');
              return false;
            }
          },
          orElse: () => ScheduleModel(
            streamerUrl: '',
            date: now,
            startTime: '',
            endTime: '',
          ),
        );

        if (currentSchedule.streamerUrl.isNotEmpty) {
          return currentSchedule.streamerUrl;
        }
      }

      _logger.warning(
        'Nenhuma live correspondente ao horário atual, carregando canal padrão',
      );
      return 'https://twitch.tv/BoostTeam_';
    } catch (e, s) {
      _logger.error('Erro ao buscar o canal atual', e, s);
      throw Failure(message: 'Erro ao buscar o canal atual');
    }
  }

  @override
  Future<String?> fetchCurrentChannelForList(String listName) async {
    try {
      final now = DateTime.now();
      final scheduleList =
          await _homeRepository.loadScheduleListByName(listName, now);

      if (scheduleList == null || scheduleList.schedules.isEmpty) {
        _logger.warning(
          'Lista $listName não encontrada ou vazia, carregando canal padrão',
        );
        return 'https://twitch.tv/BoostTeam_';
      }

      // Procura por um agendamento atual na lista específica
      final currentSchedule = scheduleList.schedules.firstWhere(
        (schedule) {
          try {
            final startTimeStr = schedule.startTime;
            final endTimeStr = schedule.endTime;

            // Remove o formato Time() se presente
            final cleanStartTime =
                startTimeStr.replaceAll('Time(', '').replaceAll(')', '');
            final cleanEndTime =
                endTimeStr.replaceAll('Time(', '').replaceAll(')', '');

            if (cleanStartTime.isEmpty || cleanEndTime.isEmpty) return false;

            final startTimeParts = cleanStartTime.split(':');
            final endTimeParts = cleanEndTime.split(':');

            if (startTimeParts.length < 2 || endTimeParts.length < 2) {
              return false;
            }

            final startDateTime = DateTime(
              now.year,
              now.month,
              now.day,
              int.parse(startTimeParts[0]),
              int.parse(startTimeParts[1]),
              startTimeParts.length > 2 ? int.parse(startTimeParts[2]) : 0,
            );
            final endDateTime = DateTime(
              now.year,
              now.month,
              now.day,
              int.parse(endTimeParts[0]),
              int.parse(endTimeParts[1]),
              endTimeParts.length > 2 ? int.parse(endTimeParts[2]) : 0,
            );

            return now.isAfter(startDateTime) && now.isBefore(endDateTime);
          } catch (e) {
            _logger.warning('Erro ao processar horário do agendamento: $e');
            return false;
          }
        },
        orElse: () => ScheduleModel(
          streamerUrl: '',
          date: now,
          startTime: '',
          endTime: '',
        ),
      );

      if (currentSchedule.streamerUrl.isNotEmpty) {
        return currentSchedule.streamerUrl;
      }
      return 'https://twitch.tv/BoostTeam_';
    } catch (e, s) {
      _logger.error('Erro ao buscar o canal atual da $listName', e, s);
      throw Failure(message: 'Erro ao buscar o canal atual da $listName');
    }
  }

  @override
  Future<void> saveScore(
    int streamerId,
    DateTime date,
    int hour,
    int minute,
    int points,
  ) async {
    // Validações
    if (streamerId <= 0) throw Failure(message: 'ID do streamer inválido');
    if (hour < 0 || hour > 23) throw Failure(message: 'Hora inválida');
    if (minute < 0 || minute > 59) throw Failure(message: 'Minuto inválido');
    if (points < 0) throw Failure(message: 'Pontuação inválida');

    final score = ScoreModel(
      streamerId: streamerId,
      date: date,
      hour: hour,
      minute: minute,
      points: points,
    );

    try {
      await _homeRepository.saveScore(score);
    } catch (e) {
      rethrow;
    }
  }
}
