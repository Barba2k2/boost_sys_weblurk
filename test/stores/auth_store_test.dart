import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:modular_test/modular_test.dart';
import 'package:boost_sys_weblurk/app/modules/core/auth/auth_store.dart';
import 'package:boost_sys_weblurk/app/core/local_storage/local_storage.dart';
import 'package:boost_sys_weblurk/app/core/helpers/constants.dart';
import 'package:boost_sys_weblurk/app/core/logger/app_logger.dart';

// Simple mock implementation for LocalStorage
class TestLocalStorage implements LocalStorage {
  final Map<String, dynamic> storage = {};
  final List<String> removedKeys = [];

  @override
  Future<T?> read<T>(String key) async {
    return storage[key] as T?;
  }

  @override
  Future<void> write<T>(String key, T value) async {
    storage[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    storage.remove(key);
    removedKeys.add(key);
  }

  @override
  Future<bool> contains(String key) async {
    return storage.containsKey(key);
  }

  Future<void> clearAll() async {
    storage.clear();
  }

  @override
  Future<void> clear() async {
    storage.clear();
  }
}

// Simple mock implementation for AppLogger
class TestAppLogger implements AppLogger {
  final List<String> logs = [];

  @override
  void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logs.add('DEBUG: $message');
  }

  @override
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logs.add('ERROR: $message');
  }

  @override
  void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logs.add('WARNING: $message');
  }

  @override
  void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logs.add('INFO: $message');
  }

  @override
  void append(dynamic message) {
    logs.add('APPEND: $message');
  }

  @override
  void closeAppend() {
    logs.add('CLOSE_APPEND');
  }

  @override
  void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logs.add('FATAL: $message');
  }
}

// Test module for dependency injection
class TestModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.instance<AppLogger>(
          TestAppLogger(),
        ),
      ];
}

void main() {
  late AuthStore authStore;
  late TestLocalStorage localStorage;
  late TestAppLogger logger;

  setUpAll(
    () {
      // Initialize modular for testing
      initModule(
        TestModule(),
      );
      logger = Modular.get<AppLogger>() as TestAppLogger;
    },
  );

  setUp(
    () {
      // Reset the test state
      localStorage = TestLocalStorage();
      authStore = AuthStore(localStorage: localStorage);
      logger.logs.clear();
    },
  );

  group(
    'AuthStore',
    () {
      test(
        'logout should remove all user data from localStorage',
        () async {
          // Act
          await authStore.logout();

          // Assert
          expect(
            localStorage.removedKeys,
            contains(Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY),
          );
          expect(
            localStorage.removedKeys,
            contains(Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY),
          );
          expect(
            localStorage.removedKeys,
            contains(Constants.LOCAL_SOTRAGE_USER_LOGGED_STATUS_KEY),
          );
          expect(
            logger.logs.any(
              (log) => log.contains('Logout realizado com sucesso'),
            ),
            isTrue,
          );
        },
      );

      test(
        'loadUserLogged should call logout on first initialization',
        () async {
          // Act
          await authStore.loadUserLogged();

          // Assert - verify that the keys were removed during logout
          expect(
            localStorage.removedKeys,
            contains(Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY),
          );
          expect(
            localStorage.removedKeys,
            contains(Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY),
          );
          expect(
            localStorage.removedKeys,
            contains(Constants.LOCAL_SOTRAGE_USER_LOGGED_STATUS_KEY),
          );
          expect(
            logger.logs.any(
              (log) => log.contains('Primeira inicialização'),
            ),
            isTrue,
          );
        },
      );
    },
  );
}
