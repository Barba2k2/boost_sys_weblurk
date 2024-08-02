import 'dart:convert';

import 'package:intl/intl.dart';

import '../../core/exceptions/failure.dart';
import '../../core/logger/app_logger.dart';
import '../../core/rest_client/rest_client.dart';
import '../../core/rest_client/rest_client_exception.dart';
import './home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final RestClient _restClient;
  final AppLogger _logger;

  HomeRepositoryImpl({
    required RestClient restClient,
    required AppLogger logger,
  })  : _restClient = restClient,
        _logger = logger;

  @override
  Future<void> saveSchedules(
    DateTime selectedDate,
    List<String> streamerUrls,
  ) async {
    try {
      final schedules = streamerUrls.asMap().entries.map(
        (entry) {
          final index = entry.key;
          final url = entry.value;
          return {
            'id': (index + 1).toString(),
            'streamerUrl': url,
            'date': DateFormat('yyyy-MM-dd').format(selectedDate),
            'startTime': '${index.toString().padLeft(2, '0')}:00:00',
            'endTime': '${(index + 1).toString().padLeft(2, '0')}:00:00',
          };
        },
      ).toList();

      final response = await _restClient.auth().post(
            '/schedules/save',
            data: jsonEncode(schedules),
          );

      if (response.statusCode != 200) {
        throw Failure(message: 'Erro ao salvar o agendamento');
      }
    } on RestClientException catch (e, s) {
      _logger.error('Error on save schedules', e, s);
      throw Failure(message: 'Erro do RestClient ao salvar o agendamento');
    } catch (e, s) {
      _logger.error('Error on save schedules', e, s);
      throw Failure(message: 'Erro generico salvar o agendamento');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> loadSchedules(
    DateTime selectedDate,
  ) async {
    try {
      var dateSelected = DateFormat('yyyy-MM-dd').format(selectedDate);

      final response = await _restClient.auth().get(
            '/schedules/get?date=$dateSelected',
          );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Failure(message: 'Erro ao carregar os agendamentos');
      }
    } on RestClientException catch (e, s) {
      _logger.error('Error on load schedules', e, s);
      throw Failure(message: 'Erro do RestClient ao carregar o agendamento');
    } catch (e, s) {
      _logger.error('Error on load schedules', e, s);
      throw Failure(message: 'Erro generico carregar o agendamento');
    }
  }

  @override
  Future<void> forceUpdateLive() async {
    try {
      final response = await _restClient.auth().post('/schedules/update');

      if (response.statusCode == 200) {
        return;
      } else {
        throw Failure(message: 'Erro ao forçar a atualização da live');
      }
    } on RestClientException catch (e, s) {
      _logger.error('Error on force update live', e, s);
      throw Failure(
        message: 'Erro do RestClient ao forçar a atualização da live',
      );
    } catch (e, s) {
      _logger.error('Error forcing live update', e, s);
      throw Failure(message: 'Erro genérico ao forçar a atualização da live');
    }
  }
}
