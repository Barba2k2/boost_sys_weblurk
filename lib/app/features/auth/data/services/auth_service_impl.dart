import '../../../../core/logger/app_logger.dart';
import '../../../../core/rest_client/rest_client.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/services/auth_service.dart';

class AuthServiceImpl implements AuthService {
  AuthServiceImpl({
    required RestClient restClient,
    required AppLogger logger,
  })  : _restClient = restClient,
        _logger = logger;

  final RestClient _restClient;
  final AppLogger _logger;

  @override
  Future<UserEntity> login(String username, String password) async {
    _logger.info('Fazendo login para usuário: $username');
    final response = await _restClient.post('/auth/login', data: {
      'nickname': username,
      'password': password,
    });
    return UserEntity.fromJson(response.data);
  }

  @override
  Future<void> logout() async {
    _logger.info('Fazendo logout');
    await _restClient.post('/auth/logout');
  }

  @override
  Future<bool> checkLoginStatus() async {
    _logger.info('Verificando status do login');
    final response = await _restClient.get('/auth/status');
    return response.data['isLoggedIn'] as bool;
  }
} 