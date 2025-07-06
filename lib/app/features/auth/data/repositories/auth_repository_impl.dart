import '../../../../core/logger/app_logger.dart';
import '../../../../utils/utils.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/auth_store.dart';
import '../datasources/auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;
  final AppLogger _logger;
  final AuthStore _authStore;

  AuthRepositoryImpl({
    required AuthDataSource dataSource,
    required AppLogger logger,
    required AuthStore authStore,
  })  : _dataSource = dataSource,
        _logger = logger,
        _authStore = authStore;

  @override
  Future<Result<void>> login(String nickname, String password) async {
    try {
      _logger.info('Iniciando login para usuário: $nickname');

      final result = await _dataSource.login(nickname, password);

      if (result.isSuccess) {
        final user = result.asSuccess;
        await _authStore.setUserLogged(user);
        _logger.info('Login realizado com sucesso para: ${user.nickname}');
        return Result.ok(null);
      } else {
        _logger.error('Falha no login: ${result.asErrorValue}');
        return Result.error(result.asErrorValue);
      }
    } catch (e, s) {
      _logger.error('Erro inesperado no login', e, s);
      return Result.error(e as Exception);
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      _logger.info('Iniciando logout');
      await _authStore.clearUserLogged();
      await _dataSource.logout();
      _logger.info('Logout realizado com sucesso');
      return Result.ok(null);
    } catch (e, s) {
      _logger.error('Erro no logout', e, s);
      return Result.error(e as Exception);
    }
  }

  @override
  Future<Result<bool>> isLoggedIn() async {
    try {
      final isLogged = _authStore.isLoggedIn;
      _logger.info('Verificando login: $isLogged');
      return Result.ok(isLogged);
    } catch (e, s) {
      _logger.error('Erro ao verificar login', e, s);
      return Result.error(e as Exception);
    }
  }
}
