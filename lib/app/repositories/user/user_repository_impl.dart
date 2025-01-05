import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../core/exceptions/failure.dart';
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
  Future<String> login(String nickname, String password) async {
    try {
      final result = await _restClient.unAuht().post(
        '/auth/login',
        data: {
          'nickname': nickname,
          'password': password,
        },
      );

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

      final deviceToken = const Uuid().v4();

      _logger.debug('Device Token: $deviceToken');

      final data = {
        if (kIsWeb) 'web_token': deviceToken,
        if (!kIsWeb && Platform.isWindows || Platform.isAndroid)
          'windows_token': deviceToken,
      };

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

  @override
  Future<void> updateLoginStatus(int userId, String status) async {
    try {
      await _restClient.auth().post(
        '/streamer/status/update',
        data: {
          'streamerId': userId,
          'status': status,
        },
      );
    } catch (e, s) {
      _logger.error('Failed to update login status', e, s);
      throw Failure(message: 'Failed to update login status');
    }
  }
}
