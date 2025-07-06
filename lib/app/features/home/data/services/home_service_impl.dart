import '../../../../core/exceptions/failure.dart';
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
  Future<List<dynamic>> fetchSchedules() async {
    _logger.info('Buscando schedules');
    final response = await _restClient.get('/schedules');
    return response.data as List<dynamic>;
  }

  @override
  Future<List<ScheduleListEntity>> fetchScheduleLists() async {
    _logger.info('Buscando listas de schedules');
    final response = await _restClient.get('/schedule-lists');
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => ScheduleListEntity.fromJson(json)).toList();
  }

  @override
  Future<List<String>> getAvailableListNames() async {
    _logger.info('Buscando nomes das listas disponíveis');
    final response = await _restClient.get('/available-list-names');
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((item) => item.toString()).toList();
  }

  @override
  Future<ScheduleListEntity?> fetchScheduleListByName(String listName) async {
    _logger.info('Buscando lista por nome: $listName');
    final response = await _restClient.get('/schedule-list/$listName');
    if (response.data == null) return null;
    return ScheduleListEntity.fromJson(response.data);
  }

  @override
  Future<void> updateLists() async {
    _logger.info('Atualizando listas');
    await _restClient.post('/update-lists');
  }

  @override
  Future<String?> fetchCurrentChannel() async {
    _logger.info('Buscando canal atual');
    final response = await _restClient.get('/current-channel');
    return response.data as String?;
  }

  @override
  Future<String?> fetchCurrentChannelForList(String listName) async {
    _logger.info('Buscando canal atual para lista: $listName');
    final response = await _restClient.get('/current-channel/$listName');
    return response.data as String?;
  }

  @override
  Future<void> saveScore(
    int streamerId,
    DateTime date,
    int hour,
    int minute,
    int points,
  ) async {
    _logger.info(
        'Salvando score para streamer ID: $streamerId, pontos: $points');
    await _restClient.post('/save-score', data: {
      'streamerId': streamerId,
      'date': date.toIso8601String(),
      'hour': hour,
      'minute': minute,
      'points': points,
    });
  }
}
