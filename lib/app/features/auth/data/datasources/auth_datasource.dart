import '../../../../core/logger/app_logger.dart';
import '../../../../core/rest_client/rest_client.dart';
import '../../../../models/user_model.dart';
import '../../../../utils/utils.dart';

abstract class AuthDataSource {
  Future<Result<UserModel>> login(String nickname, String password);
  Future<Result<void>> logout();
}

class AuthDataSourceImpl implements AuthDataSource {
  final RestClient _restClient;
  final AppLogger _logger;

  AuthDataSourceImpl({
    required RestClient restClient,
    required AppLogger logger,
  })  : _restClient = restClient,
        _logger = logger;

  @override
  Future<Result<UserModel>> login(String nickname, String password) async {
    try {
      _logger.info('Fazendo requisição de login para: $nickname');

      final response = await _restClient.post('/auth/login', data: {
        'nickname': nickname,
        'password': password,
      });

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data);
        _logger.info('Login bem-sucedido para: ${user.nickname}');
        return Result.ok(user);
      } else {
        _logger.error('Falha no login: ${response.statusCode}');
        return Result.error(Exception('Credenciais inválidas'));
      }
    } catch (e, s) {
      _logger.error('Erro na requisição de login', e, s);
      return Result.error(e as Exception);
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      _logger.info('Fazendo requisição de logout');

      await _restClient.post('/auth/logout');

      _logger.info('Logout bem-sucedido');
      return Result.ok(null);
    } catch (e, s) {
      _logger.error('Erro na requisição de logout', e, s);
      return Result.error(e as Exception);
    }
  }
}
