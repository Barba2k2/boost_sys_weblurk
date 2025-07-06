import 'package:flutter_test/flutter_test.dart';
import 'package:boost_sys_weblurk/app/features/home/domain/usecases/initialize_home_usecase.dart';
import 'package:boost_sys_weblurk/app/features/home/domain/repositories/home_repository.dart';
import 'package:boost_sys_weblurk/app/utils/result.dart';
import 'package:mockito/mockito.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  group('Home Service Tests', () {
    late InitializeHomeUseCase initializeHomeUseCase;
    late MockHomeRepository mockHomeRepository;

    setUp(() {
      mockHomeRepository = MockHomeRepository();

      initializeHomeUseCase = InitializeHomeUseCase(mockHomeRepository);
    });

    test('should initialize home successfully', () async {
      // Arrange
      when(mockHomeRepository.initializeHome())
          .thenAnswer((_) async => Result.ok(null));

      // Act
      final result = await initializeHomeUseCase.execute();

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockHomeRepository.initializeHome()).called(1);
    });

    test('should handle initialization error', () async {
      // Arrange
      when(mockHomeRepository.initializeHome()).thenAnswer(
        (_) async => Result.error(Exception('Initialization failed')),
      );

      // Act
      final result = await initializeHomeUseCase.execute();

      // Assert
      expect(result.isError, isTrue);
      expect(result.asErrorValue.toString(), contains('Initialization failed'));
    });
  });
}
