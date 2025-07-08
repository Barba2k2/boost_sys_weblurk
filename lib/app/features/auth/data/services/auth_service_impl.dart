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
  Future<Map<String, dynamic>> login(String nickname, String password) async {
    _logger.info('Fazendo login para usuário: $nickname');
    final response = await _restClient.post('/auth/login', data: {
      'nickname': nickname,
      'password': password,
    });
    
    final userEntity = UserEntity.fromJson(response.data);
    final accessToken = response.data['access_token'] as String?;
    
    return {
      'user': userEntity,
      'access_token': accessToken,
    };
  }

  @override
  Future<Map<String, String>> confirmLogin(String accessToken, String windowsToken) async {
    _logger.info('Confirmando login com windows_token');
    _logger.info('Access token: $accessToken');
    _logger.info('Windows token: $windowsToken');
    
    final response = await _restClient.unAuth().patch(
      '/auth/confirm',
      data: {
        'windows_token': windowsToken,
      },
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    
    final newAccessToken = response.data['access_token'] as String?;
    final refreshToken = response.data['refresh_token'] as String?;
    
    _logger.info('Login confirmado com sucesso');
    _logger.info('Novo access token: ${newAccessToken?.substring(0, 20)}...');
    _logger.info('Refresh token: ${refreshToken?.substring(0, 20)}...');
    
    return {
      'access_token': newAccessToken ?? '',
      'refresh_token': refreshToken ?? '',
    };
  }

  @override
  Future<void> logout() async {
    _logger.info('Fazendo logout');
    await _restClient.post('/auth/logout');
  }

  @override
  Future<bool> checkLoginStatus() async {
    try {
      _logger.info('Verificando status do login');
      final response = await _restClient.get('/auth/status');
      
      // Verifica se a resposta tem dados válidos
      if (response.data != null && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final isLoggedIn = data['isLoggedIn'] as bool? ?? false;
        _logger.info('Status do login verificado: $isLoggedIn');
        return isLoggedIn;
      }
      
      _logger.info('Resposta da API não contém dados válidos, considerando não logado');
      return false;
    } catch (e) {
      _logger.error('Erro ao verificar status do login: $e');
      // Se há erro (como 403), considera que não está logado
      return false;
    }
  }
} 