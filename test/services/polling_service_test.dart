import 'package:flutter_test/flutter_test.dart';
import 'package:boost_sys_weblurk/app/features/home/domain/usecases/start_polling_usecase.dart';
import 'package:boost_sys_weblurk/app/features/home/domain/usecases/stop_polling_usecase.dart';
import 'package:boost_sys_weblurk/app/features/home/domain/repositories/home_repository.dart';
import 'package:boost_sys_weblurk/app/core/logger/app_logger.dart';
import 'package:boost_sys_weblurk/app/utils/result.dart';
import 'package:mockito/mockito.dart';

class MockHomeRepository extends Mock implements HomeRepository {}
class MockAppLogger extends Mock implements AppLogger {}

void main() {
  group('Polling Service Tests', () {
    late StartPollingUseCase startPollingUseCase;
    late StopPollingUseCase stopPollingUseCase;
    late MockHomeRepository mockHomeRepository;
    late MockAppLogger mockLogger;

    setUp(() {
      mockHomeRepository = MockHomeRepository();
      mockLogger = MockAppLogger();

      startPollingUseCase = StartPollingUseCase(
        repository: mockHomeRepository,
        logger: mockLogger,
      );
      stopPollingUseCase = StopPollingUseCase(
        repository: mockHomeRepository,
        logger: mockLogger,
      );
    });

    test('should start polling successfully', () async {
      // Arrange
      when(mockHomeRepository.startPolling(any))
          .thenAnswer((_) async => Result.ok(null));

      // Act
      final result = await startPollingUseCase.startPolling(1);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockHomeRepository.startPolling(1)).called(1);
    });

    test('should stop polling successfully', () async {
      // Arrange
      when(mockHomeRepository.stopPolling())
          .thenAnswer((_) async => Result.ok(null));

      // Act
      final result = await stopPollingUseCase.stopPolling();

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockHomeRepository.stopPolling()).called(1);
    });

    test('should handle polling start error', () async {
      // Arrange
      when(mockHomeRepository.startPolling(any)).thenAnswer(
        (_) async => Result.error(Exception('Polling start failed')),
      );

      // Act
      final result = await startPollingUseCase.startPolling(1);

      // Assert
      expect(result.isError, isTrue);
      expect(result.asErrorValue.toString(), contains('Polling start failed'));
    });

    test('should handle polling stop error', () async {
      // Arrange
      when(mockHomeRepository.stopPolling()).thenAnswer(
        (_) async => Result.error(Exception('Polling stop failed')),
      );

      // Act
      final result = await stopPollingUseCase.stopPolling();

      // Assert
      expect(result.isError, isTrue);
      expect(result.asErrorValue.toString(), contains('Polling stop failed'));
    });
  });
}
