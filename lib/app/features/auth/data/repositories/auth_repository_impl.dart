import '../../../../core/exceptions/failure.dart';
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
  Future<Result<UserEntity>> login(String username, String password) async {
    try {
      _logger.info('Repository: Iniciando login para usuário: $username');
      
      final data = await _authService.login(username, password);
      
      return Result.ok(data).when(
        success: (user) {
          _logger.info('Repository: Login realizado com sucesso para: ${user.username}');
          return Result.ok(user);
        },
        error: (failure) {
          _logger.error('Repository: Erro no login', failure);
          return Result.error(failure);
        },
        loading: () {
          _logger.info('Repository: Fazendo login...');
          return Result.loading();
        },
      );
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado no login', e, s);
      return Result.error(Failure('Erro no login: $e'));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      _logger.info('Repository: Iniciando logout');
      
      await _authService.logout();
      
      return Result.ok(null).when(
        success: (_) {
          _logger.info('Repository: Logout realizado com sucesso');
          return Result.ok(null);
        },
        error: (failure) {
          _logger.error('Repository: Erro no logout', failure);
          return Result.error(failure);
        },
        loading: () {
          _logger.info('Repository: Fazendo logout...');
          return Result.loading();
        },
      );
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado no logout', e, s);
      return Result.error(Failure('Erro no logout: $e'));
    }
  }

  @override
  Future<Result<bool>> checkLoginStatus() async {
    try {
      _logger.info('Repository: Verificando status do login');
      
      final data = await _authService.checkLoginStatus();
      
      return Result.ok(data).when(
        success: (isLoggedIn) {
          _logger.info('Repository: Status do login verificado: $isLoggedIn');
          return Result.ok(isLoggedIn);
        },
        error: (failure) {
          _logger.error('Repository: Erro ao verificar status do login', failure);
          return Result.error(failure);
        },
        loading: () {
          _logger.info('Repository: Verificando status do login...');
          return Result.loading();
        },
      );
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao verificar status do login', e, s);
      return Result.error(Failure('Erro ao verificar status do login: $e'));
    }
  }
}
