import '../../core/exceptions/failure.dart';
import '../../core/helpers/constants.dart';
import '../../core/local_storage/local_storage.dart';
import '../../core/logger/app_logger.dart';
import '../../core/services/error_message_service.dart';
import '../../repositories/user/user_repository.dart';
import 'user_service.dart';

class UserServiceImpl implements UserService {
  UserServiceImpl({
    required UserRepository userRepository,
    required AppLogger logger,
    required LocalStorage localStorage,
    required LocalSecureStorage localSecureStorage,
  })  : _logger = logger,
        _userRepository = userRepository,
        _localStorage = localStorage,
        _localSecureStorage = localSecureStorage;

  final UserRepository _userRepository;
  final AppLogger _logger;
  final LocalStorage _localStorage;
  final LocalSecureStorage _localSecureStorage;

  @override
  Future<void> register(String nickname, String password) async {
    try {
      await _userRepository.register(nickname, password);
    } catch (e, s) {
      _logger.error('Service - Failed to register user', e, s);

      final userFriendlyMessage =
          ErrorMessageService.instance.extractUserFriendlyMessage(e);
      throw Failure(message: userFriendlyMessage);
    }
  }

  @override
  Future<void> login(String nickname, String password) async {
    try {
      final accessToken = await _userRepository.login(nickname, password);
      await _saveAccessToken(accessToken);

      final confirmLoginModel = await _userRepository.confirmLogin();
      await _saveAccessToken(confirmLoginModel.accessToken);
      await _localSecureStorage.write(
        Constants.LOCAL_SOTRAGE_REFRESH_TOKEN_KEY,
        confirmLoginModel.refreshToken,
      );

      final userModel = await _userRepository.getUserLogged();
      await _localStorage.write<String>(
        Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY,
        userModel.toJson(),
      );

      // Update login status in background - don't block login if this fails
      _updateLoginStatus('ON').catchError((e) {
        _logger.error('Failed to update login status (non-blocking)', e);
      });
    } catch (e, s) {
      _logger.error('Service - Failed to login user', e, s);

      await _clearAllData();

      final userFriendlyMessage =
          ErrorMessageService.instance.extractUserFriendlyMessage(e);
      throw Failure(message: userFriendlyMessage);
    }
  }

  Future<void> _clearAllData() async {
    try {
      await _localStorage.remove(Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY);
      await _localStorage.remove(Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY);
      await _localStorage.remove(
        Constants.LOCAL_SOTRAGE_USER_LOGGED_STATUS_KEY,
      );
    } catch (e) {
      _logger.error('Error clearing local storage data', e);
    }

    try {
      await _localSecureStorage.remove(
        Constants.LOCAL_SOTRAGE_REFRESH_TOKEN_KEY,
      );
    } catch (e) {
      _logger.error('Error clearing secure storage data', e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      try {
        await _updateLoginStatus('OFF');
        await _saveLastSeen();
      } catch (e) {
        _logger.error('Error updating status during logout', e);
      }

      await _clearAllData();
    } catch (e, s) {
      _logger.error('Service - Failed to logout user', e, s);
      throw Failure(message: 'Failed to logout user');
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
      throw Failure(message: 'Failed to save access token');
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

      if (token != null) {
        final userData = await _localStorage.read(
          Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY,
        );

        if (userData == null) {
          await _clearAllData();
          return null;
        }

        return token;
      }
      return null;
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
