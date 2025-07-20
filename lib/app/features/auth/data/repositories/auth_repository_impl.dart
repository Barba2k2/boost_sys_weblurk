import '../../../../core/logger/app_logger.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/services/auth_service.dart';
import '../../../../core/result/result.dart';
import 'package:uuid/uuid.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthService authService,
    required AppLogger logger,
  })  : _authService = authService,
        _logger = logger;

  final AuthService _authService;
  final AppLogger _logger;
  final _uuid = const Uuid();

  @override
  Future<AppResult<Map<String, dynamic>>> login(
    String nickname,
    String password,
  ) async {
    try {
      _logger.info('Repository: Iniciando login para usuário: $nickname');

      // Primeira etapa: fazer login
      final loginResponse = await _authService.login(nickname, password);
      final userData = loginResponse['user'] as UserEntity;
      final accessToken = loginResponse['access_token'] as String?;

      // Segunda etapa: confirmar login com windows_token
      if (accessToken != null) {
        // Gerar um windows_token usando UUID
        final windowsToken = _uuid.v4();

        // Extrair apenas o token (remover "Bearer" se presente)
        final cleanAccessToken = accessToken.startsWith('Bearer ')
            ? accessToken.substring(7)
            : accessToken;

        _logger.info(
            'Repository: Confirmando login com windows_token: $windowsToken');
        final confirmResponse =
            await _authService.confirmLogin(cleanAccessToken, windowsToken);
        _logger.info('Repository: Login confirmado com sucesso');

        // Retorna o user junto com os novos tokens
        return AppSuccess({
          'user': userData,
          'access_token': confirmResponse['access_token'],
          'refresh_token': confirmResponse['refresh_token'],
        });
      } else {
        _logger.warning(
            'Repository: Access token não encontrado na resposta do login');
        return AppSuccess({
          'user': userData,
          'access_token': '',
          'refresh_token': '',
        });
      }
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado no login', e, s);
      return AppFailure(Exception('Erro no login: $e'));
    }
  }

  @override
  Future<AppResult<AppUnit>> logout() async {
    try {
      _logger.info('Repository: Iniciando logout');
      await _authService.logout();
      _logger.info('Repository: Logout realizado com sucesso');
      return AppSuccess(appUnit);
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado no logout', e, s);
      return AppFailure(Exception('Erro no logout: $e'));
    }
  }

  @override
  Future<AppResult<bool>> checkLoginStatus() async {
    // Como o app sempre inicia no login, não precisamos verificar o status
    // Retorna false para indicar que não está logado
    _logger.info('Repository: App sempre inicia no login, retornando false');
    return AppSuccess(false);
  }
}
