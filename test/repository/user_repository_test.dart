import 'package:flutter_test/flutter_test.dart';
import 'package:boost_sys_weblurk/repositories/user/user_repository_impl.dart';
import 'package:boost_sys_weblurk/core/rest_client/rest_client.dart';
import 'package:boost_sys_weblurk/core/rest_client/rest_client_response.dart';
import 'package:boost_sys_weblurk/core/exceptions/failure.dart';
import '../mocks/app_logger_mock.dart';

// Custom implementation of RestClient for testing
class TestRestClient implements RestClient {
  final Map<String, dynamic> responses = {};
  final Map<String, dynamic> exceptions = {};
  final List<Map<String, dynamic>> calls = [];
  bool _isAuthenticated = false;

  @override
  RestClient auth() {
    _isAuthenticated = true;
    return this;
  }

  @override
  RestClient unAuth() {
    _isAuthenticated = false;
    return this;
  }

  void setResponse(String method, String path, RestClientResponse response) {
    responses['$method:$path'] = response;
  }

  void setException(String method, String path, dynamic exception) {
    exceptions['$method:$path'] = exception;
  }

  @override
  Future<RestClientResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    calls.add(
      {
        'method': 'POST',
        'path': path,
        'data': data,
        'isAuthenticated': _isAuthenticated,
      },
    );

    if (exceptions.containsKey('POST:$path')) {
      throw exceptions['POST:$path'];
    }

    return responses['POST:$path'] as RestClientResponse<T>;
  }

  @override
  Future<RestClientResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    calls.add(
      {
        'method': 'GET',
        'path': path,
        'isAuthenticated': _isAuthenticated,
      },
    );

    if (exceptions.containsKey('GET:$path')) {
      throw exceptions['GET:$path'];
    }

    return responses['GET:$path'] as RestClientResponse<T>;
  }

  @override
  Future<RestClientResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    calls.add(
      {
        'method': 'PATCH',
        'path': path,
        'data': data,
        'isAuthenticated': _isAuthenticated,
      },
    );

    if (exceptions.containsKey('PATCH:$path')) {
      throw exceptions['PATCH:$path'];
    }

    return responses['PATCH:$path'] as RestClientResponse<T>;
  }

  @override
  Future<RestClientResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    throw UnimplementedError('Not needed for these tests');
  }

  @override
  Future<RestClientResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    throw UnimplementedError('Not needed for these tests');
  }

  @override
  Future<RestClientResponse<T>> request<T>(
    String path, {
    required String method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    throw UnimplementedError('Not needed for these tests');
  }

  // Helper methods for verification
  bool wasMethodCalled(String method, String path) {
    return calls.any(
      (call) => call['method'] == method && call['path'] == path,
    );
  }

  bool wasAuthUsed(String method, String path) {
    return calls.any(
      (call) => call['method'] == method && call['path'] == path && call['isAuthenticated'] == true,
    );
  }

  bool wasUnAuthUsed(String method, String path) {
    return calls.any(
      (call) =>
          call['method'] == method && call['path'] == path && call['isAuthenticated'] == false,
    );
  }

  Map<String, dynamic>? getCallData(String method, String path) {
    final call = calls.firstWhere(
      (call) => call['method'] == method && call['path'] == path,
      orElse: () => {},
    );
    return call['data'];
  }
}

void main() {
  late UserRepositoryImpl userRepository;
  late TestRestClient restClient;
  late MockAppLogger logger;

  setUp(
    () {
      restClient = TestRestClient();
      logger = MockAppLogger();

      userRepository = UserRepositoryImpl(
        restClient: restClient,
        logger: logger,
      );
    },
  );

  group(
    'UserRepository',
    () {
      test(
        'login success returns access token',
        () async {
          // Arrange
          restClient.setResponse(
            'POST',
            '/auth/login',
            RestClientResponse(
              data: {'access_token': 'test_token'},
              statusCode: 200,
            ),
          );

          // Act
          final result = await userRepository.login('testuser', 'password123');

          // Assert
          expect(result, 'test_token');
          expect(restClient.wasUnAuthUsed('POST', '/auth/login'), true);
          expect(
            restClient.getCallData('POST', '/auth/login'),
            {
              'nickname': 'testuser',
              'password': 'password123',
            },
          );
        },
      );

      test(
        'login failure throws exception',
        () async {
          // Arrange
          restClient.setException(
            'POST',
            '/auth/login',
            Exception('Failed to login'),
          );

          // Act & Assert
          expect(
            () => userRepository.login('testuser', 'password123'),
            throwsA(isA<Failure>()),
          );
        },
      );

      test(
        'confirmLogin returns model with tokens',
        () async {
          // Arrange
          restClient.setResponse(
            'PATCH',
            '/auth/confirm',
            RestClientResponse(
              data: {'access_token': 'new_token', 'refresh_token': 'refresh_token'},
              statusCode: 200,
            ),
          );

          // Act
          final result = await userRepository.confirmLogin();

          // Assert
          expect(result.accessToken, 'new_token');
          expect(result.refreshToken, 'refresh_token');
          expect(restClient.wasAuthUsed('PATCH', '/auth/confirm'), true);
        },
      );

      test(
        'getUserLogged returns user model',
        () async {
          // Arrange
          restClient.setResponse(
            'GET',
            '/user/',
            RestClientResponse(
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
          expect(restClient.wasAuthUsed('GET', '/user/'), true);
        },
      );

      test(
        'updateLoginStatus calls correct endpoint',
        () async {
          // Arrange
          restClient.setResponse(
            'POST',
            '/streamer/status/update',
            RestClientResponse(
              statusCode: 200,
            ),
          );

          // Act
          await userRepository.updateLoginStatus(1, 'ON');

          // Assert
          expect(restClient.wasAuthUsed('POST', '/streamer/status/update'), true);
          expect(
            restClient.getCallData('POST', '/streamer/status/update'),
            {
              'streamerId': 1,
              'status': 'ON',
            },
          );
        },
      );
    },
  );
}
