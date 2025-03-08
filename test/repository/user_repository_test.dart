import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:boost_sys_weblurk/app/repositories/user/user_repository_impl.dart';
import 'package:boost_sys_weblurk/app/core/rest_client/rest_client.dart';
import 'package:boost_sys_weblurk/app/core/rest_client/rest_client_response.dart';
import 'package:boost_sys_weblurk/app/core/logger/app_logger.dart';
import 'package:boost_sys_weblurk/app/core/exceptions/failure.dart';

class MockRestClient extends Mock implements RestClient {}

class MockAppLogger extends Mock implements AppLogger {}

void main() {
  late UserRepositoryImpl userRepository;
  late MockRestClient mockRestClient;
  late MockAppLogger mockLogger;

  setUp(
    () {
      mockRestClient = MockRestClient();
      mockLogger = MockAppLogger();

      userRepository = UserRepositoryImpl(
        restClient: mockRestClient,
        logger: mockLogger,
      );

      // Configurar o comportamento padrão do RestClient
      when(
        mockRestClient.unAuht(),
      ).thenReturn(mockRestClient);
      when(
        mockRestClient.auth(),
      ).thenReturn(mockRestClient);
    },
  );

  group(
    'UserRepository',
    () {
      test(
        'login success returns access token',
        () async {
          // Arrange
          when(
            mockRestClient.post(
              '/auth/login',
              data: anyNamed('data'),
            ),
          ).thenAnswer(
            (_) async => RestClientResponse(
              data: {'access_token': 'test_token'},
              statusCode: 200,
            ),
          );

          // Act
          final result = await userRepository.login('testuser', 'password123');

          // Assert
          expect(result, 'test_token');
          verify(
            mockRestClient.unAuht(),
          ).called(1);
        },
      );

      test(
        'login failure throws exception',
        () async {
          // Arrange
          when(
            mockRestClient.post(
              '/auth/login',
              data: anyNamed('data'),
            ),
          ).thenThrow(
            Exception('Failed to login'),
          );

          // Act & Assert
          expect(
              () => userRepository.login('testuser', 'password123'),
              throwsA(
                isA<Failure>(),
              ));
        },
      );

      test(
        'confirmLogin returns model with tokens',
        () async {
          // Arrange
          when(
            mockRestClient.patch(
              '/auth/confirm',
              data: anyNamed('data'),
            ),
          ).thenAnswer(
            (_) async => RestClientResponse(
              data: {'access_token': 'new_token', 'refresh_token': 'refresh_token'},
              statusCode: 200,
            ),
          );

          // Act
          final result = await userRepository.confirmLogin();

          // Assert
          expect(result.accessToken, 'new_token');
          expect(result.refreshToken, 'refresh_token');
          verify(
            mockRestClient.auth(),
          ).called(1);
        },
      );

      test(
        'getUserLogged returns user model',
        () async {
          // Arrange
          when(
            mockRestClient.get('/user/'),
          ).thenAnswer(
            (_) async => RestClientResponse(
              data: {'id': 1, 'nickname': 'testuser', 'role': 'user', 'status': 'ON'},
              statusCode: 200,
            ),
          );

          // Act
          final result = await userRepository.getUserLogged();

          // Assert
          expect(result.id, 1);
          expect(result.nickname, 'testuser');
          expect(result.role, 'user');
          expect(result.status, 'ON');
          verify(
            mockRestClient.auth(),
          ).called(1);
        },
      );

      test(
        'updateLoginStatus calls correct endpoint',
        () async {
          // Arrange
          when(
            mockRestClient.post(
              '/streamer/status/update',
              data: anyNamed('data'),
            ),
          ).thenAnswer(
            (_) async => RestClientResponse(
              statusCode: 200,
            ),
          );

          // Act
          await userRepository.updateLoginStatus(1, 'ON');

          // Assert
          verify(
            mockRestClient.post(
              '/streamer/status/update',
              data: {
                'streamerId': 1,
                'status': 'ON',
              },
            ),
          ).called(1);
        },
      );
    },
  );
}
