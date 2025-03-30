import 'package:intl/intl.dart';

import '../../core/exceptions/failure.dart';
import '../../core/logger/app_logger.dart';
import '../../core/rest_client/rest_client.dart';
import '../../core/rest_client/rest_client_exception.dart';
import '../../models/score_model.dart';
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
        throw Failure(message: 'Erro ao carregar os agendamentos (código ${response.statusCode})');
      }
    } on RestClientException catch (e, s) {
      _logger.error('Error on load schedules (status code: ${e.statusCode})', e, s);
      throw Failure(
        message: 'Erro do RestClient ao carregar o agendamento: ${e.message ?? e.statusCode}',
      );
    } catch (e, s) {
      _logger.error('Error on load schedules', e, s);
      throw Failure(message: 'Erro genérico ao carregar o agendamento: ${e.toString()}');
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
        throw Failure(message: 'Erro ao buscar a URL do canal (código ${response.statusCode})');
      }
    } catch (e, s) {
      _logger.error('Error fetching channel URL', e, s);
      throw Failure(message: 'Erro ao buscar a URL do canal: ${e.toString()}');
    }
  }

  @override
  Future<void> saveScore(ScoreModel score) async {
    try {
      final data = {
        'streamerId': score.streamerId,
        'date': DateFormat('yyyy-MM-dd').format(score.date),
        'hour': score.hour,
        'minute': score.minute,
        'points': score.points,
      };

      _logger.info('Enviando score para o servidor: ${data.toString()}');

      final response = await _restClient.auth().post(
            '/score/save',
            data: data,
          );

      if (response.statusCode == 200) {
        if (response.data != null) {
          _logger.info('Score saved successfully for streamer ${score.streamerId}');
          return;
        }
        throw Failure(message: 'Response data is null');
      } else {
        _logger.warning('Erro ao salvar score: código ${response.statusCode}');
        throw Failure(message: 'Erro ao salvar score: código ${response.statusCode}');
      }
    } on RestClientException catch (e, s) {
      // Código 500 indica erro do servidor que pode ser temporário
      if (e.statusCode == 500) {
        _logger.warning(
          'Erro 500 do servidor ao salvar score: ${e.message ?? "Internal Server Error"}',
        );
        throw Failure(
          message: 'Erro temporário do servidor ao salvar a pontuação (500)',
        );
      } else {
        _logger.error('RestClient error saving score (código ${e.statusCode})', e, s);
        throw Failure(
          message: 'Erro de conexão ao salvar a pontuação: ${e.message ?? e.statusCode}',
        );
      }
    } catch (e, s) {
      _logger.error('Unexpected error saving score', e, s);
      throw Failure(
        message: 'Erro inesperado ao salvar a pontuação: ${e.toString()}',
      );
    }
  }
}
