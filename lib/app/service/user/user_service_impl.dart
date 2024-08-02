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
  Future<void> register(String nickname, String password, String role) async {
    try {
      await _userRepository.register(nickname, password, role);
    } catch (e, s) {
      _logger.error('Failed to register user on database', e, s);
      throw Failure(message: 'Failed to register user on database');
    }
  }

  @override
  Future<void> login(String nickname, String password) async {
    try {
      final accessToken = await _userRepository.login(nickname, password);

      await _saveAccessToken(accessToken);

      await _confirmLogin();

      await _getUserData();
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
}
