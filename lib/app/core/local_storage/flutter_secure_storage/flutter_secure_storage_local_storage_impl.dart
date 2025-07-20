import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../local_storage.dart';

class FlutterSecureStorageLocalStorageImpl implements LocalSecureStorage {
  FlutterSecureStorage get _instance => const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      );

  @override
  Future<void> clear() async {
    try {
      await _instance.deleteAll();
    } catch (e) {
      // No macOS, pode haver problemas de permissão
      // Mas não devemos falhar por isso
    }
  }

  @override
  Future<bool> contains(String key) async {
    try {
      return await _instance.containsKey(key: key);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      return await _instance.read(key: key);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> remove(String key) async {
    try {
      await _instance.delete(key: key);
    } catch (e) {
      // No macOS, pode haver problemas de permissão
      // Mas não devemos falhar por isso
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await _instance.write(key: key, value: value);
    } catch (e) {
      // No macOS, pode haver problemas de permissão
      // Mas não devemos falhar por isso
    }
  }
}
