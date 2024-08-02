import 'dart:convert';

import '../../core/exceptions/failure.dart';
import '../../core/logger/app_logger.dart';
import '../../core/rest_client/rest_client.dart';
import '../../models/user_model.dart';
import './streamer_repository.dart';

class StreamerRepositoryImpl implements StreamerRepository {
  final RestClient _restClient;
  final AppLogger _logger;

  StreamerRepositoryImpl({
    required RestClient restClient,
    required AppLogger logger,
  })  : _restClient = restClient,
        _logger = logger;

  @override
  Future<void> deleteUser(int id) async {
    try {
      final response = await _restClient.auth().delete('/streamers/delete/$id');

      if (response.statusCode == 200) {
        return jsonDecode(response.data);
      } else {
        throw Failure(message: 'Erro ao buscar os usuários');
      }
    } catch (e, s) {
      _logger.error('Error fetching users', e, s);
      throw Failure(message: 'Erro ao buscar os usuários');
    }
  }

  @override
  Future<void> editUser(
    int id,
    String nickname,
    String password,
    String role,
  ) async {
    try {
      final response = await _restClient.post(
        '/streamers/update/$id',
        data: {
          'nickname': nickname,
          'password': password,
          'role': role,
        },
      );

      if (response.statusCode != 200) {
        throw Failure(message: 'Erro ao atualizar o usuário');
      }
    } catch (e, s) {
      _logger.error('Error updating user', e, s);
      throw Failure(message: 'Erro ao atualizar o usuário');
    }
  }

  @override
  Future<List<UserModel>> fetchUsers() async {
    try {
      final response = await _restClient.auth().get('/streamers/');

      if (response.statusCode == 200) {
        final users = List<Map<String, dynamic>>.from(response.data);

        return users
            .map(
              (user) => UserModel.fromMap(user),
            )
            .toList();
      } else {
        throw Failure(message: 'Erro ao buscar os usuários');
      }
    } catch (e, s) {
      _logger.error('Repository - Error fetching users', e, s);
      throw Failure(message: 'Erro ao buscar os usuários');
    }
  }

  @override
  Future<void> registerUser(
    String nickname,
    String password,
    String role,
  ) async {
    try {
      final response = await _restClient.auth().post(
        '/streamers/save',
        data: {
          'nickname': nickname,
          'password': password,
          'role': role,
        },
      );

      if (response.statusCode != 200) {
        throw Failure(message: 'Erro ao registrar o usuário');
      }
    } catch (e, s) {
      _logger.error('Error registering user', e, s);
      throw Failure(message: 'Erro ao registrar o usuário');
    }
  }
}
