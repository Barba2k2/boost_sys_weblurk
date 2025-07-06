import '../../../../core/logger/app_logger.dart';
import '../../../../core/rest_client/rest_client.dart';
import '../../domain/entities/schedule_list_entity.dart';
import '../../domain/services/home_service.dart';

class HomeServiceImpl implements HomeService {
  HomeServiceImpl({
    required RestClient restClient,
    required AppLogger logger,
  })  : _restClient = restClient,
        _logger = logger;

  final RestClient _restClient;
  final AppLogger _logger;

  @override
  Future<void> fetchSchedules() async {
    try {
      _logger.info('Buscando schedules');
      // Implementação da busca de schedules
      await Future.delayed(const Duration(milliseconds: 100));
      _logger.info('Schedules buscados com sucesso');
    } catch (e, s) {
      _logger.error('Erro ao buscar schedules', e, s);
      rethrow;
    }
  }

  @override
  Future<List<ScheduleListEntity>> fetchScheduleLists() async {
    try {
      _logger.info('Buscando listas de schedules');
      // Implementação da busca de listas
      await Future.delayed(const Duration(milliseconds: 100));
      return [];
    } catch (e, s) {
      _logger.error('Erro ao buscar listas de schedules', e, s);
      rethrow;
    }
  }

  @override
  Future<List<String>> getAvailableListNames() async {
    try {
      _logger.info('Buscando nomes das listas disponíveis');
      await Future.delayed(const Duration(milliseconds: 100));
      return ['Lista 1', 'Lista 2', 'Lista 3'];
    } catch (e, s) {
      _logger.error('Erro ao buscar nomes das listas', e, s);
      rethrow;
    }
  }

  @override
  Future<ScheduleListEntity?> fetchScheduleListByName(String listName) async {
    try {
      _logger.info('Buscando lista por nome: $listName');
      await Future.delayed(const Duration(milliseconds: 100));
      return null;
    } catch (e, s) {
      _logger.error('Erro ao buscar lista por nome: $listName', e, s);
      rethrow;
    }
  }

  @override
  Future<void> updateLists() async {
    try {
      _logger.info('Atualizando listas');
      await Future.delayed(const Duration(milliseconds: 100));
      _logger.info('Listas atualizadas com sucesso');
    } catch (e, s) {
      _logger.error('Erro ao atualizar listas', e, s);
      rethrow;
    }
  }

  @override
  Future<String?> fetchCurrentChannel() async {
    try {
      _logger.info('Buscando canal atual');
      await Future.delayed(const Duration(milliseconds: 100));
      return 'https://twitch.tv/BoostTeam_123';
    } catch (e, s) {
      _logger.error('Erro ao buscar canal atual', e, s);
      rethrow;
    }
  }

  @override
  Future<String?> fetchCurrentChannelForList(String listName) async {
    try {
      _logger.info('Buscando canal atual para lista: $listName');
      await Future.delayed(const Duration(milliseconds: 100));
      return 'https://twitch.tv/BoostTeam_$listName';
    } catch (e, s) {
      _logger.error('Erro ao buscar canal atual para lista: $listName', e, s);
      rethrow;
    }
  }

  @override
  Future<void> saveScore(
    int streamerId,
    DateTime date,
    int hour,
    int minute,
    int points,
  ) async {
    try {
      _logger.info(
          'Salvando score para streamer ID: $streamerId, pontos: $points');
      await Future.delayed(const Duration(milliseconds: 100));
      _logger.info('Score salvo com sucesso');
    } catch (e, s) {
      _logger.error('Erro ao salvar score', e, s);
      rethrow;
    }
  }
}
