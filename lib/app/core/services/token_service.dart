import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const String _tokenKey = 'device_token';

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_tokenKey);

    if (token == null) {
      token = _generateToken();
      await prefs.setString(_tokenKey, token);
    }

    return token;
  }

  String _generateToken() {
    var uuid = const Uuid();
    return uuid.v4();
  }
}
