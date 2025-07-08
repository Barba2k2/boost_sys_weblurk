import 'package:flutter_test/flutter_test.dart';
import 'package:boost_sys_weblurk/app/repositories/user/user_repository.dart';
import 'package:boost_sys_weblurk/app/repositories/user/user_repository_impl.dart';
import 'package:boost_sys_weblurk/app/core/rest_client/rest_client.dart';
import 'package:boost_sys_weblurk/app/core/rest_client/rest_client_response.dart';
import 'package:boost_sys_weblurk/app/core/logger/app_logger.dart';
import 'package:boost_sys_weblurk/app/models/user_model.dart';
import 'package:boost_sys_weblurk/app/models/confirm_login_model.dart';
import 'package:mockito/mockito.dart';

class MockRestClient extends Mock implements RestClient {}

class MockAppLogger extends Mock implements AppLogger {}

void main() {
  group('User Repository Tests', () {
    late UserRepository userRepository;
    late MockRestClient mockRestClient;
    late MockAppLogger mockLogger;

    setUp(() {
      mockRestClient = MockRestClient();
      mockLogger = MockAppLogger();

      userRepository = UserRepositoryImpl(
        restClient: mockRestClient,
        logger: mockLogger,
      );
    });

    test('should login successfully', () async {
      // Arrange
      const username = 'testuser';
      const password = 'password123';
      const token = 'valid_token';

      when(mockRestClient.unAuth()).thenReturn(mockRestClient);
      when(mockRestClient.post('/auth/login', data: anyNamed('data')))
          .thenAnswer(
              (_) async => RestClientResponse(data: {'access_token': token}));

      // Act
      final result = await userRepository.login(username, password);

      // Assert
      expect(result, equals(token));
      verify(mockRestClient.unAuth()).called(1);
      verify(mockRestClient.post('/auth/login', data: {
        'nickname': username,
        'password': password,
      })).called(1);
    });

    test('should confirm login successfully', () async {
      // Arrange
      final confirmData = {
        'access_token': 'new_token',
        'refresh_token': 'refresh_token',
      };

      when(mockRestClient.auth()).thenReturn(mockRestClient);
      when(mockRestClient.patch('/auth/confirm', data: anyNamed('data')))
          .thenAnswer((_) async => RestClientResponse(data: confirmData));

      // Act
      final result = await userRepository.confirmLogin();

      // Assert
      expect(result, isA<ConfirmLoginModel>());
      verify(mockRestClient.auth()).called(1);
      verify(mockRestClient.patch('/auth/confirm', data: anyNamed('data')))
          .called(1);
    });

    test('should get user logged successfully', () async {
      // Arrange
      final userData = {
        'id': 1,
        'nickname': 'testuser',
        'role': 'user',
        'status': 'ON',
      };

      when(mockRestClient.auth()).thenReturn(mockRestClient);
      when(mockRestClient.get('/user/'))
          .thenAnswer((_) async => RestClientResponse(data: userData));

      // Act
      final result = await userRepository.getUserLogged();

      // Assert
      expect(result, isA<UserModel>());
      expect(result.id, equals(1));
      expect(result.nickname, equals('testuser'));
      verify(mockRestClient.auth()).called(1);
      verify(mockRestClient.get('/user/')).called(1);
    });

    test('should update login status successfully', () async {
      // Arrange
      const userId = 1;
      const status = 'ON';

      when(mockRestClient.auth()).thenReturn(mockRestClient);
      when(mockRestClient.post('/streamer/status/update',
              data: anyNamed('data')))
          .thenAnswer((_) async => RestClientResponse(data: {}));

      // Act
      await userRepository.updateLoginStatus(userId, status);

      // Assert
      verify(mockRestClient.auth()).called(1);
      verify(mockRestClient.post('/streamer/status/update', data: {
        'streamerId': userId,
        'status': status,
      })).called(1);
    });
  });
}
