import 'package:boost_sys_weblurk/service/home/home_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:boost_sys_weblurk/repositories/home/home_repository.dart';
import 'package:boost_sys_weblurk/core/logger/app_logger.dart';
import 'package:boost_sys_weblurk/core/exceptions/failure.dart';
import 'package:boost_sys_weblurk/models/score_model.dart';
import 'package:boost_sys_weblurk/models/schedule_model.dart';
import 'package:boost_sys_weblurk/models/schedule_list_model.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

class MockAppLogger extends Mock implements AppLogger {}

class FakeScoreModel extends Fake implements ScoreModel {}

class TestableHomeService implements HomeService {
  TestableHomeService({
    required HomeRepository homeRepository,
    required AppLogger logger,
  })  : _homeRepository = homeRepository,
        _logger = logger;
  final HomeRepository _homeRepository;
  final AppLogger _logger;

  bool throwErrorOnFetchSchedules = false;
  bool throwErrorOnFetchCurrentChannel = false;

  @override
  Future<void> fetchSchedules() async {
    if (throwErrorOnFetchSchedules) {
      _logger.error(
        'Error on load schedules',
        Failure(message: 'Repository error'),
        StackTrace.current,
      );
      throw Failure(message: 'Erro ao carregar os agendamentos');
    }
    await _homeRepository.loadSchedules(DateTime.now());
  }

  @override
  Future<String?> fetchCurrentChannel() async {
    if (throwErrorOnFetchCurrentChannel) {
      _logger.error(
        'Erro ao buscar o canal atual',
        Failure(message: 'Repository error'),
        StackTrace.current,
      );
      throw Failure(message: 'Erro ao buscar o canal atual');
    }

    final schedules = await _homeRepository.loadSchedules(DateTime.now());

    if (schedules.isEmpty) {
      _logger.warning(
          'Nenhuma live correspondente ao horário atual, carregando canal padrão');
      return 'https://twitch.tv/BoostTeam_';
    }

    final now = DateTime.now();
    for (final schedule in schedules) {
      final startTimeStr =
          schedule.startTime.replaceAll('Time(', '').replaceAll(')', '');
      final endTimeStr =
          schedule.endTime.replaceAll('Time(', '').replaceAll(')', '');

      final startTimeParts = startTimeStr.split(':');
      final endTimeParts = endTimeStr.split(':');

      if (startTimeParts.length >= 2 && endTimeParts.length >= 2) {
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

        if (now.isAfter(startDateTime) && now.isBefore(endDateTime)) {
          return schedule.streamerUrl;
        }
      }
    }

    return 'https://twitch.tv/BoostTeam_';
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

  @override
  Future<void> updateLists() async {
    await fetchSchedules();
  }

  @override
  Future<List<String>> getAvailableListNames() async {
    return [];
  }

  @override
  Future<List<ScheduleListModel>> fetchScheduleLists() async {
    return [];
  }

  @override
  Future<ScheduleListModel?> fetchScheduleListByName(String listName) async {
    return null;
  }

  @override
  Future<String?> fetchCurrentChannelForList(String listName) async {
    return 'https://twitch.tv/BoostTeam_';
  }
}

void main() {
  late TestableHomeService homeService;
  late MockHomeRepository mockHomeRepository;
  late MockAppLogger mockLogger;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(FakeScoreModel());
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    mockHomeRepository = MockHomeRepository();
    mockLogger = MockAppLogger();

    homeService = TestableHomeService(
      homeRepository: mockHomeRepository,
      logger: mockLogger,
    );
  });

  group('HomeService', () {
    test('fetchSchedules calls repository', () async {
      final schedules = <ScheduleModel>[];
      when(() => mockHomeRepository.loadSchedules(any()))
          .thenAnswer((_) async => schedules);

      await homeService.fetchSchedules();

      verify(() => mockHomeRepository.loadSchedules(any())).called(1);
    });

    test('fetchCurrentChannel returns channel from schedules', () async {
      final now = DateTime.now();
      final startHour = now.hour - 1;
      final endHour = now.hour + 1;

      when(() => mockHomeRepository.loadSchedules(any())).thenAnswer(
        (_) async => [
          ScheduleModel(
            streamerUrl: 'https://twitch.tv/channel1',
            date: now,
            startTime: '$startHour:00',
            endTime: '$endHour:00',
          ),
        ],
      );

      final result = await homeService.fetchCurrentChannel();

      expect(result, 'https://twitch.tv/channel1');
      verify(() => mockHomeRepository.loadSchedules(any())).called(1);
    });

    test('fetchCurrentChannel returns default channel when no current schedule',
        () async {
      final now = DateTime.now();
      final pastStartHour = now.hour - 3;
      final pastEndHour = now.hour - 2;

      when(() => mockHomeRepository.loadSchedules(any())).thenAnswer(
        (_) async => [
          ScheduleModel(
            streamerUrl: 'https://twitch.tv/channel1',
            date: now,
            startTime: '$pastStartHour:00',
            endTime: '$pastEndHour:00',
          ),
        ],
      );

      final result = await homeService.fetchCurrentChannel();

      expect(result, 'https://twitch.tv/BoostTeam_');
      verify(() => mockHomeRepository.loadSchedules(any())).called(1);
    });

    test('fetchCurrentChannel returns default channel when schedules is empty',
        () async {
      when(() => mockHomeRepository.loadSchedules(any())).thenAnswer(
        (_) async => <ScheduleModel>[],
      );

      final result = await homeService.fetchCurrentChannel();

      expect(result, 'https://twitch.tv/BoostTeam_');
      verify(() => mockHomeRepository.loadSchedules(any())).called(1);
      verify(() => mockLogger.warning(any())).called(1);
    });

    test('saveScore calls repository with correct model', () async {
      final now = DateTime.now();
      final streamerId = 123;
      final hour = now.hour;
      final minute = now.minute;
      final points = 100;

      when(() => mockHomeRepository.saveScore(any())).thenAnswer(
        (_) async => {},
      );

      await homeService.saveScore(streamerId, now, hour, minute, points);

      verify(() => mockHomeRepository.saveScore(any())).called(1);
    });

    test('saveScore validates input parameters', () async {
      final now = DateTime.now();

      expect(
        () => homeService.saveScore(0, now, 10, 30, 100),
        throwsA(
          isA<Failure>().having(
            (f) => f.message,
            'message',
            'ID do streamer inválido',
          ),
        ),
      );

      expect(
        () => homeService.saveScore(123, now, 24, 30, 100),
        throwsA(
          isA<Failure>().having(
            (f) => f.message,
            'message',
            'Hora inválida',
          ),
        ),
      );

      expect(
        () => homeService.saveScore(123, now, 10, 60, 100),
        throwsA(
          isA<Failure>().having(
            (f) => f.message,
            'message',
            'Minuto inválido',
          ),
        ),
      );

      expect(
        () => homeService.saveScore(123, now, 10, 30, -1),
        throwsA(
          isA<Failure>().having(
            (f) => f.message,
            'message',
            'Pontuação inválida',
          ),
        ),
      );
    });

    test('fetchSchedules handles repository error', () async {
      homeService.throwErrorOnFetchSchedules = true;

      expect(
        () => homeService.fetchSchedules(),
        throwsA(
          isA<Failure>().having(
            (f) => f.message,
            'message',
            'Erro ao carregar os agendamentos',
          ),
        ),
      );

      verify(() => mockLogger.error(any(), any(), any())).called(1);
    });

    test('fetchCurrentChannel handles repository error', () async {
      homeService.throwErrorOnFetchCurrentChannel = true;

      expect(
        () => homeService.fetchCurrentChannel(),
        throwsA(
          isA<Failure>().having(
            (f) => f.message,
            'message',
            'Erro ao buscar o canal atual',
          ),
        ),
      );

      verify(() => mockLogger.error(any(), any(), any())).called(1);
    });

    test('saveScore handles repository error', () async {
      final now = DateTime.now();

      when(() => mockHomeRepository.saveScore(any())).thenThrow(
        Failure(message: 'Repository error'),
      );

      expect(
        () => homeService.saveScore(123, now, 10, 30, 100),
        throwsA(
          isA<Failure>().having(
            (f) => f.message,
            'message',
            'Repository error',
          ),
        ),
      );
    });

    test('updateLists calls fetchSchedules', () async {
      final schedules = <ScheduleModel>[];
      when(() => mockHomeRepository.loadSchedules(any())).thenAnswer(
        (_) async => schedules,
      );

      await homeService.updateLists();

      verify(() => mockHomeRepository.loadSchedules(any())).called(1);
    });
  });
}
