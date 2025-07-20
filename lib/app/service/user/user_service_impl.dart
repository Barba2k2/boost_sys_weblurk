import '../../core/exceptions/failure.dart';
import '../../core/helpers/constants.dart';
import '../../core/local_storage/local_storage.dart';
import '../../core/logger/app_logger.dart';
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

      await _updateLoginStatus('ON');
      _logger.info(
        'Login completo realizado com sucesso: ${userModel.nickname}',
      );
    } catch (e, s) {
      _logger.error('Service - Failed to login user', e, s);

      await _clearAllData();

      // Fornecer mensagens de erro mais específicas
      if (e.toString().contains('Connection failed') ||
          e.toString().contains('Operation not permitted')) {
        throw Failure(
            message:
                'Erro de conexão com o servidor. Verifique sua conexão com a internet.');
      } else if (e.toString().contains('User not exists')) {
        throw Failure(
            message: 'Usuário não encontrado. Verifique suas credenciais.');
      } else if (e.toString().contains('Token de acesso não encontrado')) {
        throw Failure(
            message: 'Erro na resposta do servidor. Tente novamente.');
      } else {
        throw Failure(message: 'Erro ao realizar login. Tente novamente.');
      }
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
      // No macOS, pode haver problemas de permissão com flutter_secure_storage
      // Mas não devemos falhar o login por isso
    }
  }

  @override
  Future<void> logout() async {
    try {
      try {
        await _updateLoginStatus('OFF');
        await _saveLastSeen();
      } catch (e) {
        _logger.warning('Error updating status during logout', e);
      }

      await _clearAllData();
      _logger.info('Logout completed successfully');
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
      _logger.info('Access token saved successfully');
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
      _logger.info('Login status updated to: $status');
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
          _logger.warning('Token found but no user data');
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
