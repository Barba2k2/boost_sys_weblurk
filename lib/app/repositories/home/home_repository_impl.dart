import 'package:intl/intl.dart';

import '../../core/exceptions/failure.dart';
import '../../core/logger/app_logger.dart';
import '../../core/rest_client/rest_client.dart';
import '../../core/rest_client/rest_client_exception.dart';
import '../../models/score_model.dart';
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
  Future<List<Map<String, dynamic>>> loadSchedules(DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      final response = await _restClient.auth().get(
            '/schedules/get?date=$formattedDate',
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
      throw Failure(message: 'Erro genérico ao carregar o agendamento');
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
        throw Failure(message: 'Erro ao buscar a URL do canal');
      }
    } catch (e, s) {
      _logger.error('Error fetching channel URL', e, s);
      throw Failure(message: 'Erro ao buscar a URL do canal');
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

      final response = await _restClient.auth().post(
            '/score/save',
            data: data,
          );

      if (response.statusCode != 200) {
        _logger.error('Failed to save score: ${response.statusCode}');
        throw Failure(message: 'Erro ao salvar a pontuação');
      } else {
        _logger.info(
          'Score saved successfully for streamer ${score.streamerId}',
        );
      }
    } catch (e, s) {
      _logger.error('Error saving score', e, s);
      throw Failure(message: 'Erro ao salvar a pontuação');
    }
  }
}
