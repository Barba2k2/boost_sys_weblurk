import 'package:flutter_test/flutter_test.dart';
import 'package:boost_sys_weblurk/app/features/auth/domain/entities/auth_store.dart';
import 'package:boost_sys_weblurk/app/models/user_model.dart';
import 'package:boost_sys_weblurk/app/core/local_storage/local_storage.dart';
import 'package:boost_sys_weblurk/app/core/helpers/constants.dart';
import 'package:boost_sys_weblurk/app/core/logger/app_logger.dart';
import 'package:mockito/mockito.dart';

class MockLocalStorage extends Mock implements LocalStorage {}

class MockAppLogger extends Mock implements AppLogger {}

void main() {
  group('AuthStore Tests', () {
    late AuthStore authStore;
    late MockLocalStorage mockLocalStorage;
    late MockAppLogger mockLogger;

    setUp(() {
      mockLocalStorage = MockLocalStorage();
      mockLogger = MockAppLogger();
      authStore = AuthStore(
        localStorage: mockLocalStorage,
        logger: mockLogger,
      );
    });

    test('should initialize with null user', () {
      expect(authStore.userLogged, isNull);
    });

    test('should set user logged', () async {
      final user = UserModel(
        id: 1,
        nickname: 'testuser',
        role: 'user',
        status: 'ON',
      );

      await authStore.setUserLogged(user);

      expect(authStore.userLogged, equals(user));
    });

    test('should clear user logged', () async {
      final user = UserModel(
        id: 1,
        nickname: 'testuser',
        role: 'user',
        status: 'ON',
      );

      await authStore.setUserLogged(user);
      expect(authStore.userLogged, equals(user));

      await authStore.clearUserLogged();
      expect(authStore.userLogged, isNull);
    });

    test('should load user from storage', () async {
      final userJson =
          '{"id":1,"nickname":"testuser","role":"user","status":"ON"}';
      when(mockLocalStorage
              .read<String>(Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY))
          .thenAnswer((_) async => userJson);

      await authStore.loadUserLogged();

      expect(authStore.userLogged?.id, equals(1));
      expect(authStore.userLogged?.nickname, equals('testuser'));
      expect(authStore.userLogged?.role, equals('user'));
      expect(authStore.userLogged?.status, equals('ON'));
    });

    test('should handle null user from storage', () async {
      when(mockLocalStorage
              .read<String>(Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY))
          .thenAnswer((_) async => null);

      await authStore.loadUserLogged();

      expect(authStore.userLogged, isNull);
    });

    test('should save user to storage', () async {
      final user = UserModel(
        id: 1,
        nickname: 'testuser',
        role: 'user',
        status: 'ON',
      );

      await authStore.setUserLogged(user);

      verify(mockLocalStorage.write(
        Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY,
        any,
      )).called(1);
    });

    test('should remove user from storage', () async {
      await authStore.clearUserLogged();

      verify(mockLocalStorage
              .remove(Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY))
          .called(1);
    });
  });
}
