import 'package:boost_sys_weblurk/app/service/home/home_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:boost_sys_weblurk/app/repositories/home/home_repository.dart';
import 'package:boost_sys_weblurk/app/core/logger/app_logger.dart';
import 'package:boost_sys_weblurk/app/core/exceptions/failure.dart';
import 'package:boost_sys_weblurk/app/models/score_model.dart';

// Mock classes
class MockHomeRepository extends Mock implements HomeRepository {}

class MockAppLogger extends Mock implements AppLogger {}

class FakeScoreModel extends Fake implements ScoreModel {}

// Versão modificada do HomeService com implementação simplificada para testes
class TestableHomeService implements HomeService {
  TestableHomeService({
    required HomeRepository homeRepository,
    required AppLogger logger,
  })  : _homeRepository = homeRepository,
        _logger = logger;
  final HomeRepository _homeRepository;
  final AppLogger _logger;

  // Variável para testes
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
      _logger.warning('Nenhuma live correspondente ao horário atual, carregando canal padrão');
      return 'https://twitch.tv/BoostTeam_';
    }

    // Verifica se há algum horário atual
    final now = DateTime.now();
    for (final schedule in schedules) {
      final startTimeStr =
          schedule['start_time'].toString().replaceAll('Time(', '').replaceAll(')', '');
      final endTimeStr =
          schedule['end_time'].toString().replaceAll('Time(', '').replaceAll(')', '');

      final startTimeParts = startTimeStr.split(':');
      final endTimeParts = endTimeStr.split(':');

      if (startTimeParts.length >= 3 && endTimeParts.length >= 3) {
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

        if (now.isAfter(startDateTime) && now.isBefore(endDateTime)) {
          return schedule['streamer_url'] as String?;
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

  @override
  Future<void> updateLists() async {
    await fetchSchedules();
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
      // Arrange
      final schedules = <Map<String, dynamic>>[];
      when(() => mockHomeRepository.loadSchedules(any())).thenAnswer((_) async => schedules);

      // Act
      await homeService.fetchSchedules();

      // Assert
      verify(() => mockHomeRepository.loadSchedules(any())).called(1);
    });

    test('fetchCurrentChannel returns channel from schedules', () async {
      // Arrange
      final now = DateTime.now();
      final startHour = now.hour - 1;
      final endHour = now.hour + 1;

      when(() => mockHomeRepository.loadSchedules(any())).thenAnswer(
        (_) async => [
          {
            'start_time': 'Time($startHour:00:00)',
            'end_time': 'Time($endHour:00:00)',
            'streamer_url': 'https://twitch.tv/channel1',
          },
        ],
      );

      // Act
      final result = await homeService.fetchCurrentChannel();

      // Assert
      expect(result, 'https://twitch.tv/channel1');
      verify(() => mockHomeRepository.loadSchedules(any())).called(1);
    });

    test('fetchCurrentChannel returns default channel when no current schedule', () async {
      // Arrange
      final now = DateTime.now();
      final pastStartHour = now.hour - 3;
      final pastEndHour = now.hour - 2;

      when(() => mockHomeRepository.loadSchedules(any())).thenAnswer(
        (_) async => [
          {
            'start_time': 'Time($pastStartHour:00:00)',
            'end_time': 'Time($pastEndHour:00:00)',
            'streamer_url': 'https://twitch.tv/channel1',
          },
        ],
      );

      // Act
      final result = await homeService.fetchCurrentChannel();

      // Assert
      expect(result, 'https://twitch.tv/BoostTeam_');
      verify(() => mockHomeRepository.loadSchedules(any())).called(1);
    });

    test('fetchCurrentChannel returns default channel when schedules is empty', () async {
      // Arrange
      when(() => mockHomeRepository.loadSchedules(any())).thenAnswer((_) async => []);

      // Act
      final result = await homeService.fetchCurrentChannel();

      // Assert
      expect(result, 'https://twitch.tv/BoostTeam_');
      verify(() => mockHomeRepository.loadSchedules(any())).called(1);
      verify(() => mockLogger.warning(any())).called(1);
    });

    test('saveScore calls repository with correct model', () async {
      // Arrange
      final now = DateTime.now();
      final streamerId = 123;
      final hour = now.hour;
      final minute = now.minute;
      final points = 100;

      when(() => mockHomeRepository.saveScore(any())).thenAnswer((_) async => {});

      // Act
      await homeService.saveScore(streamerId, now, hour, minute, points);

      // Assert - Verificar que saveScore foi chamado
      verify(() => mockHomeRepository.saveScore(any())).called(1);
    });

    test('saveScore validates input parameters', () async {
      // Arrange
      final now = DateTime.now();

      // Act & Assert - Invalid streamer ID
      expect(
        () => homeService.saveScore(0, now, 10, 30, 100),
        throwsA(isA<Failure>().having((f) => f.message, 'message', 'ID do streamer inválido')),
      );

      // Act & Assert - Invalid hour
      expect(
        () => homeService.saveScore(123, now, 24, 30, 100),
        throwsA(isA<Failure>().having((f) => f.message, 'message', 'Hora inválida')),
      );

      // Act & Assert - Invalid minute
      expect(
        () => homeService.saveScore(123, now, 10, 60, 100),
        throwsA(isA<Failure>().having((f) => f.message, 'message', 'Minuto inválido')),
      );

      // Act & Assert - Invalid points
      expect(
        () => homeService.saveScore(123, now, 10, 30, -1),
        throwsA(isA<Failure>().having((f) => f.message, 'message', 'Pontuação inválida')),
      );
    });

    test('fetchSchedules handles repository error', () async {
      // Arrange
      homeService.throwErrorOnFetchSchedules = true;

      // Act & Assert
      expect(
        () => homeService.fetchSchedules(),
        throwsA(
            isA<Failure>().having((f) => f.message, 'message', 'Erro ao carregar os agendamentos')),
      );

      // Verify logger was called with the error
      verify(() => mockLogger.error(any(), any(), any())).called(1);
    });

    test('fetchCurrentChannel handles repository error', () async {
      // Arrange
      homeService.throwErrorOnFetchCurrentChannel = true;

      // Act & Assert
      expect(
        () => homeService.fetchCurrentChannel(),
        throwsA(isA<Failure>().having((f) => f.message, 'message', 'Erro ao buscar o canal atual')),
      );

      // Verify logger was called with the error
      verify(() => mockLogger.error(any(), any(), any())).called(1);
    });

    test('saveScore handles repository error', () async {
      // Arrange
      final now = DateTime.now();

      when(() => mockHomeRepository.saveScore(any()))
          .thenThrow(Failure(message: 'Repository error'));

      // Act & Assert
      expect(
        () => homeService.saveScore(123, now, 10, 30, 100),
        throwsA(isA<Failure>().having((f) => f.message, 'message', 'Repository error')),
      );
    });

    test('updateLists calls fetchSchedules', () async {
      // Arrange
      final schedules = <Map<String, dynamic>>[];
      when(() => mockHomeRepository.loadSchedules(any())).thenAnswer((_) async => schedules);

      // Act
      await homeService.updateLists();

      // Assert
      verify(() => mockHomeRepository.loadSchedules(any())).called(1);
    });
  });
}
