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
            (dataA['schedules'] as List).map(
              (x) => ScheduleModel.fromMap(x),
            ),
          );
        }
      }

      if (responseListB.statusCode == 200) {
        final dataB = responseListB.data;
        if (dataB is Map<String, dynamic> && dataB['schedules'] != null) {
          allSchedules.addAll(
            (dataB['schedules'] as List).map(
              (x) => ScheduleModel.fromMap(x),
            ),
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
            'Erro ao carregar os agendamentos: ${e.message ?? e.statusCode}',
      );
    } catch (e, s) {
      _logger.error('Error on load schedules', e, s);
      throw Failure(
        message: 'Erro ao carregar os agendamentos: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<ScheduleListModel>> loadScheduleLists(DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

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
        message: 'Erro genérico ao carregar as listas: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<String>> getAvailableListNames() async {
    try {
      final response = await _restClient.auth().get('/list-a/lists');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['list_names'] != null) {
          return List<String>.from(data['list_names']);
        }
        return ['Lista A', 'Lista B'];
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

      final response = await _restClient.auth().get(endpoint);

      if (response.statusCode == 200) {
        if (response.data != null) {
          final result = ScheduleListModel.fromMap(response.data);
          return result;
        }
        return null;
      } else {
        throw Failure(
          message: 'Erro ao carregar a lista: ${response.statusCode}',
        );
      }
    } on RestClientException catch (e, s) {
      _logger.error(
        'Error on load list (status code: ${e.statusCode})',
        e,
        s,
      );
      throw Failure(
        message:
            'Erro do RestClient ao carregar a lista: ${e.message ?? e.statusCode}',
      );
    } catch (e, s) {
      _logger.error('Error on load list', e, s);
      throw Failure(
        message: 'Erro genérico ao carregar a lista: ${e.toString()}',
      );
    }
  }

  @override
  Future<String?> getCurrentChannel() async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

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
            (dataA['schedules'] as List).map(
              (x) => ScheduleModel.fromMap(x),
            ),
          );
        }
      }

      if (responseListB.statusCode == 200) {
        final dataB = responseListB.data;
        if (dataB is Map<String, dynamic> && dataB['schedules'] != null) {
          allSchedules.addAll(
            (dataB['schedules'] as List).map(
              (x) => ScheduleModel.fromMap(x),
            ),
          );
        }
      }

      final now = DateTime.now();
      for (final schedule in allSchedules) {
        try {
          final startTimeStr = schedule.startTime;
          final endTimeStr = schedule.endTime;

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
      if (e.statusCode == 500 &&
          e.response.data != null &&
          e.response.data
              .toString()
              .contains('duplicate key value violates unique constraint')) {
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
