import 'package:result_dart/result_dart.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../utils/utils.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/services/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthService authService,
    required AppLogger logger,
  })  : _authService = authService,
        _logger = logger;

  final AuthService _authService;
  final AppLogger _logger;

  @override
  Future<Result<UserEntity, Exception>> login(String username, String password) async {
    try {
      _logger.info('Repository: Iniciando login para usuário: $username');
      final data = await _authService.login(username, password);
      return Success(data);
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado no login', e, s);
      return Failure(Exception('Erro no login: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> logout() async {
    try {
      _logger.info('Repository: Iniciando logout');
      await _authService.logout();
      _logger.info('Repository: Logout realizado com sucesso');
      return Success(null);
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado no logout', e, s);
      return Failure(Exception('Erro no logout: $e'));
    }
  }

  @override
  Future<Result<bool, Exception>> checkLoginStatus() async {
    try {
      _logger.info('Repository: Verificando status do login');
      final data = await _authService.checkLoginStatus();
      _logger.info('Repository: Status do login verificado: $data');
      return Success(data);
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao verificar status do login', e, s);
      return Failure(Exception('Erro ao verificar status do login: $e'));
    }
  }
}
