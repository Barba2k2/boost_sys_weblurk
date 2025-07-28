import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../core/exceptions/failure.dart';
import '../../core/logger/app_logger.dart';
import '../../core/rest_client/rest_client.dart';
import '../../core/rest_client/rest_client_exception.dart';
import '../../core/rest_client/dio/dio_rest_client.dart';
import '../../models/confirm_login_model.dart';
import '../../models/user_model.dart';
import 'user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    required AppLogger logger,
    required RestClient restClient,
  })  : _restClient = restClient,
        _logger = logger;

  final RestClient _restClient;
  final AppLogger _logger;

  @override
  Future<String> login(String nickname, String password) async {
    try {
      // Testar conectividade antes de tentar login
      if (_restClient is DioRestClient) {
        final dioClient = _restClient;
        final isConnected = await dioClient.testConnectivity();
        if (!isConnected) {
          throw Failure(
              message:
                  'Erro de conectividade. Verifique sua conexão com a internet.');
        }
      }

      final result = await _restClient.unAuth().post(
        '/auth/login',
        data: {
          'nickname': nickname,
          'password': password,
        },
      );

      if (result.data != null && result.data['access_token'] != null) {
        return result.data['access_token'];
      } else {
        throw Failure(message: 'Token de acesso não encontrado na resposta');
      }
    } on RestClientException catch (e, s) {
      if (e.statusCode == HttpStatus.badRequest ||
          e.statusCode == HttpStatus.forbidden) {
        final errorMessage = e.response.data?['message'] ?? 'Erro de validação';
        if (errorMessage.contains('User not exists') ||
            errorMessage.contains('User not found')) {
          throw Failure(
            message: 'Usuario não encontrado, entre em contato com o suporte!!',
          );
        }
      }

      // Tratamento específico para erros de conexão
      if (e.error != null && e.error.toString().contains('SocketException')) {
        throw Failure(
            message:
                'Erro de conexão. Verifique sua internet e tente novamente.');
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
      final deviceToken = const Uuid().v4();

      final data = {
        if (kIsWeb) 'web_token': deviceToken,
        if (!kIsWeb &&
            (Platform.isWindows || Platform.isAndroid || Platform.isMacOS))
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
