import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:boost_sys_weblurk/app/modules/core/auth/auth_store.dart';
import 'package:boost_sys_weblurk/app/core/local_storage/local_storage.dart';
import 'package:boost_sys_weblurk/app/core/helpers/constants.dart';
import 'package:boost_sys_weblurk/app/core/logger/app_logger.dart';
import 'package:boost_sys_weblurk/app/models/user_model.dart';

class MockLocalStorage extends Mock implements LocalStorage {}

class MockAppLogger extends Mock implements AppLogger {}

// Create a testable version of AuthStore that doesn't use Modular.get
class TestableAuthStore extends AuthStoreBase {
  final AppLogger logger;

  TestableAuthStore({
    required LocalStorage localStorage,
    required this.logger,
  }) : super(localStorage: localStorage);

  // This is used instead of Modular.get<AppLogger>()
  @override
  AppLogger get _logger => logger;

  // Expose setter for testing
  set userLogged(UserModel? user) {
    _userLogged = user;
  }
}

void main() {
  late TestableAuthStore authStore;
  late MockLocalStorage mockLocalStorage;
  late MockAppLogger mockLogger;

  setUp(() {
    mockLocalStorage = MockLocalStorage();
    mockLogger = MockAppLogger();

    // Initialize Modular for the test
    Modular.init(TestModule());

    authStore = TestableAuthStore(
      localStorage: mockLocalStorage,
      logger: mockLogger,
    );
  });

  group('AuthStore', () {
    test('logout removes data from localStorage', () async {
      // Arrange - configurado no setUp

      // Act
      await authStore.logout();

      // Assert
      verify(
        mockLocalStorage.remove(Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY),
      ).called(1);
      verify(
        mockLocalStorage.remove(Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY),
      ).called(1);
      verify(
        mockLocalStorage.remove(Constants.LOCAL_SOTRAGE_USER_LOGGED_STATUS_KEY),
      ).called(1);
    });

    test('loadUserLogged sets user when valid data exists', () async {
      // Arrange
      final userJson = json.encode(
        {
          'id': 1,
          'nickname': 'testuser',
          'role': 'user',
          'status': 'ON',
        },
      );

      when(
        mockLocalStorage.read<String>(Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY),
      ).thenAnswer(
        (_) async => userJson,
      );
      when(
        mockLocalStorage.read<String>(Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY),
      ).thenAnswer(
        (_) async => 'validToken',
      );

      // Act
      await authStore.loadUserLogged();

      // Assert
      expect(authStore.userLogged, isNotNull);
      expect(authStore.userLogged?.nickname, 'testuser');
    });

    test('loadUserLogged calls logout when token is missing', () async {
      // Arrange
      final userJson = json.encode(
        {
          'id': 1,
          'nickname': 'testuser',
          'role': 'user',
          'status': 'ON',
        },
      );

      when(
        mockLocalStorage.read<String>(Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY),
      ).thenAnswer(
        (_) async => userJson,
      );
      when(
        mockLocalStorage.read<String>(Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY),
      ).thenAnswer(
        (_) async => null,
      );

      // Act
      await authStore.loadUserLogged();

      // Assert
      expect(authStore.userLogged, isNull);
      verify(
        mockLocalStorage.remove(Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY),
      ).called(1);
    });

    test('updateUserStatus updates user status', () async {
      // Arrange
      final user = UserModel(
        id: 1,
        nickname: 'testuser',
        role: 'user',
        status: 'OFF',
      );

      // Configurar o estado inicial
      authStore.userLogged = user;

      // Act
      await authStore.updateUserStatus('ON');

      // Assert
      expect(authStore.userLogged?.status, 'ON');
      verify(
        mockLocalStorage.write(Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY, any),
      ).called(1);
    });
  });
}

// Test module to provide dependencies
class TestModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.instance<AppLogger>(MockAppLogger()),
      ];
}
