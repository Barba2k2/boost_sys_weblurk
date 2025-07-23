import 'package:intl/intl.dart';

import '../../core/exceptions/failure.dart';
import '../../core/logger/app_logger.dart';
import '../../core/rest_client/rest_client.dart';
import '../../core/rest_client/rest_client_exception.dart';
import '../../models/score_model.dart';
import '../../models/schedule_list_model.dart';
import '../../models/schedule_model.dart';
import 'home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({
    required RestClient restClient,
    required AppLogger logger,
  })  : _restClient = restClient,
        _logger = logger;

  final RestClient _restClient;
  final AppLogger _logger;

  @override
  Future<List<ScheduleModel>> loadSchedules(DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      // Busca agendamentos de ambas as listas para a data específica
      final responseListA = await _restClient.auth().get(
            '/list-a/get?date=$formattedDate',
          );
      final responseListB = await _restClient.auth().get(
            '/list-b/get?date=$formattedDate',
          );

      final List<ScheduleModel> allSchedules = [];

      if (responseListA.statusCode == 200) {
        final dataA = responseListA.data;
        if (dataA is Map<String, dynamic> && dataA['schedules'] != null) {
          allSchedules.addAll(
            (dataA['schedules'] as List).map((x) => ScheduleModel.fromMap(x)),
          );
        }
      }

      if (responseListB.statusCode == 200) {
        final dataB = responseListB.data;
        if (dataB is Map<String, dynamic> && dataB['schedules'] != null) {
          allSchedules.addAll(
            (dataB['schedules'] as List).map((x) => ScheduleModel.fromMap(x)),
          );
        }
      }

      return allSchedules;
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

      // Busca ambas as listas A e B para a data específica
      final responseListA = await _restClient.auth().get(
            '/list-a/get?date=$formattedDate',
          );
      final responseListB = await _restClient.auth().get(
            '/list-b/get?date=$formattedDate',
          );

      final List<ScheduleListModel> scheduleLists = [];

      try {
        if (responseListA.statusCode == 200) {
          final dataA = responseListA.data;
          if (dataA is Map<String, dynamic>) {
            scheduleLists.add(ScheduleListModel.fromMap(dataA));
          }
        }
      } catch (e) {
        _logger.error('Erro ao fazer parse da resposta da Lista A', e);
        _logger.error(
          'Corpo da resposta Lista A: \n${responseListA.data.toString()}',
        );
        throw Failure(message: 'Erro ao processar dados da Lista A.');
      }

      try {
        if (responseListB.statusCode == 200) {
          final dataB = responseListB.data;
          if (dataB is Map<String, dynamic>) {
            scheduleLists.add(ScheduleListModel.fromMap(dataB));
          }
        }
      } catch (e) {
        _logger.error('Erro ao fazer parse da resposta da Lista B', e);
        _logger.error(
          'Corpo da resposta Lista B: \n${responseListB.data.toString()}',
        );
        throw Failure(message: 'Erro ao processar dados da Lista B.');
      }

      return scheduleLists;
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
      // Usa o endpoint de listas da Lista A (ambos retornam o mesmo resultado)
      final response = await _restClient.auth().get('/list-a/lists');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['list_names'] != null) {
          return List<String>.from(data['list_names']);
        }
        return ['Lista A', 'Lista B']; // Fallback
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
      // Normaliza o nome para evitar erro de contains
      final normalized =
          listName.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
      String endpoint;
      if (normalized == 'listaa') {
        endpoint = '/list-a/get?date=$formattedDate';
      } else if (normalized == 'listab') {
        endpoint = '/list-b/get?date=$formattedDate';
      } else {
        endpoint = '/list-a/get?date=$formattedDate';
      }

      _logger.info('Buscando $listName no endpoint: $endpoint');
      final response = await _restClient.auth().get(endpoint);
      _logger.info('Resposta $listName: status=${response.statusCode}');

      if (response.statusCode == 200) {
        if (response.data != null) {
          final result = ScheduleListModel.fromMap(response.data);
          _logger.info(
            '$listName carregada com ${result.schedules.length} agendamentos',
          );
          return result;
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

      // Busca agendamentos de ambas as listas para a data atual
      final responseListA = await _restClient.auth().get(
            '/list-a/get?date=$formattedDate',
          );
      final responseListB = await _restClient.auth().get(
            '/list-b/get?date=$formattedDate',
          );

      final List<ScheduleModel> allSchedules = [];

      if (responseListA.statusCode == 200) {
        final dataA = responseListA.data;
        if (dataA is Map<String, dynamic> && dataA['schedules'] != null) {
          allSchedules.addAll(
            (dataA['schedules'] as List).map((x) => ScheduleModel.fromMap(x)),
          );
        }
      }

      if (responseListB.statusCode == 200) {
        final dataB = responseListB.data;
        if (dataB is Map<String, dynamic> && dataB['schedules'] != null) {
          allSchedules.addAll(
            (dataB['schedules'] as List).map((x) => ScheduleModel.fromMap(x)),
          );
        }
      }

      // Buscar o agendamento atual baseado no horário
      final now = DateTime.now();
      for (final schedule in allSchedules) {
        try {
          final startTimeStr = schedule.startTime;
          final endTimeStr = schedule.endTime;

          // Remove o formato Time() se presente
          final cleanStartTime =
              startTimeStr.replaceAll('Time(', '').replaceAll(')', '');
          final cleanEndTime =
              endTimeStr.replaceAll('Time(', '').replaceAll(')', '');

          if (cleanStartTime.isEmpty || cleanEndTime.isEmpty) continue;

          final startTimeParts = cleanStartTime.split(':');
          final endTimeParts = cleanEndTime.split(':');

          if (startTimeParts.length < 2 || endTimeParts.length < 2) {
            continue;
          }

          final startDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(startTimeParts[0]),
            int.parse(startTimeParts[1]),
            startTimeParts.length > 2 ? int.parse(startTimeParts[2]) : 0,
          );
          final endDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(endTimeParts[0]),
            int.parse(endTimeParts[1]),
            endTimeParts.length > 2 ? int.parse(endTimeParts[2]) : 0,
          );

          if (now.isAfter(startDateTime) && now.isBefore(endDateTime)) {
            return schedule.streamerUrl;
          }
        } catch (e) {
          _logger.warning('Erro ao processar horário do agendamento: $e');
          continue;
        }
      }

      _logger.info('Nenhum agendamento ativo encontrado');
      return null;
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
      // Verifica se é erro de duplicação (500 com mensagem específica)
      if (e.statusCode == 500 &&
          e.response.data != null &&
          e.response.data
              .toString()
              .contains('duplicate key value violates unique constraint')) {
        // Pontuação já existe, consideramos como sucesso
        _logger.info(
            'Pontuação já existe no banco de dados, ignorando duplicação');
        return;
      }

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
