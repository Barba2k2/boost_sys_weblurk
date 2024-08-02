import 'dart:io';

import 'package:get/get_connect/http/src/status/http_status.dart';

import '../../core/exceptions/failure.dart';
import '../../core/exceptions/user_exists_exception.dart';
import '../../core/logger/app_logger.dart';
import '../../core/rest_client/rest_client.dart';
import '../../core/rest_client/rest_client_exception.dart';
import '../../models/confirm_login_model.dart';
import '../../models/user_model.dart';
import 'user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final RestClient _restClient;
  final AppLogger _logger;

  UserRepositoryImpl({
    required AppLogger logger,
    required RestClient restClient,
  })  : _restClient = restClient,
        _logger = logger;

  @override
  Future<void> register(String nickname, String password, String role) async {
    try {
      await _restClient.auth().post(
        '/auth/register',
        data: {
          'nickname': nickname,
          'password': password,
          'role': role,
        },
      );
    } on RestClientException catch (e, s) {
      if (e.statusCode == HttpStatus.badRequest &&
          e.response.data['message'].contains('User already exists')) {
        _logger.error('User already exists - ${e.error}', e, s);
        throw UserExistsException();
      }
      _logger.error('Failed to register user', e, s);
      throw Failure(message: 'Failed to register user');
    }
  }

  @override
  Future<String> login(String nickname, String password) async {
    try {
      final result = await _restClient.unAuht().post(
        '/auth/login',
        data: {
          'nickname': nickname,
          'password': password,
        },
      );

      _logger.info('Response Data: ${result.data}');
      _logger.info('Response Data: ${result.statusCode}');
      _logger.info('Response Data: ${result.statusMessage}');

      return result.data['access_token'];
    } on RestClientException catch (e, s) {
      if (e.statusCode == HttpStatus.badRequest ||
          e.response.data['message'].contains('User not exists')) {
        _logger.error('Error: ${e.response.data['message']}', e, s);
        _logger.error('User not exists - ${e.error}', e, s);
        throw Failure(
          message: 'Usuario não encontrado, entre em contato com o suporte!!',
        );
      }
      _logger.error('Repository - Failed to login user', e, s);
      throw Failure(message: 'Erro ao realizar login');
    } catch (e, s) {
      _logger.error('Repository - Failed to login user - 2', e, s);
      throw Failure(message: 'Erro ao realizar login - 2');
    }
  }

  @override
  Future<ConfirmLoginModel> confirmLogin() async {
    try {
      // final deviceToken = await FirebaseMessaging.instance.getToken();

      final deviceToken = '';

      final data = {
        'web_token': Platform.isAndroid ? deviceToken : null,
        "windows_token": Platform.isWindows ? deviceToken : null,
      };

      _logger.info('Data being sent: $data');

      final result = await _restClient.auth().patch(
            '/auth/confirm',
            data: data,
          );

      return ConfirmLoginModel.fromMap(result.data);
    } on RestClientException catch (e, s) {
      _logger.error('Failed to confirm login', e, s);
      throw Failure(message: 'Erro ao confirmar login');
    } catch (e, s) {
      _logger.error('Failed to confirm login - 2', e, s);
      throw Failure(message: 'Erro ao confirmar login - 2');
    }
  }

  @override
  Future<UserModel> getUserLogged() async {
    try {
      final result = await _restClient.auth().get('/user/');

      return UserModel.fromMap(result.data);
    } on RestClientException catch (e, s) {
      _logger.error('Failed to get user logged', e, s);
      throw Failure(message: 'Erro ao obter usuário logado');
    } catch (e, s) {
      _logger.error('Failed to get user logged - 2', e, s);
      throw Failure(message: 'Erro ao obter usuário logado - 2');
    }
  }
}
