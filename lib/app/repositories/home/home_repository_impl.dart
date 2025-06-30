import 'package:intl/intl.dart';

import '../../core/exceptions/failure.dart';
import '../../core/logger/app_logger.dart';
import '../../core/rest_client/rest_client.dart';
import '../../core/rest_client/rest_client_exception.dart';
import '../../models/score_model.dart';
import '../../models/schedule_list_model.dart';
import './home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({
    required RestClient restClient,
    required AppLogger logger,
  })  : _restClient = restClient,
        _logger = logger;

  final RestClient _restClient;
  final AppLogger _logger;

  @override
  Future<List<Map<String, dynamic>>> loadSchedules(DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      final response = await _restClient.auth().get(
            '/schedules/get?date=$formattedDate',
          );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Failure(
          message:
              'Erro ao carregar os agendamentos (código ${response.statusCode})',
        );
      }
    } on RestClientException catch (e, s) {
      _logger.error(
        'Error on load schedules (status code: ${e.statusCode})',
        e,
        s,
      );
      throw Failure(
        message:
            'Erro do RestClient ao carregar o agendamento: ${e.message ?? e.statusCode}',
      );
    } catch (e, s) {
      _logger.error('Error on load schedules', e, s);
      throw Failure(
        message: 'Erro genérico ao carregar o agendamento: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<ScheduleListModel>> loadScheduleLists(DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      final response = await _restClient.auth().get(
            '/schedules/get?date=$formattedDate',
          );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        // A API retorna uma lista de objetos com list_name e schedules
        return data.map((item) {
          if (item is Map<String, dynamic>) {
            return ScheduleListModel.fromMap(item);
          } else {
            _logger.warning('Formato de dados inesperado: $item');
            return ScheduleListModel(
                listName: 'Lista Desconhecida', schedules: []);
          }
        }).toList();
      } else {
        throw Failure(
            message:
                'Erro ao carregar as listas de agendamentos (código ${response.statusCode})');
      }
    } on RestClientException catch (e, s) {
      _logger.error(
        'Error on load schedule lists (status code: ${e.statusCode})',
        e,
        s,
      );
      throw Failure(
        message:
            'Erro do RestClient ao carregar as listas: ${e.message ?? e.statusCode}',
      );
    } catch (e, s) {
      _logger.error('Error on load schedule lists', e, s);
      throw Failure(
          message: 'Erro genérico ao carregar as listas: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getAvailableListNames() async {
    try {
      final response = await _restClient.auth().get('/schedules/lists');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => item.toString()).toList();
      } else {
        throw Failure(
          message:
              'Erro ao carregar nomes das listas (código ${response.statusCode})',
        );
      }
    } on RestClientException catch (e, s) {
      _logger.error(
        'Error on get list names (status code: ${e.statusCode})',
        e,
        s,
      );
      throw Failure(
        message:
            'Erro do RestClient ao buscar nomes das listas: ${e.message ?? e.statusCode}',
      );
    } catch (e, s) {
      _logger.error('Error on get list names', e, s);
      throw Failure(
        message: 'Erro genérico ao buscar nomes das listas: ${e.toString()}',
      );
    }
  }

  @override
  Future<ScheduleListModel?> loadScheduleListByName(
    String listName,
    DateTime date,
  ) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      final response = await _restClient.auth().get(
            '/schedules/list?name=$listName&date=$formattedDate',
          );

      if (response.statusCode == 200) {
        if (response.data != null) {
          return ScheduleListModel.fromMap(response.data);
        }
        return null;
      } else {
        throw Failure(
          message:
              'Erro ao carregar lista específica (código ${response.statusCode})',
        );
      }
    } on RestClientException catch (e, s) {
      _logger.error(
        'Error on load specific list (status code: ${e.statusCode})',
        e,
        s,
      );
      throw Failure(
        message:
            'Erro do RestClient ao carregar lista específica: ${e.message ?? e.statusCode}',
      );
    } catch (e, s) {
      _logger.error('Error on load specific list', e, s);
      throw Failure(
        message: 'Erro genérico ao carregar lista específica: ${e.toString()}',
      );
    }
  }

  // @override
  // Future<void> forceUpdateLive() async {
  //   try {
  //     final response = await _restClient.auth().post('/schedule/update');

  //     if (response.statusCode == 200) {
  //       final responseBody = response.data;
  //       final newChannel = responseBody['currentChannel'] as String?;

  //       if (newChannel != null && newChannel.isNotEmpty) {
  //         _logger.info('New channel detected: $newChannel');
  //       }
  //     } else {
  //       _logger.error('Failed to force update live: ${response.statusCode}');
  //       throw Failure(message: 'Erro ao forçar a atualização da live');
  //     }
  //   } catch (e, s) {
  //     _logger.error('Error forcing live update', e, s);
  //     throw Failure(message: 'Erro ao forçar a atualização da live');
  //   }
  // }

  @override
  Future<String?> getCurrentChannel() async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final response = await _restClient.auth().get(
            '/schedules/get?date=$formattedDate',
          );

      if (response.statusCode == 200) {
        // Certifique-se de que a resposta é uma lista e pegue o primeiro item
        if (response.data is List && response.data.isNotEmpty) {
          final firstSchedule = response.data[1];
          return firstSchedule['streamer_url'] as String?;
        } else {
          _logger.warning(
            'A lista de agendamentos está vazia ou a estrutura dos dados não está correta',
          );
          return null;
        }
      } else {
        throw Failure(
          message:
              'Erro ao buscar a URL do canal (código ${response.statusCode})',
        );
      }
    } catch (e, s) {
      _logger.error('Error fetching channel URL', e, s);
      throw Failure(
        message: 'Erro ao buscar a URL do canal: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> saveScore(ScoreModel score) async {
    try {
      final response = await _restClient.auth().post(
            '/score/save',
            data: score.toMap(),
          );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Failure(
          message: 'Erro ao salvar pontuação (código ${response.statusCode})',
        );
      }
    } on RestClientException catch (e, s) {
      _logger.error('Error on save score (status code: ${e.statusCode})', e, s);
      throw Failure(
        message:
            'Erro do RestClient ao salvar pontuação: ${e.message ?? e.statusCode}',
      );
    } catch (e, s) {
      _logger.error('Error on save score', e, s);
      throw Failure(
        message: 'Erro genérico ao salvar pontuação: ${e.toString()}',
      );
    }
  }
}
