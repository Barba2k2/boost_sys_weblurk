import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boost_sys_weblurk/core/local_storage/shared_preferences/shared_preferences_local_storage_impl.dart';

void main() {
  late SharedPreferencesLocalStorageImpl localStorage;

  setUp(
    () {
      SharedPreferences.setMockInitialValues(
        {},
      );
      localStorage = SharedPreferencesLocalStorageImpl();
    },
  );

  group(
    'SharedPreferencesLocalStorageImpl',
    () {
      test(
        'write and read string',
        () async {
          await localStorage.write('test_key', 'test_value');
          final result = await localStorage.read<String>('test_key');

          expect(result, 'test_value');
        },
      );

      test(
        'write and read int',
        () async {
          await localStorage.write('test_key', 42);
          final result = await localStorage.read<int>('test_key');

          expect(result, 42);
        },
      );

      test(
        'write and read bool',
        () async {
          await localStorage.write('test_key', true);
          final result = await localStorage.read<bool>('test_key');

          expect(result, true);
        },
      );

      test(
        'contains returns true when key exists',
        () async {
          await localStorage.write('test_key', 'test_value');

          final result = await localStorage.contains('test_key');

          expect(result, true);
        },
      );

      test(
        'contains returns false when key does not exist',
        () async {
          final result = await localStorage.contains('nonexistent_key');

          expect(result, false);
        },
      );

      test(
        'remove deletes key',
        () async {
          await localStorage.write('test_key', 'test_value');

          await localStorage.remove('test_key');
          final exists = await localStorage.contains('test_key');

          expect(exists, false);
        },
      );

      test(
        'clear removes all keys',
        () async {
          await localStorage.write('key1', 'value1');
          await localStorage.write('key2', 'value2');

          await localStorage.clear();
          final key1Exists = await localStorage.contains('key1');
          final key2Exists = await localStorage.contains('key2');

          expect(key1Exists, false);
          expect(key2Exists, false);
        },
      );

      test(
        'throws exception for unsupported type',
        () async {
          expect(
            () => localStorage.write(
              'test_key',
              DateTime.now(),
            ),
            throwsException,
          );
        },
      );
    },
  );
}
