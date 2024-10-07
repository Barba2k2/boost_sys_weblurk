import '../../core/exceptions/failure.dart';
import '../../core/helpers/constants.dart';
import '../../core/local_storage/local_storage.dart';
import '../../core/logger/app_logger.dart';
import '../../repositories/user/user_repository.dart';
import 'user_service.dart';

class UserServiceImpl implements UserService {
  final UserRepository _userRepository;
  final AppLogger _logger;
  final LocalStorage _localStorage;
  final LocalSecureStorage _localSecureStorage;

  UserServiceImpl({
    required UserRepository userRepository,
    required AppLogger logger,
    required LocalStorage localStorage,
    required LocalSecureStorage localSecureStorage,
  })  : _logger = logger,
        _userRepository = userRepository,
        _localStorage = localStorage,
        _localSecureStorage = localSecureStorage;

  @override
  Future<void> login(String nickname, String password) async {
    try {
      final accessToken = await _userRepository.login(nickname, password);

      await _saveAccessToken(accessToken);

      await _confirmLogin();

      await _getUserData();

      await _updateLoginStatus('ON');
    } catch (e, s) {
      _logger.error('Service - Failed to login user', e, s);
      throw Failure(message: 'Failed to login user');
    }
  }

  Future<void> _saveAccessToken(String accessToken) async {
    try {
      await _localStorage.write(
        Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY,
        accessToken,
      );
    } catch (e, s) {
      _logger.error('Failed to save access token on local storage', e, s);
    }
  }

  Future<void> _confirmLogin() async {
    try {
      final confirmLoginModel = await _userRepository.confirmLogin();

      await _saveAccessToken(confirmLoginModel.accessToken);

      await _localSecureStorage.write(
        Constants.LOCAL_SOTRAGE_REFRESH_TOKEN_KEY,
        confirmLoginModel.refreshToken,
      );
    } catch (e, s) {
      _logger.error('Failed to confirm login', e, s);
      throw Failure(message: 'Failed to confirm login');
    }
  }

  Future<void> _getUserData() async {
    try {
      final userModel = await _userRepository.getUserLogged();

      await _localStorage.write<String>(
        Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY,
        userModel.toJson(),
      );
    } catch (e, s) {
      _logger.error('Failed to get user data', e, s);
      throw Failure(message: 'Failed to get user data');
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Atualizar o status para 'OFF' e registrar o horário de logout
      await _updateLoginStatus('OFF');
      await _saveLastSeen();

      // Limpar tokens e dados do usuário
      await _localStorage.remove(Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY);
      await _localSecureStorage.remove(
        Constants.LOCAL_SOTRAGE_REFRESH_TOKEN_KEY,
      );
      await _localStorage.remove(
        Constants.LOCAL_SOTRAGE_USER_LOGGED_STATUS_KEY,
      );
    } catch (e, s) {
      _logger.error('Service - Failed to logout user', e, s);
      throw Failure(message: 'Failed to logout user');
    }
  }

  Future<void> _updateLoginStatus(String status) async {
    try {
      final userModel = await _userRepository.getUserLogged();
      await _userRepository.updateLoginStatus(userModel.id, status);
      await _saveLastSeen();
    } catch (e, s) {
      _logger.error('Failed to update login status', e, s);
      throw Failure(message: 'Failed to update login status');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      final token = await _localStorage.read(
        Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY,
      );
      return token;
    } catch (e, s) {
      _logger.error('Failed to get token from local storage', e, s);
      return null;
    }
  }

  Future<void> _saveLastSeen() async {
    try {
      await _userRepository.getUserLogged();
    } catch (e, s) {
      _logger.error('Failed to save last seen time', e, s);
      throw Failure(message: 'Failed to save last seen time');
    }
  }
}
