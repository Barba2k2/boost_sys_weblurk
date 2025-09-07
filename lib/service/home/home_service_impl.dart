import 'dart:async';
import '../../core/exceptions/failure.dart';
import '../../core/logger/app_logger.dart';
import '../../core/services/error_message_service.dart';
import '../../core/services/timezone_service.dart';
import '../../models/score_model.dart';
import '../../models/schedule_list_model.dart';
import '../../models/schedule_model.dart';
import '../../repositories/home/home_repository.dart';
import 'home_service.dart';

class HomeServiceImpl implements HomeService {
  HomeServiceImpl({
    required HomeRepository homeRepository,
    required AppLogger logger,
    required TimezoneService timezoneService,
  })  : _homeRepository = homeRepository,
        _logger = logger,
        _timezoneService = timezoneService;

  final HomeRepository _homeRepository;
  final AppLogger _logger;
  final TimezoneService _timezoneService;

  // Cache para evitar chamadas desnecessárias
  List<ScheduleListModel>? _cachedScheduleLists;
  String? _cachedCurrentChannel;
  String? _cachedChannelListA;
  String? _cachedChannelListB;
  DateTime? _lastScheduleListsUpdate;
  DateTime? _lastChannelUpdate;
  DateTime? _lastChannelListAUpdate;
  DateTime? _lastChannelListBUpdate;

  static const Duration _cacheValidityDuration = Duration(minutes: 5);

  /// Verifica se o cache ainda é válido
  bool _isCacheValid(DateTime? lastUpdate) {
    if (lastUpdate == null) return false;
    return DateTime.now().difference(lastUpdate) < _cacheValidityDuration;
  }

  /// Limpa o cache
  void _clearCache() {
    _cachedScheduleLists = null;
    _cachedCurrentChannel = null;
    _cachedChannelListA = null;
    _cachedChannelListB = null;
    _lastScheduleListsUpdate = null;
    _lastChannelUpdate = null;
    _lastChannelListAUpdate = null;
    _lastChannelListBUpdate = null;
  }

  /// Check if current time is within schedule range (with timezone conversion)
  Future<bool> _isCurrentTimeInSchedule(
    ScheduleModel schedule,
    DateTime now,
  ) async {
    try {
      final startTimeStr = schedule.startTime;
      final endTimeStr = schedule.endTime;

      // Convert schedule times from machine timezone to Brazil time
      final convertedTimes = await _timezoneService.convertScheduleTimes(
        startTimeStr,
        endTimeStr,
      );

      final cleanStartTime = convertedTimes['startTime']!
          .replaceAll('Time(', '')
          .replaceAll(')', '');
      final cleanEndTime = convertedTimes['endTime']!
          .replaceAll('Time(', '')
          .replaceAll(')', '');

      if (cleanStartTime.isEmpty || cleanEndTime.isEmpty) {
        return false;
      }

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

      final isCurrent = now.isAfter(startDateTime) && now.isBefore(endDateTime);

      return isCurrent;
    } catch (e) {
      _logger.warning('Erro ao processar horário do agendamento: $e');
      return false;
    }
  }

  @override
  Future<void> fetchSchedules() async {
    try {
      await _homeRepository.loadSchedules(DateTime.now());
    } catch (e, s) {
      _logger.error('Error on load schedules', e, s);
      ErrorMessageService.instance.showScheduleError();
      throw Failure(message: 'Erro ao carregar os agendamentos');
    }
  }

  @override
  Future<List<ScheduleListModel>> fetchScheduleLists() async {
    try {
      // Verifica se o cache ainda é válido
      if (_cachedScheduleLists != null &&
          _isCacheValid(_lastScheduleListsUpdate)) {
        return _cachedScheduleLists!;
      }

      final scheduleLists =
          await _homeRepository.loadScheduleLists(DateTime.now());

      // Atualiza o cache
      _cachedScheduleLists = scheduleLists;
      _lastScheduleListsUpdate = DateTime.now();

      return scheduleLists;
    } catch (e, s) {
      _logger.error('Error on load schedule lists', e, s);
      ErrorMessageService.instance.showScheduleError();
      throw Failure(message: 'Erro ao carregar as listas de agendamentos');
    }
  }

  @override
  Future<List<String>> getAvailableListNames() async {
    try {
      return await _homeRepository.getAvailableListNames();
    } catch (e, s) {
      _logger.error('Error on get available list names', e, s);
      ErrorMessageService.instance.showScheduleError();
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
      ErrorMessageService.instance.showScheduleError();
      throw Failure(message: 'Erro ao buscar lista $listName');
    }
  }

  @override
  Future<void> updateLists() async {
    // Limpa o cache para forçar atualização
    _clearCache();
    return await fetchSchedules();
  }

  @override
  Future<String?> fetchCurrentChannel() async {
    try {
      // Verifica se o cache ainda é válido
      if (_cachedCurrentChannel != null && _isCacheValid(_lastChannelUpdate)) {
        return _cachedCurrentChannel;
      }

      final now = DateTime.now();

      // Convert current time to Brazil timezone (GMT-3) for schedule lookup
      final brazilTime =
          now.add(Duration(hours: -3 - now.timeZoneOffset.inHours));

      final scheduleLists = await _homeRepository.loadScheduleLists(brazilTime);

      String? currentChannel;
      if (scheduleLists.isEmpty) {
        currentChannel = 'https://twitch.tv/BoostTeam_';
      } else {
        for (final scheduleList in scheduleLists) {
          if (scheduleList.schedules.isEmpty) {
            continue;
          }

          ScheduleModel? currentSchedule;

          for (final schedule in scheduleList.schedules) {
            final isCurrent =
                await _isCurrentTimeInSchedule(schedule, brazilTime);
            if (isCurrent) {
              currentSchedule = schedule;
              break;
            }
          }

          currentSchedule ??= ScheduleModel(
            streamerUrl: '',
            date: now,
            startTime: '',
            endTime: '',
          );

          if (currentSchedule.streamerUrl.isNotEmpty) {
            currentChannel = currentSchedule.streamerUrl;
            break;
          }
        }
      }

      // Atualiza o cache
      _cachedCurrentChannel = currentChannel;
      _lastChannelUpdate = DateTime.now();

      return currentChannel;
    } catch (e, s) {
      _logger.error('Erro ao buscar o canal atual', e, s);
      throw Failure(message: 'Erro ao buscar o canal atual');
    }
  }

  @override
  Future<String?> fetchCurrentChannelForList(String listName) async {
    try {
      // Verifica cache específico para cada lista
      String? cachedChannel;
      DateTime? lastUpdate;

      if (listName == 'Lista A') {
        cachedChannel = _cachedChannelListA;
        lastUpdate = _lastChannelListAUpdate;
      } else if (listName == 'Lista B') {
        cachedChannel = _cachedChannelListB;
        lastUpdate = _lastChannelListBUpdate;
      }

      if (cachedChannel != null && _isCacheValid(lastUpdate)) {
        return cachedChannel;
      }

      final now = DateTime.now();

      // Convert current time to Brazil timezone (GMT-3) for schedule lookup
      final brazilTime =
          now.add(Duration(hours: -3 - now.timeZoneOffset.inHours));

      final scheduleList =
          await _homeRepository.loadScheduleListByName(listName, brazilTime);

      String? currentChannel;
      if (scheduleList == null || scheduleList.schedules.isEmpty) {
        currentChannel = 'https://twitch.tv/BoostTeam_';
      } else {
        ScheduleModel? currentSchedule;

        for (final schedule in scheduleList.schedules) {
          final isCurrent =
              await _isCurrentTimeInSchedule(schedule, brazilTime);
          if (isCurrent) {
            currentSchedule = schedule;
            break;
          }
        }

        currentSchedule ??= ScheduleModel(
          streamerUrl: '',
          date: now,
          startTime: '',
          endTime: '',
        );

        currentChannel = currentSchedule.streamerUrl.isNotEmpty
            ? currentSchedule.streamerUrl
            : null;
      }

      // Atualiza o cache específico da lista
      if (listName == 'Lista A') {
        _cachedChannelListA = currentChannel;
        _lastChannelListAUpdate = DateTime.now();
      } else if (listName == 'Lista B') {
        _cachedChannelListB = currentChannel;
        _lastChannelListBUpdate = DateTime.now();
      }

      return currentChannel;
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

  /// Limpa recursos e cache
  void dispose() {
    _clearCache();
  }
}
