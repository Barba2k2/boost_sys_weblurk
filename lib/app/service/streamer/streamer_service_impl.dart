import '../../core/exceptions/failure.dart';
import '../../core/logger/app_logger.dart';
import '../../models/user_model.dart';
import '../../repositories/streamer/streamer_repository.dart';
import './streamer_service.dart';

class StreamerServiceImpl implements StreamerService {
  final StreamerRepository _streamerRepository;
  final AppLogger _logger;

  StreamerServiceImpl({
    required AppLogger logger,
    required StreamerRepository streamerRepository,
  })  : _logger = logger,
        _streamerRepository = streamerRepository;

  @override
  Future<List<UserModel>> fetchUsers() async {
    try {
      return await _streamerRepository.fetchUsers();
    } catch (e, s) {
      _logger.error('Service - Error fetching users', e, s);
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
      await _streamerRepository.registerUser(nickname, password, role);
    } catch (e, s) {
      _logger.error('Error registering user', e, s);
      throw Failure(message: 'Erro ao registrar o usuário');
    }
  }

  @override
  Future<void> deleteUser(int id) async {
    try {
      await _streamerRepository.deleteUser(id);
    } catch (e, s) {
      _logger.error('Error deleting user', e, s);
      throw Failure(message: 'Erro ao deletar o usuário');
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
      _logger.info('Sending update request to repository for user ID: $id');
      await _streamerRepository.editUser(id, nickname, password, role);
    } catch (e, s) {
      _logger.error('Error updating user', e, s);
      throw Failure(message: 'Erro ao atualizar o usuário');
    }
  }
}
