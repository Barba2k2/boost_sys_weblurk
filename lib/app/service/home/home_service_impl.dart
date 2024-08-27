import '../../core/exceptions/failure.dart';
import '../../core/logger/app_logger.dart';
import '../../core/ui/widgets/messages.dart';
import '../../models/score_model.dart';
import '../../repositories/home/home_repository.dart';
import 'home_service.dart';

class HomeServiceImpl implements HomeService {
  final HomeRepository _homeRepository;
  final AppLogger _logger;

  HomeServiceImpl({
    required HomeRepository homeRepository,
    required AppLogger logger,
  })  : _homeRepository = homeRepository,
        _logger = logger;

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
  Future<void> updateLists() async => await fetchSchedules();

  @override
  Future<String?> fetchCurrentChannel() async {
    try {
      final now = DateTime.now();
      final schedules = await _homeRepository.loadSchedules(now);

      if (schedules.isEmpty) {
        _logger.warning(
          'Nenhuma live correspondente ao horário atual, carregando canal padrão',
        );
        return 'https://twitch.tv/BoostTeam_';
      }

      final currentSchedule = schedules.firstWhere(
        (schedule) {
          final startTimeParts = schedule['start_time'].split(':');
          final endTimeParts = schedule['end_time'].split(':');

          final startDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(startTimeParts[0]),
            int.parse(startTimeParts[1]),
            int.parse(startTimeParts[2]),
          );
          final endDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(endTimeParts[0]),
            int.parse(endTimeParts[1]),
            int.parse(endTimeParts[2]),
          );

          return now.isAfter(startDateTime) && now.isBefore(endDateTime);
        },
      );

      if (currentSchedule.isNotEmpty) {
        return currentSchedule['streamer_url'] as String?;
      } else {
        _logger.warning('Nenhuma live correspondente ao horário atual');
        return 'https://twitch.tv/BoostTeam_';
      }
    } catch (e, s) {
      _logger.error('Erro ao buscar o canal atual', e, s);
      throw Failure(message: 'Erro ao buscar o canal atual');
    }
  }

  @override
  Future<void> saveScore(
    int streamerId,
    DateTime date,
    int hour,
    int points,
  ) async {
    try {
      final score = ScoreModel(
        // id: 0,
        streamerId: streamerId,
        date: date,
        hour: hour,
        points: points,
      );

      await _homeRepository.saveScore(score);
    } catch (e, s) {
      _logger.error('Error saving score', e, s);
      throw Failure(message: 'Erro ao salvar a pontuação');
    }
  }
}
