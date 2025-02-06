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
          final startTimeStr =
              schedule['start_time'].toString().replaceAll('Time(', '').replaceAll(')', '');
          final endTimeStr =
              schedule['end_time'].toString().replaceAll('Time(', '').replaceAll(')', '');

          final startTimeParts = startTimeStr.split(':');
          final endTimeParts = endTimeStr.split(':');

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
        orElse: () => {'streamer_url': 'https://twitch.tv/BoostTeam_'},
      );

      return currentSchedule['streamer_url'] as String?;
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
    int minute,
    int points,
  ) async {
    try {
      // Input validation
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

      // Add retry logic
      int retryCount = 0;
      const maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          await _homeRepository.saveScore(score);
          _logger.info('Score saved successfully after ${retryCount + 1} attempts');
          return;
        } catch (e) {
          retryCount++;
          if (retryCount == maxRetries) {
            rethrow;
          }
          _logger.warning('Retry attempt $retryCount after error: $e');
          await Future.delayed(Duration(seconds: 1 * retryCount));
        }
      }
    } catch (e, s) {
      _logger.error('Error in saveScore service', e, s);
      if (e is Failure) {
        rethrow;
      }
      throw Failure(message: 'Erro ao salvar a pontuação: ${e.toString()}');
    }
  }
}
